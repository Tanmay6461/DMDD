CREATE OR REPLACE PACKAGE BODY healthcare_pkg AS
    -- Register patient implementation with enhanced validations
    PROCEDURE register_patient(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_street_name IN VARCHAR2,
        p_city IN VARCHAR2,
        p_state IN VARCHAR2
    ) AS
        v_patient_id NUMBER;
        v_address_id NUMBER;
    BEGIN
        -- Validate parameters are not null
        IF p_first_name IS NULL THEN
            RAISE_APPLICATION_ERROR(healthcare_exceptions.null_parameter_code, 'First name cannot be NULL');
        END IF;
        
        IF p_last_name IS NULL THEN
            RAISE_APPLICATION_ERROR(healthcare_exceptions.null_parameter_code, 'Last name cannot be NULL');
        END IF;
        
        -- Validate name lengths (based on table constraints)
        IF LENGTH(p_first_name) < 1 OR LENGTH(p_first_name) > 150 THEN
            RAISE_APPLICATION_ERROR(-20012, 'First name must be between 1 and 150 characters');
        END IF;
        
        IF LENGTH(p_last_name) < 1 OR LENGTH(p_last_name) > 150 THEN
            RAISE_APPLICATION_ERROR(-20013, 'Last name must be between 1 and 150 characters');
        END IF;
        
        -- Validate address data if provided
        IF p_street_name IS NOT NULL AND LENGTH(p_street_name) > 100 THEN
            RAISE_APPLICATION_ERROR(-20014, 'Street name cannot exceed 100 characters');
        END IF;
        
        IF p_city IS NOT NULL AND LENGTH(p_city) > 50 THEN
            RAISE_APPLICATION_ERROR(-20015, 'City cannot exceed 50 characters');
        END IF;
        
        IF p_state IS NOT NULL AND LENGTH(p_state) > 20 THEN
            RAISE_APPLICATION_ERROR(-20016, 'State cannot exceed 20 characters');
        END IF;
        
        -- Create address if provided
        IF p_street_name IS NOT NULL OR p_city IS NOT NULL OR p_state IS NOT NULL THEN
            SELECT NVL(MAX(address_id), 0) + 1 INTO v_address_id FROM Patient_Address;
            
            -- Insert patient address
            INSERT INTO Patient_Address (address_id, street_name, city, state)
            VALUES (v_address_id, TRIM(p_street_name), TRIM(p_city), UPPER(TRIM(p_state)));
        END IF;
        
        -- Insert patient details (with address_id if available)
        INSERT INTO Patient (first_name, last_name, address_id)
        VALUES (TRIM(p_first_name), TRIM(p_last_name), v_address_id)
        RETURNING patient_id INTO v_patient_id;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Patient registered successfully with ID: ' || v_patient_id);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    END register_patient;
    
    -- Add medical record implementation with enhanced validations
    PROCEDURE add_medical_record(
        p_patient_id IN INTEGER,
        p_doctor_id IN INTEGER,
        p_symptoms IN VARCHAR2,
        p_diagnosis IN VARCHAR2,
        p_drug_id IN INTEGER
    ) AS
        v_patient_exists NUMBER;
        v_doctor_exists NUMBER;
        v_drug_exists NUMBER;
    BEGIN
        -- Individual null parameter checks
        IF p_patient_id IS NULL THEN
            RAISE_APPLICATION_ERROR(healthcare_exceptions.null_parameter_code, 'Patient ID cannot be NULL');
        END IF;
        
        IF p_doctor_id IS NULL THEN
            RAISE_APPLICATION_ERROR(healthcare_exceptions.null_parameter_code, 'Doctor ID cannot be NULL');
        END IF;
        
        IF p_diagnosis IS NULL THEN
            RAISE_APPLICATION_ERROR(healthcare_exceptions.null_parameter_code, 'Diagnosis cannot be NULL');
        END IF;
        
        IF p_drug_id IS NULL THEN
            RAISE_APPLICATION_ERROR(healthcare_exceptions.null_parameter_code, 'Drug ID cannot be NULL');
        END IF;
        
        -- Validate ID formats
        IF p_patient_id <= 0 THEN
            RAISE_APPLICATION_ERROR(-20020, 'Patient ID must be a positive number');
        END IF;
        
        IF p_doctor_id <= 0 THEN
            RAISE_APPLICATION_ERROR(-20021, 'Doctor ID must be a positive number');
        END IF;
        
        IF p_drug_id <= 0 THEN
            RAISE_APPLICATION_ERROR(-20022, 'Drug ID must be a positive number');
        END IF;
        
        -- Validate text fields
        IF p_diagnosis IS NOT NULL AND LENGTH(p_diagnosis) > 150 THEN
            RAISE_APPLICATION_ERROR(-20023, 'Diagnosis cannot exceed 150 characters');
        END IF;
        
        IF p_symptoms IS NOT NULL AND LENGTH(p_symptoms) > 150 THEN
            RAISE_APPLICATION_ERROR(-20024, 'Symptoms cannot exceed 150 characters');
        END IF;
        
        -- Check if patient exists
        SELECT COUNT(*) INTO v_patient_exists
        FROM Patient
        WHERE patient_id = p_patient_id;
        
        IF v_patient_exists = 0 THEN
            RAISE_APPLICATION_ERROR(healthcare_exceptions.patient_not_found_code, 
                'Patient ID ' || p_patient_id || ' not found');
        END IF;
        
        -- Check if doctor exists
        SELECT COUNT(*) INTO v_doctor_exists
        FROM Doctor_Details
        WHERE doctor_id = p_doctor_id;
        
        IF v_doctor_exists = 0 THEN
            RAISE_APPLICATION_ERROR(healthcare_exceptions.doctor_not_found_code, 
                'Doctor ID ' || p_doctor_id || ' not found');
        END IF;
        
        -- Check if doctor has treated this patient before
        DECLARE
            v_previous_treatments NUMBER;
        BEGIN
            SELECT COUNT(*) INTO v_previous_treatments
            FROM Medication_Information
            WHERE patient_id = p_patient_id
            AND doctor_id = p_doctor_id;
            
            IF v_previous_treatments = 0 THEN
                DBMS_OUTPUT.PUT_LINE('Note: This is the first time Doctor ID ' || p_doctor_id || ' is treating this patient');
            END IF;
        END;
        
        -- Check if drug exists
        SELECT COUNT(*) INTO v_drug_exists
        FROM Drug_Details
        WHERE drug_id = p_drug_id;
        
        IF v_drug_exists = 0 THEN
            RAISE_APPLICATION_ERROR(healthcare_exceptions.drug_not_found_code, 
                'Drug ID ' || p_drug_id || ' not found');
        END IF;
        
        -- Check for duplicate prescription in the same day
        DECLARE
            v_same_day_prescriptions NUMBER;
        BEGIN
            SELECT COUNT(*) INTO v_same_day_prescriptions
            FROM Medication_Information
            WHERE patient_id = p_patient_id
            AND drug_id = p_drug_id
            AND TRUNC(date_administered) = TRUNC(SYSDATE);
            
            IF v_same_day_prescriptions > 0 THEN
                DBMS_OUTPUT.PUT_LINE('Warning: This drug was already prescribed to this patient today');
            END IF;
        END;
        
        -- Add to medical history (using IDENTITY column)
        INSERT INTO Medical_History (symptoms, diagnosis, date_detected, patient_id)
        VALUES (TRIM(p_symptoms), TRIM(p_diagnosis), SYSDATE, p_patient_id);
        
        -- Add prescription (using IDENTITY column)
        INSERT INTO Medication_Information (date_administered, patient_id, doctor_id, drug_id)
        VALUES (SYSDATE, p_patient_id, p_doctor_id, p_drug_id);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Medical record added successfully');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    END add_medical_record;
    
    -- Order diagnostic test implementation with enhanced validations
    PROCEDURE order_diagnostic_test(
        p_patient_id IN INTEGER,
        p_diagnostic_id IN INTEGER,
        p_test_result IN VARCHAR2
    ) AS
        v_patient_exists NUMBER;
        v_diagnostic_exists NUMBER;
        v_test_charge NUMBER;
    BEGIN
        -- Individual null parameter checks
        IF p_patient_id IS NULL THEN
            RAISE_APPLICATION_ERROR(healthcare_exceptions.null_parameter_code, 'Patient ID cannot be NULL');
        END IF;
        
        IF p_diagnostic_id IS NULL THEN
            RAISE_APPLICATION_ERROR(healthcare_exceptions.null_parameter_code, 'Diagnostic ID cannot be NULL');
        END IF;
        
        -- Validate ID formats
        IF p_patient_id <= 0 THEN
            RAISE_APPLICATION_ERROR(-20030, 'Patient ID must be a positive number');
        END IF;
        
        IF p_diagnostic_id <= 0 THEN
            RAISE_APPLICATION_ERROR(-20031, 'Diagnostic ID must be a positive number');
        END IF;
        
        -- Validate test result if provided
        IF p_test_result IS NOT NULL AND LENGTH(p_test_result) > 100 THEN
            RAISE_APPLICATION_ERROR(-20032, 'Test result cannot exceed 100 characters');
        END IF;
        
        -- Check if patient exists
        SELECT COUNT(*) INTO v_patient_exists
        FROM Patient
        WHERE patient_id = p_patient_id;
        
        IF v_patient_exists = 0 THEN
            RAISE_APPLICATION_ERROR(healthcare_exceptions.patient_not_found_code, 
                'Patient ID ' || p_patient_id || ' not found');
        END IF;
        
        -- Check if diagnostic test exists and get its charge
        BEGIN
            SELECT COUNT(*), MAX(test_charge) 
            INTO v_diagnostic_exists, v_test_charge
            FROM Diagnostic_Test
            WHERE diagnostic_id = p_diagnostic_id;
            
            IF v_diagnostic_exists = 0 THEN
                RAISE_APPLICATION_ERROR(healthcare_exceptions.diagnostic_not_found_code, 
                    'Diagnostic ID ' || p_diagnostic_id || ' not found');
            END IF;
            
            -- Validate test charge as per CHECK constraint
            IF v_test_charge <= 0 THEN
                RAISE_APPLICATION_ERROR(-20033, 'Diagnostic test charge must be greater than 0');
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(healthcare_exceptions.diagnostic_not_found_code, 
                    'Diagnostic ID ' || p_diagnostic_id || ' not found');
        END;
        
        -- Check for duplicate recent diagnostic test
        DECLARE
            v_recent_tests NUMBER;
        BEGIN
            SELECT COUNT(*) INTO v_recent_tests
            FROM Prescribed_Diagnostics
            WHERE patient_id = p_patient_id
            AND diagnostic_test_id = p_diagnostic_id
            AND date_administered > SYSDATE - 7;  -- Within the last week
            
            IF v_recent_tests > 0 THEN
                DBMS_OUTPUT.PUT_LINE('Warning: This test was already ordered for this patient within the last 7 days');
            END IF;
        END;
        
        -- Insert prescribed diagnostic (using IDENTITY column)
        INSERT INTO Prescribed_Diagnostics (
            date_administered, test_result, patient_id, diagnostic_test_id
        )
        VALUES (
            SYSDATE, TRIM(p_test_result), p_patient_id, p_diagnostic_id
        );
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Diagnostic test ordered successfully');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    END order_diagnostic_test;
    
    -- Get patient expenses procedure
    PROCEDURE get_patient_expenses(
        p_patient_id IN INTEGER,
        p_med_expenses OUT NUMBER,
        p_diag_expenses OUT NUMBER,
        p_total_expenses OUT NUMBER
    ) 
    IS
    BEGIN
        -- Calculate medication expenses
        SELECT NVL(SUM(dd.drug_price), 0)
        INTO p_med_expenses
        FROM Medication_Information mi
        JOIN Drug_Details dd ON mi.drug_id = dd.drug_id
        WHERE mi.patient_id = p_patient_id;
        
        -- Calculate diagnostic test expenses
        SELECT NVL(SUM(dt.test_charge), 0)
        INTO p_diag_expenses
        FROM Prescribed_Diagnostics pd
        JOIN Diagnostic_Test dt ON pd.diagnostic_test_id = dt.diagnostic_id
        WHERE pd.patient_id = p_patient_id;
        
        -- Total expenses
        p_total_expenses := p_med_expenses + p_diag_expenses;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_med_expenses := 0;
            p_diag_expenses := 0;
            p_total_expenses := 0;
        WHEN OTHERS THEN
            p_med_expenses := -1;
            p_diag_expenses := -1;
            p_total_expenses := -1;
            DBMS_OUTPUT.PUT_LINE('Error calculating expenses: ' || SQLERRM);
    END get_patient_expenses;
    
    -- Display bill procedure
    PROCEDURE display_patient_bill(p_patient_id IN INTEGER)
    IS
        v_patient_name VARCHAR2(300);
        v_doctor_name VARCHAR2(100);
        v_medication_cost NUMBER;
        v_diagnostic_cost NUMBER;
        v_total_amount NUMBER;
        v_patient_exists NUMBER;
    BEGIN
        -- Check if patient exists
        SELECT COUNT(*) INTO v_patient_exists
        FROM Patient
        WHERE patient_id = p_patient_id;
        
        IF v_patient_exists = 0 THEN
            RAISE_APPLICATION_ERROR(healthcare_exceptions.patient_not_found_code, 
                'Patient ID ' || p_patient_id || ' not found');
        END IF;
        
        -- Get patient name
        SELECT first_name || ' ' || last_name
        INTO v_patient_name
        FROM Patient
        WHERE patient_id = p_patient_id;
        
        -- Get most recent doctor name
        BEGIN
            SELECT MAX(dd.first_name || ' ' || dd.last_name)
            INTO v_doctor_name
            FROM Medication_Information mi
            JOIN Doctor_Details dd ON mi.doctor_id = dd.doctor_id
            WHERE mi.patient_id = p_patient_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_doctor_name := 'No doctor assigned';
        END;
        
        -- Get all expenses using the procedure
        get_patient_expenses(p_patient_id, v_medication_cost, v_diagnostic_cost, v_total_amount);
        
        -- Display bill information
        DBMS_OUTPUT.PUT_LINE('--- HEALTHCARE BILL ---');
        DBMS_OUTPUT.PUT_LINE('Patient: ' || v_patient_name);
        DBMS_OUTPUT.PUT_LINE('Doctor: ' || v_doctor_name);
        DBMS_OUTPUT.PUT_LINE('Bill Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY'));
        DBMS_OUTPUT.PUT_LINE('------------------------');
        DBMS_OUTPUT.PUT_LINE('Medication Cost: $' || TO_CHAR(v_medication_cost, '999,999.99'));
        DBMS_OUTPUT.PUT_LINE('Diagnostic Cost: $' || TO_CHAR(v_diagnostic_cost, '999,999.99'));
        DBMS_OUTPUT.PUT_LINE('------------------------');
        DBMS_OUTPUT.PUT_LINE('Total Amount: $' || TO_CHAR(v_total_amount, '999,999.99'));
        DBMS_OUTPUT.PUT_LINE('------------------------');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: Patient ID ' || p_patient_id || ' not found.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    END display_patient_bill;
    
END healthcare_pkg;
/

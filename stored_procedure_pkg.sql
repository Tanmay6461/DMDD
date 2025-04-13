CREATE OR REPLACE PACKAGE BODY healthcare_pkg AS
   
    PROCEDURE register_patient(
        p_patient_id IN INTEGER,
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_doctor_id IN INTEGER,
        p_street_name IN VARCHAR2,
        p_city IN VARCHAR2,
        p_state IN VARCHAR2
    ) AS
        v_doctor_exists NUMBER;
        v_patient_exists NUMBER;
    BEGIN
        -- Validate all parameters are not null
        IF p_patient_id IS NULL THEN
            RAISE_APPLICATION_ERROR(healthcare_exceptions.null_parameter_code, 'Patient ID cannot be NULL');
        END IF;
        
        IF p_first_name IS NULL THEN
            RAISE_APPLICATION_ERROR(healthcare_exceptions.null_parameter_code, 'First name cannot be NULL');
        END IF;
        
        IF p_last_name IS NULL THEN
            RAISE_APPLICATION_ERROR(healthcare_exceptions.null_parameter_code, 'Last name cannot be NULL');
        END IF;
        
        IF p_doctor_id IS NULL THEN
            RAISE_APPLICATION_ERROR(healthcare_exceptions.null_parameter_code, 'Doctor ID cannot be NULL');
        END IF;
        -- Validate ID formats
        IF p_patient_id <= 0 THEN
            RAISE_APPLICATION_ERROR(-20010, 'Patient ID must be a positive number');
        END IF;
        
        IF p_doctor_id <= 0 THEN
            RAISE_APPLICATION_ERROR(-20011, 'Doctor ID must be a positive number');
        END IF;
        
        -- Validate name lengths (based on your table constraints)
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
         -- Check if doctor exists
        SELECT COUNT(*) INTO v_doctor_exists
        FROM Doctor_Details
        WHERE doctor_id = p_doctor_id;
        
        IF v_doctor_exists = 0 THEN
            RAISE_APPLICATION_ERROR(healthcare_exceptions.doctor_not_found_code, 
                'Doctor ID ' || p_doctor_id || ' not found');
        END IF;
        
        -- Check if patient already exists
        SELECT COUNT(*) INTO v_patient_exists
        FROM Patient
        WHERE patient_id = p_patient_id;
        
        IF v_patient_exists > 0 THEN
            RAISE_APPLICATION_ERROR(healthcare_exceptions.patient_exists_code, 
                'Patient ID ' || p_patient_id || ' already exists');
        END IF;
        
        -- Insert patient details
        INSERT INTO Patient (patient_id, first_name, last_name, doctor_id)
        VALUES (p_patient_id, TRIM(p_first_name), TRIM(p_last_name), p_doctor_id);
        
        -- Insert patient address if provided
        IF p_street_name IS NOT NULL OR p_city IS NOT NULL OR p_state IS NOT NULL THEN
            INSERT INTO Patient_Address (address_id, street_name, city, state, patient_id)
            VALUES ((SELECT NVL(MAX(address_id), 0) + 1 FROM Patient_Address), 
                    TRIM(p_street_name), TRIM(p_city), UPPER(TRIM(p_state)), p_patient_id);
        END IF;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Patient registered successfully');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    END register_patient;

 --2 Add medical record implementation with enhanced validations
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
        v_history_id INTEGER;
        v_prescription_id INTEGER;
        v_doctor_match NUMBER;
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
        
        -- Check if doctor is patient's assigned doctor
        SELECT COUNT(*) INTO v_doctor_match
        FROM Patient
        WHERE patient_id = p_patient_id
        AND doctor_id = p_doctor_id;
        
        IF v_doctor_match = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Warning: Doctor ID ' || p_doctor_id || ' is not the assigned doctor for this patient');
        END IF;
        
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
        
        -- Add to medical history
        SELECT NVL(MAX(patient_history_id), 0) + 1 INTO v_history_id FROM Medical_History;
        
        INSERT INTO Medical_History (patient_history_id, symptoms, diagnosis, date_detected, patient_id)
        VALUES (v_history_id, 
                TRIM(p_symptoms), 
                TRIM(p_diagnosis), 
                SYSDATE, 
                p_patient_id);
        
        -- Add prescription
        SELECT NVL(MAX(prescription_id), 0) + 1 INTO v_prescription_id FROM Medication_Information;
        
        INSERT INTO Medication_Information (prescription_id, date_administered, patient_id, doctor_id, drug_id)
        VALUES (v_prescription_id, SYSDATE, p_patient_id, p_doctor_id, p_drug_id);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Medical record added successfully');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    END add_medical_record;

END healthcare_pkg;
/


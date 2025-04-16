CREATE OR REPLACE PROCEDURE get_patient_bill(
    p_patient_id IN INTEGER
) AS
    v_patient_exists NUMBER;
    v_patient_name VARCHAR2(300);
    v_medication_cost NUMBER := 0;
    v_diagnostic_cost NUMBER := 0;
    v_total_amount NUMBER := 0;
    v_has_records NUMBER := 0;
    v_doctor_name VARCHAR2(100);
BEGIN
    -- Validate patient ID
    IF p_patient_id IS NULL THEN
        RAISE_APPLICATION_ERROR(healthcare_exceptions.null_parameter_code, 
            'Patient ID cannot be NULL');
    END IF;
    
    IF p_patient_id <= 0 THEN
        RAISE_APPLICATION_ERROR(-20040, 'Patient ID must be a positive number');
    END IF;
    
    -- Check if patient exists
    SELECT COUNT(*) INTO v_patient_exists
    FROM Patient
    WHERE patient_id = p_patient_id;
    
    IF v_patient_exists = 0 THEN
        RAISE_APPLICATION_ERROR(healthcare_exceptions.patient_not_found_code, 
            'Patient ID ' || p_patient_id || ' not found');
    END IF;
    
    -- Check if patient has any records to bill
    SELECT COUNT(*) INTO v_has_records
    FROM (
        SELECT 1 FROM Medication_Information WHERE patient_id = p_patient_id
        UNION
        SELECT 1 FROM Prescribed_Diagnostics WHERE patient_id = p_patient_id
    );
         
    IF v_has_records = 0 THEN
        RAISE_APPLICATION_ERROR(-20041, 'No billable records found for Patient ID ' || p_patient_id);
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
        
        IF v_doctor_name IS NULL THEN
            v_doctor_name := 'No doctor assigned';
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_doctor_name := 'No doctor assigned';
    END;
    
    -- Calculate medication expenses
    SELECT NVL(SUM(dd.drug_price), 0)
    INTO v_medication_cost
    FROM Medication_Information mi
    JOIN Drug_Details dd ON mi.drug_id = dd.drug_id
    WHERE mi.patient_id = p_patient_id;
    
    -- Calculate diagnostic test expenses
    SELECT NVL(SUM(dt.test_charge), 0)
    INTO v_diagnostic_cost
    FROM Prescribed_Diagnostics pd
    JOIN Diagnostic_Test dt ON pd.diagnostic_test_id = dt.diagnostic_id
    WHERE pd.patient_id = p_patient_id;
    
    -- Get total amount using the function
    v_total_amount := get_patient_total_expenses(p_patient_id);
    
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
END get_patient_bill;
/




CREATE OR REPLACE PROCEDURE update_patient_details(
    p_patient_id   IN INTEGER,
    p_first_name   IN VARCHAR2,
    p_last_name    IN VARCHAR2,
    p_city         IN VARCHAR2,
    p_state        IN VARCHAR2
) AS
    v_exists NUMBER;
    v_address_id NUMBER;
BEGIN
    -- Null checks
    IF p_patient_id IS NULL THEN
        RAISE_APPLICATION_ERROR(healthcare_exceptions.null_parameter_code, 'Patient ID cannot be NULL');
    END IF;
    
    -- Check if patient exists
    SELECT COUNT(*) INTO v_exists
    FROM Patient
    WHERE patient_id = p_patient_id;
    
    IF v_exists = 0 THEN
        RAISE_APPLICATION_ERROR(healthcare_exceptions.patient_not_found_code, 'Patient ID ' || p_patient_id || ' not found');
    END IF;
    
    -- Update Patient basic info
    UPDATE Patient
    SET first_name = NVL(TRIM(p_first_name), first_name),
        last_name  = NVL(TRIM(p_last_name), last_name)
    WHERE patient_id = p_patient_id;
    
    -- Get address_id
    SELECT address_id INTO v_address_id
    FROM Patient
    WHERE patient_id = p_patient_id;
    
    -- Update Patient_Address if city/state provided
    IF (p_city IS NOT NULL OR p_state IS NOT NULL) AND v_address_id IS NOT NULL THEN
        UPDATE Patient_Address
        SET city = NVL(TRIM(p_city), city),
            state = NVL(UPPER(TRIM(p_state)), state)
        WHERE address_id = v_address_id;
    ELSIF (p_city IS NOT NULL OR p_state IS NOT NULL) AND v_address_id IS NULL THEN
        -- Create a new address if patient doesn't have one
        SELECT NVL(MAX(address_id), 0) + 1 INTO v_address_id FROM Patient_Address;
        
        INSERT INTO Patient_Address (address_id, street_name, city, state, patient_id)
        VALUES (v_address_id, NULL, TRIM(p_city), UPPER(TRIM(p_state)), p_patient_id);
        
        -- Update patient with new address_id
        UPDATE Patient
        SET address_id = v_address_id
        WHERE patient_id = p_patient_id;
    END IF;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Patient details updated successfully.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END update_patient_details;
/

--Stored procedure for DELETE
CREATE OR REPLACE PROCEDURE delete_patient_record(
    p_patient_id IN INTEGER
) AS
    v_exists NUMBER;
    v_address_id NUMBER;
BEGIN
    IF p_patient_id IS NULL THEN
        RAISE_APPLICATION_ERROR(healthcare_exceptions.null_parameter_code, 'Patient ID cannot be NULL');
    END IF;
    
    -- Check if patient exists
    SELECT COUNT(*) INTO v_exists
    FROM Patient
    WHERE patient_id = p_patient_id;
    
    IF v_exists = 0 THEN
        RAISE_APPLICATION_ERROR(healthcare_exceptions.patient_not_found_code, 'Patient ID ' || p_patient_id || ' not found');
    END IF;
    
    -- Get the address_id before deleting patient
    BEGIN
        SELECT address_id INTO v_address_id
        FROM Patient
        WHERE patient_id = p_patient_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_address_id := NULL;
    END;
    
    -- Delete dependencies first
    DELETE FROM Prescribed_Diagnostics WHERE patient_id = p_patient_id;
    DELETE FROM Medication_Information WHERE patient_id = p_patient_id;
    DELETE FROM Medical_History WHERE patient_id = p_patient_id;
    
    -- Delete patient first (since address depends on patient in your schema)
    DELETE FROM Patient WHERE patient_id = p_patient_id;
    
    -- Delete address if it exists
    IF v_address_id IS NOT NULL THEN
        DELETE FROM Patient_Address WHERE address_id = v_address_id;
    END IF;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Patient record and related data deleted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END delete_patient_record;
/
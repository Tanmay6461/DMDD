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
    


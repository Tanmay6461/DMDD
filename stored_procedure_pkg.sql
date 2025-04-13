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


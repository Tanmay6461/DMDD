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

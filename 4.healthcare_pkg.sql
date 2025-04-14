CREATE OR REPLACE PACKAGE healthcare_pkg AS
    -- Register a new patient
    PROCEDURE register_patient(
        p_patient_id IN INTEGER,
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_doctor_id IN INTEGER,
        p_street_name IN VARCHAR2,
        p_city IN VARCHAR2,
        p_state IN VARCHAR2
    );
    
    -- Add medical record
    PROCEDURE add_medical_record(
        p_patient_id IN INTEGER,
        p_doctor_id IN INTEGER,
        p_symptoms IN VARCHAR2,
        p_diagnosis IN VARCHAR2,
        p_drug_id IN INTEGER
    );
    
    -- Order diagnostic test
    PROCEDURE order_diagnostic_test(
        p_patient_id IN INTEGER,
        p_diagnostic_id IN INTEGER,
        p_test_result IN VARCHAR2
    );
    
END healthcare_pkg;
/
create or replace PACKAGE healthcare_exceptions AS

    -- Error codes
    patient_not_found_code CONSTANT NUMBER := -20001;
    doctor_not_found_code CONSTANT NUMBER := -20002;
    drug_not_found_code CONSTANT NUMBER := -20003;
    diagnostic_not_found_code CONSTANT NUMBER := -20004;
    patient_exists_code CONSTANT NUMBER := -20005;
    null_parameter_code CONSTANT NUMBER := -20006;

END healthcare_exceptions;

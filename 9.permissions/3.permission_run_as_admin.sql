

GRANT CREATE SESSION TO admin_user, doctor_user, billing_user, patient_user;

-- Assign roles to users
GRANT HEALTHCARE_ADMIN TO admin_user;
GRANT HEALTHCARE_DOCTOR TO doctor_user;
GRANT HEALTHCARE_BILLING TO billing_user;
GRANT HEALTHCARE_PATIENT TO patient_user;

-- Simpler re-runnable script for healthcare roles and users

-- Drop roles if they exist (ignoring errors if they don't)
BEGIN
  EXECUTE IMMEDIATE 'DROP ROLE HEALTHCARE_ADMIN';
  EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP ROLE HEALTHCARE_DOCTOR';
  EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP ROLE HEALTHCARE_PATIENT';
  EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP ROLE HEALTHCARE_BILLING';
  EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Drop users if they exist (ignoring errors if they don't)
BEGIN
  EXECUTE IMMEDIATE 'DROP USER admin_user CASCADE';
  EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP USER doctor_user CASCADE';
  EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP USER billing_user CASCADE';
  EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP USER patient_user CASCADE';
  EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Create essential roles
CREATE ROLE HEALTHCARE_ADMIN;
CREATE ROLE HEALTHCARE_DOCTOR;
CREATE ROLE HEALTHCARE_PATIENT;
CREATE ROLE HEALTHCARE_BILLING;

-- HEALTHCARE_ADMIN role (full access to all tables)
GRANT ALL ON Doctor_Details TO HEALTHCARE_ADMIN;
GRANT ALL ON Patient TO HEALTHCARE_ADMIN;
GRANT ALL ON Patient_Address TO HEALTHCARE_ADMIN;
GRANT ALL ON Medical_History TO HEALTHCARE_ADMIN;
GRANT ALL ON Drug_Details TO HEALTHCARE_ADMIN;
GRANT ALL ON Medication_Information TO HEALTHCARE_ADMIN;
GRANT ALL ON Diagnostic_Test TO HEALTHCARE_ADMIN;
GRANT ALL ON Prescribed_Diagnostics TO HEALTHCARE_ADMIN;
GRANT EXECUTE ON healthcare_pkg TO HEALTHCARE_ADMIN;
GRANT EXECUTE ON healthcare_exceptions TO HEALTHCARE_ADMIN;

-- HEALTHCARE_DOCTOR role
GRANT SELECT ON Doctor_Details TO HEALTHCARE_DOCTOR;
GRANT SELECT, INSERT, UPDATE ON Patient TO HEALTHCARE_DOCTOR;
GRANT SELECT, INSERT, UPDATE ON Patient_Address TO HEALTHCARE_DOCTOR;
GRANT SELECT, INSERT, UPDATE ON Medical_History TO HEALTHCARE_DOCTOR;
GRANT SELECT ON Drug_Details TO HEALTHCARE_DOCTOR;
GRANT SELECT, INSERT, UPDATE ON Medication_Information TO HEALTHCARE_DOCTOR;
GRANT SELECT ON Diagnostic_Test TO HEALTHCARE_DOCTOR;
GRANT SELECT, INSERT, UPDATE ON Prescribed_Diagnostics TO HEALTHCARE_DOCTOR;
GRANT EXECUTE ON healthcare_pkg TO HEALTHCARE_DOCTOR;


-- Grant object privileges to HEALTHCARE_BILLING role
GRANT SELECT ON Patient TO HEALTHCARE_BILLING;
GRANT SELECT ON Patient_Address TO HEALTHCARE_BILLING;
GRANT SELECT ON Medication_Information TO HEALTHCARE_BILLING;
GRANT SELECT ON Drug_Details TO HEALTHCARE_BILLING;
GRANT SELECT ON Prescribed_Diagnostics TO HEALTHCARE_BILLING;
GRANT SELECT ON Diagnostic_Test TO HEALTHCARE_BILLING;
GRANT EXECUTE ON get_patient_bill TO HEALTHCARE_BILLING;


-- HEALTHCARE_PATIENT role (very limited access)
GRANT SELECT ON Patient_Medical_Summary TO HEALTHCARE_PATIENT;
GRANT SELECT ON Patient_Billing_Summary TO HEALTHCARE_PATIENT;

---- Create users with proper privileges
CREATE USER admin_user IDENTIFIED BY "Admin_Pwd123";
CREATE USER doctor_user IDENTIFIED BY "Doctor_Pwd123";
CREATE USER billing_user IDENTIFIED BY "Billing_Pwd123";
CREATE USER patient_user IDENTIFIED BY "Patient_Pwd123";

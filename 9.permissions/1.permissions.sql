
-- Execute as OMS (after running OMS-tables.sql and creating packages)


-- Grant permissions to OMS_APP_USER
GRANT SELECT, INSERT, UPDATE ON Patient TO OMS_APP_USER;
GRANT SELECT, INSERT, UPDATE ON Patient_Address TO OMS_APP_USER;
GRANT SELECT ON Doctor_Details TO OMS_APP_USER;
GRANT SELECT ON Drug_Details TO OMS_APP_USER;
GRANT SELECT ON Diagnostic_Test TO OMS_APP_USER;
GRANT SELECT, INSERT ON Medical_History TO OMS_APP_USER;
GRANT SELECT, INSERT ON Medication_Information TO OMS_APP_USER;
GRANT SELECT, INSERT ON Prescribed_Diagnostics TO OMS_APP_USER;

-- Grant execute on package(s)
GRANT EXECUTE ON healthcare_pkg TO OMS_APP_USER;

-- Grant select on views
GRANT SELECT ON Patient_Medical_Summary TO OMS_APP_USER;
GRANT SELECT ON Doctor_Performance TO OMS_APP_USER;
GRANT SELECT ON Drug_Utilization TO OMS_APP_USER;
GRANT SELECT ON Patient_Billing_Summary TO OMS_APP_USER;
GRANT SELECT ON Diagnostic_Test_Analysis TO OMS_APP_USER;


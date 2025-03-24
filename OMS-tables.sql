-- doctor details
CREATE TABLE IF NOT EXISTS Doctor_Details (
    doctor_id VARCHAR2(50) PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    specialization VARCHAR2(50)
);

CREATE TABLE IF NOT EXISTS Prescribed_Diagnostics (
    diagnostic_test_id VARCHAR2(50),
    date_administered DATE NOT NULL,
    test_result VARCHAR2(100),
    nurse_id VARCHAR2(50),
    patient_id VARCHAR2(50),
    PRIMARY KEY (diagnostic_test_id, patient_id),
    CONSTRAINT fk_prescribed_diagnostics_patient FOREIGN KEY (patient_id) REFERENCES Patient_Records (patient_id),
    CONSTRAINT fk_prescribed_diagnostics_test FOREIGN KEY (diagnostic_test_id) REFERENCES Diagnostic_Test (diagnostic_id)
);

--2. View: Medication Administered
CREATE VIEW IF NOT EXISTS Diagnostic_Tests_Prescribed AS
SELECT 
    pd.diagnostic_test_id,
    dt.test_name,
    dt.test_charge,
    pd.date_administered,
    pd.test_result,
    p.first_name || ' ' || p.last_name AS patient_name
FROM 
    Prescribed_Diagnostics pd
JOIN 
    Diagnostic_Test dt ON pd.diagnostic_test_id = dt.diagnostic_id
JOIN 
    Patient_Records p ON pd.patient_id = p.patient_id;
-- Patient Details

CREATE TABLE IF NOT EXISTS Patient (
    patient_id INTEGER PRIMARY KEY,
    first_name VARCHAR2(150) NOT NULL,
    last_name VARCHAR2(150) NOT NULL,
    doctor_id INTEGER NOT NULL,
    CONSTRAINT Patient_Doctor_FK FOREIGN KEY (doctor_id) REFERENCES Doctor_Details (doctor_id)
);



-- doctor details
CREATE TABLE IF NOT EXISTS Doctor_Details (
    doctor_id INTEGER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    specialization VARCHAR2(50)
);


-- Patient address
CREATE TABLE IF NOT EXISTS Patient_Address (
    address_id INTEGER PRIMARY KEY,
    street_name VARCHAR2(100),
    city VARCHAR2(50),
    state VARCHAR2(20),
    patient_id INTEGER NOT NULL,
    CONSTRAINT Patient_Address_FK FOREIGN KEY (patient_id) REFERENCES Patient (patient_id)
);

--Medical history
CREATE TABLE IF NOT EXISTS Medical_History (
    patient_history_id INTEGER PRIMARY KEY,
    symptoms VARCHAR(150),
    diagnosis VARCHAR(150),
    date_detected DATE,
    patient_id INTEGER NOT NULL,
    CONSTRAINT Medical_History_Patient_FK FOREIGN KEY (patient_id) REFERENCES Patient (patient_id)
);

--Drug details
CREATE TABLE IF NOT EXISTS Drug_Details (
    drug_id INTEGER PRIMARY KEY,
    drug_name VARCHAR2(50),
    drug_price FLOAT
);


--Medication Information

CREATE TABLE IF NOT EXISTS Medication_Information (
    prescription_id INTEGER PRIMARY KEY,
    date_administered DATE NOT NULL,
    patient_id INTEGER NOT NULL,
    doctor_id INTEGER NOT NULL,
    drug_id INTEGER NOT NULL,
    CONSTRAINT Medication_Information_Patient_FK FOREIGN KEY (patient_id) REFERENCES Patient (patient_id),
    CONSTRAINT Medication_Information_Doctor_FK FOREIGN KEY (doctor_id) REFERENCES Doctor_Details (doctor_id),
    CONSTRAINT Medication_Information_Drug_FK FOREIGN KEY (drug_id) REFERENCES Drug_Details (drug_id)
);


--Diagnostic Test

CREATE TABLE IF NOT EXISTS Diagnostic_Test (
    diagnostic_id INTEGER PRIMARY KEY,
    test_name VARCHAR2(50),
    test_charge FLOAT CHECK(test_charge > 0)
);

--Prescribed Diagnostics

CREATE TABLE IF NOT EXISTS Prescribed_Diagnostics (
    prescribed_diagnostics_id INTEGER PRIMARY KEY,
    date_administered DATE NOT NULL,
    test_result VARCHAR2(100),
    patient_id INTEGER NOT NULL,
    diagnostic_test_id INTEGER NOT NULL,
    CONSTRAINT Prescribed_Diagnostics_Patient_FK FOREIGN KEY (patient_id) REFERENCES Patient (patient_id),
    CONSTRAINT Prescribed_Diagnostics_Test_FK FOREIGN KEY (diagnostic_test_id) REFERENCES Diagnostic_Test (diagnostic_id)
);


-- View's

-- 1. View: Current Patient Status
CREATE VIEW IF NOT EXISTS Current_Patient_Status AS
SELECT 
    p.patient_id, 
    p.first_name || ' ' || p.last_name AS patient_name, 
    d.first_name || ' ' || d.last_name AS doctor_name, 
    d.specialization AS doctor_specialization, 
    a.street_name || ', ' || a.city || ', ' || a.state AS address
FROM 
    Patient p
JOIN 
    Doctor_Details d ON p.doctor_id = d.doctor_id
LEFT JOIN 
    Patient_Address a ON p.patient_id = a.patient_id;


--2. View: Medication Administered
CREATE VIEW IF NOT EXISTS Diagnostic_Tests_Prescribed AS
SELECT 
    pd.prescribed_diagnostics_id, 
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
    Patient p ON pd.patient_id = p.patient_id;


--3. 
CREATE VIEW IF NOT EXISTS Total_Diagnostic_Charges_Per_Patient AS
SELECT 
    p.patient_id, 
    p.first_name || ' ' || p.last_name AS patient_name, 
    SUM(dt.test_charge) AS total_charges
FROM 
    Prescribed_Diagnostics pd
JOIN 
    Diagnostic_Test dt ON pd.diagnostic_test_id = dt.diagnostic_id
JOIN 
    Patient p ON pd.patient_id = p.patient_id
GROUP BY 
    p.patient_id, p.first_name, p.last_name;



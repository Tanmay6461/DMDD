-- Patient Details
CREATE TABLE IF NOT EXISTS Patient_Records (

    patient_id VARCHAR2(50) PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    doctor_id VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_patient_doctor FOREIGN KEY (doctor_id) REFERENCES Doctor_Details (doctor_id)
);

-- doctor details
CREATE TABLE IF NOT EXISTS Doctor_Details (
    doctor_id VARCHAR2(50) PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    specialization VARCHAR2(50)
);

-- Patient address
CREATE TABLE IF NOT EXISTS Patient_Address (
    address_id VARCHAR2(50) PRIMARY KEY,
    street_name VARCHAR2(100),
    city VARCHAR2(50),
    state VARCHAR2(50),
    patient_id VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_patient_address FOREIGN KEY (patient_id) REFERENCES Patient_Records (patient_id)
);


CREATE TABLE IF NOT EXISTS Medication_Information (
    prescription_id VARCHAR2(50) PRIMARY KEY,
    medicine_name VARCHAR2(100),
    medicine_composition VARCHAR2(150),
    date_administered DATE NOT NULL,
    patient_id VARCHAR2(50) NOT NULL,
    nurse_id VARCHAR2(50),
    CONSTRAINT fk_medication_patient FOREIGN KEY (patient_id) REFERENCES Patient_Records (patient_id)
);



CREATE TABLE IF NOT EXISTS Diagnostic_Test (
    diagnostic_id VARCHAR2(50) PRIMARY KEY,
    test_name VARCHAR2(50),
    test_charge FLOAT CHECK(test_charge > 0)
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

-- View's

-- 1. View: Current Patient Status
CREATE VIEW IF NOT EXISTS Current_Patient_Details AS
SELECT 
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    d.first_name || ' ' || d.last_name AS doctor_name,
    d.specialization AS doctor_specialization,
    a.street_name || ', ' || a.city || ', ' || a.state AS address
FROM 
    Patient_Records p
JOIN 
    Doctor_Details d ON p.doctor_id = d.doctor_id
LEFT JOIN 
    Patient_Address a ON p.patient_id = a.patient_id;


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
    Patient_Records p ON pd.patient_id = p.patient_id
GROUP BY 
    p.patient_id, p.first_name, p.last_name;
    
    
INSERT INTO Patient_Records (patient_id, first_name, last_name, doctor_id) VALUES 
('P001', 'Alice', 'Green', 'D001'),
('P002', 'Bob', 'White', 'D002'),
('P003', 'Charlie', 'Black', 'D003'),
('P004', 'Diana', 'Blue', 'D004'),
('P005', 'Eve', 'Gray', 'D005');


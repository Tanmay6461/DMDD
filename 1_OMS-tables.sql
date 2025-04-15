-- Drop tables if they exist
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Prescribed_Diagnostics CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Doctor_Details CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Medication_Information CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Patient CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Patient_Address CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Medical_History CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Drug_Details CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE Diagnostic_Test CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Ignore errors if tables do not exist
END;
/

-- Doctor details
CREATE TABLE Doctor_Details (
    doctor_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    specialization VARCHAR2(50)
);

-- Patient details
CREATE TABLE Patient (
    patient_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    address_id INTEGER ,
    first_name VARCHAR2(150) NOT NULL,
    last_name VARCHAR2(150) NOT NULL
    );

-- Patient address
CREATE TABLE Patient_Address (
    address_id INTEGER PRIMARY KEY,
    street_name VARCHAR2(100),
    city VARCHAR2(50),
    state VARCHAR2(20),
    patient_id INTEGER NOT NULL,
    CONSTRAINT Patient_Address_FK FOREIGN KEY (patient_id) REFERENCES Patient (patient_id)
);

-- Medical history
CREATE TABLE Medical_History (
    patient_history_id INTEGER PRIMARY KEY,
    symptoms VARCHAR2(150),
    diagnosis VARCHAR2(150),
    date_detected DATE,
    patient_id INTEGER NOT NULL,
    CONSTRAINT Medical_History_Patient_FK FOREIGN KEY (patient_id) REFERENCES Patient (patient_id)
);

-- Drug details
CREATE TABLE Drug_Details (
    drug_id INTEGER PRIMARY KEY,
    drug_name VARCHAR2(50),
    drug_price NUMBER
);

-- Medication information
CREATE TABLE Medication_Information (
    prescription_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date_administered DATE NOT NULL,
    patient_id INTEGER NOT NULL,
    doctor_id INTEGER NOT NULL,
    drug_id INTEGER NOT NULL,
    CONSTRAINT Medication_Information_Patient_FK FOREIGN KEY (patient_id) REFERENCES Patient (patient_id),
    CONSTRAINT Medication_Information_Doctor_FK FOREIGN KEY (doctor_id) REFERENCES Doctor_Details (doctor_id),
    CONSTRAINT Medication_Information_Drug_FK FOREIGN KEY (drug_id) REFERENCES Drug_Details (drug_id)
);


-- Diagnostic test
CREATE TABLE Diagnostic_Test (
    diagnostic_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    test_name VARCHAR2(50),
    test_charge NUMBER CHECK(test_charge > 0)
);

-- Prescribed diagnostics
CREATE TABLE Prescribed_Diagnostics (
    prescribed_diagnostics_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date_administered DATE NOT NULL,
    test_result VARCHAR2(100),
    patient_id INTEGER NOT NULL,
    diagnostic_test_id INTEGER NOT NULL,
    CONSTRAINT Prescribed_Diagnostics_Patient_FK FOREIGN KEY (patient_id) REFERENCES Patient (patient_id),
    CONSTRAINT Prescribed_Diagnostics_Test_FK FOREIGN KEY (diagnostic_test_id) REFERENCES Diagnostic_Test (diagnostic_id)
);


-- Insert into Doctor_Details
INSERT INTO Doctor_Details (first_name, last_name, specialization) 
VALUES ('John', 'Smith', 'Cardiology');

INSERT INTO Doctor_Details (first_name, last_name, specialization) 
VALUES ('Sarah', 'Johnson', 'Neurology');

INSERT INTO Doctor_Details (first_name, last_name, specialization) 
VALUES ('Michael', 'Brown', 'Orthopedics');

-- Insert into Patient
INSERT INTO Patient (first_name, last_name) 
VALUES ('Robert', 'Williams');

INSERT INTO Patient (first_name, last_name) 
VALUES ('Emily', 'Davis');

INSERT INTO Patient (first_name, last_name) 
VALUES ('James', 'Miller');

-- Insert into Patient_Address (need to get patient_id values first)
INSERT INTO Patient_Address (address_id, street_name, city, state, patient_id) 
VALUES (1, '123 Main St', 'New York', 'NY', 1);

INSERT INTO Patient_Address (address_id, street_name, city, state, patient_id) 
VALUES (2, '456 Oak Ave', 'Los Angeles', 'CA', 2);

INSERT INTO Patient_Address (address_id, street_name, city, state, patient_id) 
VALUES (3, '789 Pine Rd', 'Chicago', 'IL', 3);

-- Update patient records with address_id
UPDATE Patient SET address_id = 1 WHERE patient_id = 1;
UPDATE Patient SET address_id = 2 WHERE patient_id = 2;
UPDATE Patient SET address_id = 3 WHERE patient_id = 3;

-- Insert into Medical_History
INSERT INTO Medical_History (patient_history_id, symptoms, diagnosis, date_detected, patient_id) 
VALUES (1, 'Chest pain, shortness of breath', 'Hypertension', TO_DATE('2024-01-15', 'YYYY-MM-DD'), 1);

INSERT INTO Medical_History (patient_history_id, symptoms, diagnosis, date_detected, patient_id) 
VALUES (2, 'Severe headache, nausea', 'Migraine', TO_DATE('2024-02-10', 'YYYY-MM-DD'), 2);

INSERT INTO Medical_History (patient_history_id, symptoms, diagnosis, date_detected, patient_id) 
VALUES (3, 'Joint pain, swelling', 'Arthritis', TO_DATE('2024-03-05', 'YYYY-MM-DD'), 3);

-- Insert into Drug_Details
INSERT INTO Drug_Details (drug_id, drug_name, drug_price) 
VALUES (1, 'Lisinopril', 25.50);

INSERT INTO Drug_Details (drug_id, drug_name, drug_price) 
VALUES (2, 'Sumatriptan', 85.75);

INSERT INTO Drug_Details (drug_id, drug_name, drug_price) 
VALUES (3, 'Ibuprofen', 12.99);

-- Insert into Medication_Information
INSERT INTO Medication_Information (date_administered, patient_id, doctor_id, drug_id) 
VALUES (TO_DATE('2024-01-16', 'YYYY-MM-DD'), 1, 1, 1);

INSERT INTO Medication_Information (date_administered, patient_id, doctor_id, drug_id) 
VALUES (TO_DATE('2024-02-11', 'YYYY-MM-DD'), 2, 2, 2);

INSERT INTO Medication_Information (date_administered, patient_id, doctor_id, drug_id) 
VALUES (TO_DATE('2024-03-06', 'YYYY-MM-DD'), 3, 3, 3);

-- Insert into Diagnostic_Test
INSERT INTO Diagnostic_Test (test_name, test_charge) 
VALUES ('Complete Blood Count', 45.00);

INSERT INTO Diagnostic_Test (test_name, test_charge) 
VALUES ('MRI Brain Scan', 1200.00);

INSERT INTO Diagnostic_Test (test_name, test_charge) 
VALUES ('X-Ray Joint', 175.00);

-- Insert into Prescribed_Diagnostics
INSERT INTO Prescribed_Diagnostics (date_administered, test_result, patient_id, diagnostic_test_id) 
VALUES (TO_DATE('2024-01-17', 'YYYY-MM-DD'), 'Elevated white blood cell count', 1, 1);

INSERT INTO Prescribed_Diagnostics (date_administered, test_result, patient_id, diagnostic_test_id) 
VALUES (TO_DATE('2024-02-12', 'YYYY-MM-DD'), 'No abnormalities detected', 2, 2);

INSERT INTO Prescribed_Diagnostics (date_administered, test_result, patient_id, diagnostic_test_id) 
VALUES (TO_DATE('2024-03-07', 'YYYY-MM-DD'), 'Mild joint inflammation', 3, 3);
COMMIT;

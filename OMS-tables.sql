

-- Patient Details
CREATE TABLE Patient_Records (
    patient_id VARCHAR2(50) PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    doctor_id VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_patient_doctor FOREIGN KEY (doctor_id) REFERENCES Doctor_Details (doctor_id));
    
    
CREATE TABLE Medication_Information (
    prescription_id VARCHAR2(50) PRIMARY KEY,
    medicine_name VARCHAR2(100),
    medicine_composition VARCHAR2(150),
    date_administered DATE NOT NULL,
    patient_id VARCHAR2(50) NOT NULL,
    nurse_id VARCHAR2(50),
    CONSTRAINT fk_medication_patient FOREIGN KEY (patient_id) REFERENCES Patient_Records (patient_id));
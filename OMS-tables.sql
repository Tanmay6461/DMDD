

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
    CONSTRAINT fk_medication_patient FOREIGN KEY (patient_id) REFERENCES Patient_Records (patient_id)
);

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
    
INSERT INTO Doctor_Details (doctor_id, first_name, last_name, specialization) VALUES 
('D001', 'John', 'Doe', 'Cardiology'),
('D002', 'Jane', 'Smith', 'Neurology'),
('D003', 'Emily', 'Clark', 'Pediatrics'),
('D004', 'Michael', 'Brown', 'Orthopedics'),
('D005', 'Sarah', 'Johnson', 'Dermatology');
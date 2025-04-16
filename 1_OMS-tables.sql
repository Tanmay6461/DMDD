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
            street_name VARCHAR2(100) NOT NULL,
            city VARCHAR2(50) NOT NULL,
            state VARCHAR2(20) NOT NUlL
        );
        
        
        -- Medical history
        CREATE TABLE Medical_History (
            patient_history_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
            symptoms VARCHAR2(150) NOT NULL,
            diagnosis VARCHAR2(150) NOT NULL,
            date_detected DATE,
            patient_id INTEGER NOT NULL,
            CONSTRAINT Medical_History_Patient_FK FOREIGN KEY (patient_id) REFERENCES Patient (patient_id)
        );
        
        -- Drug details
        CREATE TABLE Drug_Details (
            drug_id INTEGER PRIMARY KEY,
            drug_name VARCHAR2(50) NOT NULL,
            drug_price NUMBER NOT NULL,
            CONSTRAINT chk_drug_price CHECK (drug_price > 0)
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
        
        
        
        CREATE OR REPLACE TRIGGER trg_medical_history_date
        BEFORE INSERT OR UPDATE ON Medical_History
        FOR EACH ROW
        BEGIN
            IF :NEW.date_detected > SYSDATE THEN
                RAISE_APPLICATION_ERROR(-20007, 'Date detected cannot be in the future');
            END IF;
        END;
        /
        
        
        -- Insert into Doctor_Details
        INSERT INTO Doctor_Details (first_name, last_name, specialization) 
        VALUES ('John', 'Smith', 'Cardiology');
        
        INSERT INTO Doctor_Details (first_name, last_name, specialization) 
        VALUES ('Sarah', 'Johnson', 'Neurology');
        
        INSERT INTO Doctor_Details (first_name, last_name, specialization) 
        VALUES ('Michael', 'Brown', 'Orthopedics');
        
        INSERT INTO Doctor_Details (first_name, last_name, specialization) 
        VALUES ('Elizabeth', 'Taylor', 'Dermatology');
        
        INSERT INTO Doctor_Details (first_name, last_name, specialization) 
        VALUES ('David', 'Wilson', 'Pediatrics');
        
        -- Insert into Patient_Address first
        INSERT INTO Patient_Address (address_id, street_name, city, state) 
        VALUES (1, '123 Main St', 'New York', 'NY');
        
        INSERT INTO Patient_Address (address_id, street_name, city, state) 
        VALUES (2, '456 Oak Ave', 'Los Angeles', 'CA');
        
        INSERT INTO Patient_Address (address_id, street_name, city, state) 
        VALUES (3, '789 Pine Rd', 'Chicago', 'IL');
        
        INSERT INTO Patient_Address (address_id, street_name, city, state) 
        VALUES (4, '101 Cedar Blvd', 'Houston', 'TX');
        
        INSERT INTO Patient_Address (address_id, street_name, city, state) 
        VALUES (5, '202 Maple Dr', 'Seattle', 'WA');
        
        -- Insert into Patient with address_id
        INSERT INTO Patient (first_name, last_name, address_id) 
        VALUES ('Robert', 'Williams', 1);
        
        INSERT INTO Patient (first_name, last_name, address_id) 
        VALUES ('Emily', 'Davis', 2);
        
        INSERT INTO Patient (first_name, last_name, address_id) 
        VALUES ('James', 'Miller', 3);
        
        INSERT INTO Patient (first_name, last_name, address_id) 
        VALUES ('Maria', 'Rodriguez', 4);
        
        INSERT INTO Patient (first_name, last_name, address_id) 
        VALUES ('Daniel', 'Chen', 5);
        
        -- Insert into Drug_Details
        INSERT INTO Drug_Details (drug_id, drug_name, drug_price) 
        VALUES (1, 'Lisinopril', 25.50);
        
        INSERT INTO Drug_Details (drug_id, drug_name, drug_price) 
        VALUES (2, 'Sumatriptan', 85.75);
        
        INSERT INTO Drug_Details (drug_id, drug_name, drug_price) 
        VALUES (3, 'Ibuprofen', 12.99);
        
        INSERT INTO Drug_Details (drug_id, drug_name, drug_price) 
        VALUES (4, 'Amoxicillin', 18.25);
        
        INSERT INTO Drug_Details (drug_id, drug_name, drug_price) 
        VALUES (5, 'Prednisone', 9.99);
        
        -- Insert into Medical_History (with dates in the past)
        INSERT INTO Medical_History (symptoms, diagnosis, date_detected, patient_id) 
        VALUES ('Chest pain, shortness of breath', 'Hypertension', TO_DATE('2024-01-15', 'YYYY-MM-DD'), 1);
        
        INSERT INTO Medical_History (symptoms, diagnosis, date_detected, patient_id) 
        VALUES ('Severe headache, nausea', 'Migraine', TO_DATE('2024-02-10', 'YYYY-MM-DD'), 2);
        
        INSERT INTO Medical_History (symptoms, diagnosis, date_detected, patient_id) 
        VALUES ('Joint pain, swelling', 'Arthritis', TO_DATE('2024-03-05', 'YYYY-MM-DD'), 3);
        
        INSERT INTO Medical_History (symptoms, diagnosis, date_detected, patient_id) 
        VALUES ('Itchy rash, redness', 'Eczema', TO_DATE('2024-03-20', 'YYYY-MM-DD'), 4);
        
        --INSERT INTO Medical_History (symptoms, diagnosis, date_detected, patient_id) 
        --VALUES ('Fever, sore throat', 'Strep throat', TO_DATE('2024-04-01', 'YYYY-MM-DD'), 5);
        
        -- Insert into Diagnostic_Test
        INSERT INTO Diagnostic_Test (test_name, test_charge) 
        VALUES ('Complete Blood Count', 45.00);
        
        INSERT INTO Diagnostic_Test (test_name, test_charge) 
        VALUES ('MRI Brain Scan', 1200.00);
        
        INSERT INTO Diagnostic_Test (test_name, test_charge) 
        VALUES ('X-Ray Joint', 175.00);
        
        INSERT INTO Diagnostic_Test (test_name, test_charge) 
        VALUES ('Skin Biopsy', 350.00);
        
        INSERT INTO Diagnostic_Test (test_name, test_charge) 
        VALUES ('Throat Culture', 65.00);
        
        -- Insert into Medication_Information
        INSERT INTO Medication_Information (date_administered, patient_id, doctor_id, drug_id) 
        VALUES (TO_DATE('2024-01-16', 'YYYY-MM-DD'), 1, 1, 1);
        
        INSERT INTO Medication_Information (date_administered, patient_id, doctor_id, drug_id) 
        VALUES (TO_DATE('2024-02-11', 'YYYY-MM-DD'), 2, 2, 2);
        
        INSERT INTO Medication_Information (date_administered, patient_id, doctor_id, drug_id) 
        VALUES (TO_DATE('2024-03-06', 'YYYY-MM-DD'), 3, 3, 3);
        
        INSERT INTO Medication_Information (date_administered, patient_id, doctor_id, drug_id) 
        VALUES (TO_DATE('2024-03-21', 'YYYY-MM-DD'), 4, 4, 5);
        
        INSERT INTO Medication_Information (date_administered, patient_id, doctor_id, drug_id) 
        VALUES (TO_DATE('2024-04-02', 'YYYY-MM-DD'), 5, 5, 4);
        
        -- Insert into Prescribed_Diagnostics
        INSERT INTO Prescribed_Diagnostics (date_administered, test_result, patient_id, diagnostic_test_id) 
        VALUES (TO_DATE('2024-01-17', 'YYYY-MM-DD'), 'Elevated white blood cell count', 1, 1);
        
        INSERT INTO Prescribed_Diagnostics (date_administered, test_result, patient_id, diagnostic_test_id) 
        VALUES (TO_DATE('2024-02-12', 'YYYY-MM-DD'), 'No abnormalities detected', 2, 2);
        
        INSERT INTO Prescribed_Diagnostics (date_administered, test_result, patient_id, diagnostic_test_id) 
        VALUES (TO_DATE('2024-03-07', 'YYYY-MM-DD'), 'Mild joint inflammation', 3, 3);
        
        INSERT INTO Prescribed_Diagnostics (date_administered, test_result, patient_id, diagnostic_test_id) 
        VALUES (TO_DATE('2024-03-22', 'YYYY-MM-DD'), 'Eczema confirmed', 4, 4);
        
        INSERT INTO Prescribed_Diagnostics (date_administered, test_result, patient_id, diagnostic_test_id) 
        VALUES (TO_DATE('2024-04-03', 'YYYY-MM-DD'), 'Positive for strep bacteria', 5, 5);
        
        COMMIT;

-- Test Case Setup: Create sample data
-- Insert Doctor records
INSERT INTO Doctor_Details VALUES (11, 'John', 'Smith', 'Cardiologist');
INSERT INTO Doctor_Details VALUES (2, 'Jane', 'Doe', 'Neurologist');
INSERT INTO Doctor_Details VALUES (3, 'Michael', 'Johnson', 'Pediatrician');

INSERT INTO OMS.PATIENT  VALUES (121, 'Aspirin', 'DASDAS', 1);

-- Insert Drug records
INSERT INTO Drug_Details VALUES (101, 'Aspirin', 9.99);
INSERT INTO Drug_Details VALUES (102, 'Lisinopril', 24.99);
INSERT INTO Drug_Details VALUES (103, 'Amoxicillin', 14.99);

-- Insert Diagnostic Test records
INSERT INTO Diagnostic_Test VALUES (201, 'Blood Test', 45.00);
INSERT INTO Diagnostic_Test VALUES (202, 'X-Ray', 120.00);
INSERT INTO Diagnostic_Test VALUES (203, 'MRI', 350.00);

COMMIT;



-- Begin Test Cases
SET SERVEROUTPUT ON;

-- Test Case 1: Register Patient - Success
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 1: Register Patient - Success');
    healthcare_pkg.register_patient(
        p_patient_id => 1001,
        p_first_name => 'Robert',
        p_last_name => 'Jones',
        p_doctor_id => 1,
        p_street_name => '123 Main St',
        p_city => 'Boston',
        p_state => 'MA'
    );
END;
/

-- Test Case 2: Register Patient - Invalid Doctor ID
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 2: Register Patient - Invalid Doctor ID');
    healthcare_pkg.register_patient(
        p_patient_id => 1002,
        p_first_name => 'Sarah',
        p_last_name => 'Williams',
        p_doctor_id => 999, -- Non-existent doctor
        p_street_name => '456 Oak Ave',
        p_city => 'Chicago',
        p_state => 'IL'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected Error: ' || SQLERRM);
END;
/

-- Test Case 3: Register Patient - NULL Parameters
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 3: Register Patient - NULL Parameters');
    healthcare_pkg.register_patient(
        p_patient_id => NULL,
        p_first_name => 'James',
        p_last_name => 'Brown',
        p_doctor_id => 2,
        p_street_name => '789 Pine St',
        p_city => 'Denver',
        p_state => 'CO'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected Error: ' || SQLERRM);
END;
/

-- Test Case 4: Register Patient - Name Too Long
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 4: Register Patient - Name Too Long');
    healthcare_pkg.register_patient(
        p_patient_id => 1003,
        p_first_name => RPAD('Elizabeth', 200, 'a'), -- More than 150 chars
        p_last_name => 'Wilson',
        p_doctor_id => 3,
        p_street_name => '101 Cedar St',
        p_city => 'Miami',
        p_state => 'FL'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected Error: ' || SQLERRM);
END;
/

-- Test Case 5: Register Patient - Duplicate Patient ID
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 5: Register Patient - Duplicate Patient ID');
    -- First insert a patient
    healthcare_pkg.register_patient(
        p_patient_id => 1004,
        p_first_name => 'Thomas',
        p_last_name => 'Davis',
        p_doctor_id => 2,
        p_street_name => '222 Maple Ave',
        p_city => 'Seattle',
        p_state => 'WA'
    );
    
    -- Try to insert the same patient ID again
    healthcare_pkg.register_patient(
        p_patient_id => 1004,
        p_first_name => 'William',
        p_last_name => 'Thompson',
        p_doctor_id => 1,
        p_street_name => '333 Elm St',
        p_city => 'Portland',
        p_state => 'OR'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected Error: ' || SQLERRM);
END;
/

-- Test Case 6: Add Medical Record - Success
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 6: Add Medical Record - Success');
    healthcare_pkg.add_medical_record(
        p_patient_id => 1001,
        p_doctor_id => 1,
        p_symptoms => 'Chest pain, shortness of breath',
        p_diagnosis => 'Hypertension',
        p_drug_id => 102
    );
END;
/

-- Test Case 7: Add Medical Record - Non-Existent Patient
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 7: Add Medical Record - Non-Existent Patient');
    healthcare_pkg.add_medical_record(
        p_patient_id => 9999, -- Non-existent patient
        p_doctor_id => 1,
        p_symptoms => 'Fever, cough',
        p_diagnosis => 'Common cold',
        p_drug_id => 103
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected Error: ' || SQLERRM);
END;
/

-- Test Case 8: Add Medical Record - Non-Existent Drug
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 8: Add Medical Record - Non-Existent Drug');
    healthcare_pkg.add_medical_record(
        p_patient_id => 1001,
        p_doctor_id => 1,
        p_symptoms => 'Headache, dizziness',
        p_diagnosis => 'Migraine',
        p_drug_id => 999 -- Non-existent drug
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected Error: ' || SQLERRM);
END;
/

-- Test Case 9: Add Medical Record - Text Too Long
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 9: Add Medical Record - Text Too Long');
    healthcare_pkg.add_medical_record(
        p_patient_id => 1001,
        p_doctor_id => 1,
        p_symptoms => RPAD('Symptoms', 200, 'a'), -- More than 150 chars
        p_diagnosis => 'Stress',
        p_drug_id => 101
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected Error: ' || SQLERRM);
END;
/

-- Test Case 10: Add Medical Record - Doctor Warning
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 10: Add Medical Record - Doctor Warning');
    -- Patient 1001 is assigned to doctor 1, but we're using doctor 2
    healthcare_pkg.add_medical_record(
        p_patient_id => 1001,
        p_doctor_id => 2, -- Different doctor than assigned
        p_symptoms => 'Joint pain',
        p_diagnosis => 'Arthritis',
        p_drug_id => 101
    );
END;
/

-- Test Case 11: Add Medical Record - Same Day Warning
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 11: Add Medical Record - Same Day Warning');
    -- First prescription
    healthcare_pkg.add_medical_record(
        p_patient_id => 1004,
        p_doctor_id => 2,
        p_symptoms => 'Fever',
        p_diagnosis => 'Infection',
        p_drug_id => 103
    );
    
    -- Same prescription on same day
    healthcare_pkg.add_medical_record(
        p_patient_id => 1004,
        p_doctor_id => 2,
        p_symptoms => 'Fever persisting',
        p_diagnosis => 'Bacterial infection',
        p_drug_id => 103
    );
END;
/

-- Test Case 12: Order Diagnostic Test - Success
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 12: Order Diagnostic Test - Success');
    healthcare_pkg.order_diagnostic_test(
        p_patient_id => 1001,
        p_diagnostic_id => 201,
        p_test_result => 'Normal'
    );
END;
/

-- Test Case 13: Order Diagnostic Test - Non-Existent Diagnostic
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 13: Order Diagnostic Test - Non-Existent Diagnostic');
    healthcare_pkg.order_diagnostic_test(
        p_patient_id => 1001,
        p_diagnostic_id => 999, -- Non-existent test
        p_test_result => 'Normal'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected Error: ' || SQLERRM);
END;
/

-- Test Case 14: Order Diagnostic Test - Result Too Long
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 14: Order Diagnostic Test - Result Too Long');
    healthcare_pkg.order_diagnostic_test(
        p_patient_id => 1001,
        p_diagnostic_id => 202,
        p_test_result => RPAD('Result', 150, 'a') -- More than 100 chars
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected Error: ' || SQLERRM);
END;
/

-- Test Case 15: Order Diagnostic Test - Duplicate Warning
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 15: Order Diagnostic Test - Duplicate Warning');
    -- First test
    healthcare_pkg.order_diagnostic_test(
        p_patient_id => 1004,
        p_diagnostic_id => 203,
        p_test_result => 'Normal brain scan'
    );
    
    -- Same test within 7 days
    healthcare_pkg.order_diagnostic_test(
        p_patient_id => 1004,
        p_diagnostic_id => 203,
        p_test_result => 'Follow-up scan'
    );
END;
/

SELECT * FROM PATIENT;

-- Test Case 16: Get Patient Bill - Success
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 16: Get Patient Bill - Success');
    -- Patient with both medications and diagnostic tests
    healthcare_pkg.get_patient_bill(
        p_patient_id => 1001
    );
END;
/

-- Test Case 17: Get Patient Bill - No Billable Records
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 17: Get Patient Bill - No Billable Records');
    -- Register a new patient with no medical records
    healthcare_pkg.register_patient(
        p_patient_id => 1005,
        p_first_name => 'Jennifer',
        p_last_name => 'Lee',
        p_doctor_id => 3,
        p_street_name => '444 Birch Ave',
        p_city => 'Austin',
        p_state => 'TX'
    );
    
    -- Try to generate bill
    healthcare_pkg.get_patient_bill(
        p_patient_id => 1005
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected Error: ' || SQLERRM);
END;
/

-- Test Case 18: Get Patient Bill - Non-Existent Patient
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 18: Get Patient Bill - Non-Existent Patient');
    healthcare_pkg.get_patient_bill(
        p_patient_id => 9999 -- Non-existent patient
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected Error: ' || SQLERRM);
END;
/

-- Test Case 19: Multiple Procedures - Full Workflow
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 19: Multiple Procedures - Full Workflow');
    
    -- Register patient
    healthcare_pkg.register_patient(
        p_patient_id => 1006,
        p_first_name => 'David',
        p_last_name => 'Clark',
        p_doctor_id => 1,
        p_street_name => '555 Walnut St',
        p_city => 'San Francisco',
        p_state => 'CA'
    );
    
    -- Add medical record
    healthcare_pkg.add_medical_record(
        p_patient_id => 1006,
        p_doctor_id => 1,
        p_symptoms => 'High blood pressure readings',
        p_diagnosis => 'Hypertension stage 1',
        p_drug_id => 102
    );
    
    -- Order diagnostic test
    healthcare_pkg.order_diagnostic_test(
        p_patient_id => 1006,
        p_diagnostic_id => 201,
        p_test_result => 'Elevated cholesterol'
    );
    
    -- Order additional diagnostic
    healthcare_pkg.order_diagnostic_test(
        p_patient_id => 1006,
        p_diagnostic_id => 202,
        p_test_result => 'Normal heart size'
    );
    
    -- Get bill
    healthcare_pkg.get_patient_bill(
        p_patient_id => 1006
    );
END;
/




-- Connect as doctor_user

SELECT * FROM OMS.Doctor_Details WHERE ROWNUM <= 5;
SELECT * FROM OMS.Patient WHERE ROWNUM <= 5;
SELECT * FROM OMS.Drug_Details WHERE ROWNUM <= 5;
 

INSERT INTO OMS.Patient (first_name, last_name) 
VALUES ('Doctor', 'Test');
ROLLBACK;
 
-- Test insert into restricted tables (should fail)
INSERT INTO OMS.Doctor_Details (first_name, last_name, specialization) 
VALUES ('Fail', 'Test', 'Unauthorized');

 
-- Test delete operation (should fail as doctors don't have DELETE privilege)
DELETE FROM OMS.Patient WHERE patient_id = 1;

 
-- Test package procedure execution (should succeed)
BEGIN
    healthcare_pkg.add_medical_record(
        p_patient_id => 1,
        p_doctor_id => 1,
        p_symptoms => 'Test symptoms',
        p_diagnosis => 'Test diagnosis',
        p_drug_id => 1
    );
END;
/
ROLLBACK;



-- Connect as admin_user


SELECT * FROM OMS.Doctor_Details WHERE ROWNUM <= 5;
SELECT * FROM OMS.Patient WHERE ROWNUM <= 5;
SELECT * FROM OMS.Medical_History WHERE ROWNUM <= 5;
SELECT * FROM OMS.Drug_Details WHERE ROWNUM <= 5;
 

INSERT INTO OMS.Doctor_Details (first_name, last_name, specialization) 
VALUES ('Admin', 'Test', 'Administration');
-- Then rollback to clean up
ROLLBACK;
 
-- Test package procedure execution 
BEGIN
    healthcare_pkg.display_patient_bill(1);
END;
/
 
-- Test view access 
SELECT * FROM OMS.Patient_Medical_Summary WHERE ROWNUM <= 5;
SELECT * FROM OMS.Doctor_Performance WHERE ROWNUM <= 5;
SELECT * FROM OMS.Drug_Utilization WHERE ROWNUM <= 5;


-- Connect as billing_user


SELECT * FROM OMS.Patient WHERE ROWNUM <= 5;
SELECT * FROM OMS.Drug_Details WHERE ROWNUM <= 5;
SELECT * FROM OMS.Prescribed_Diagnostics WHERE ROWNUM <= 5;
 

INSERT INTO Patient (first_name, last_name) 
VALUES ('Billing', 'Test');

 
UPDATE OMS.Drug_Details SET drug_price = drug_price * 1.1 WHERE drug_id = 1;

BEGIN
    get_patient_bill(1);
END;
/
 

BEGIN
    healthcare_pkg.register_patient(
        p_first_name => 'Billing',
        p_last_name => 'Test',
        p_street_name => 'Test St',
        p_city => 'TestCity',
        p_state => 'TS'
    );
END;
/



-- Connect as patient_user

 

SELECT * FROM OMS.Patient_Medical_Summary;
SELECT * FROM OMS.Patient_Billing_Summary;
 

SELECT * FROM OMS.Patient;

 
SELECT * FROM OMS.Medical_History;

 

BEGIN
    healthcare_pkg.display_patient_bill(1);
END;
/




-- Clean up test data (optional)
/*
BEGIN
 Application Express
   -- Delete test data in reverse order of dependencies
    DELETE FROM Prescribed_Diagnostics;
    DELETE FROM Medication_Information;
    DELETE FROM Medical_History;
    DELETE FROM Patient_Address;
    DELETE FROM Patient;
    DELETE FROM Diagnostic_Test;
    DELETE FROM Drug_Details;
    DELETE FROM Doctor_Details;
    COMMIT;
END;
/
*/	

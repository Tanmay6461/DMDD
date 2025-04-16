---- Test Case Setup: Create sample data
---- Insert Doctor records
--INSERT INTO Doctor_Details (first_name, last_name, specialization) 
--VALUES ('John', 'Smith', 'Cardiologist');
--
--INSERT INTO Doctor_Details (first_name, last_name, specialization) 
--VALUES ('Jane', 'Doe', 'Neurologist');
--
--INSERT INTO Doctor_Details (first_name, last_name, specialization) 
--VALUES ('Michael', 'Johnson', 'Pediatrician');
--
---- Insert Patient record (using first_name, last_name which are required)
--INSERT INTO Patient (first_name, last_name) 
--VALUES ('Aspirin', 'DASDAS');
--
---- Insert Drug records
--INSERT INTO Drug_Details (drug_id, drug_name, drug_price) 
--VALUES (101, 'Aspirin', 9.99);
--
--INSERT INTO Drug_Details (drug_id, drug_name, drug_price) 
--VALUES (102, 'Lisinopril', 24.99);
--
--INSERT INTO Drug_Details (drug_id, drug_name, drug_price) 
--VALUES (103, 'Amoxicillin', 14.99);
--
---- Insert Diagnostic Test records (using IDENTITY column)
--INSERT INTO Diagnostic_Test (test_name, test_charge) 
--VALUES ('Blood Test', 45.00);
--
--INSERT INTO Diagnostic_Test (test_name, test_charge) 
--VALUES ('X-Ray', 120.00);
--
--INSERT INTO Diagnostic_Test (test_name, test_charge) 
--VALUES ('MRI', 350.00);
--
--COMMIT;

-- Begin Test Cases
SET SERVEROUTPUT ON;


-- Test Case 1: Register a new patient (Success)
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 1: Register a new patient (Success)');
    healthcare_pkg.register_patient(
        p_first_name => 'Emma',
        p_last_name => 'Watson',
        p_street_name => '123 Movie St',
        p_city => 'Hollywood',
        p_state => 'CA'
    );
END;
/

-- Test Case the new patient update procedure
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 2: Update patient details (Success)');
    -- Get the latest patient ID
    DECLARE
        v_patient_id NUMBER;
    BEGIN
        SELECT MAX(patient_id) INTO v_patient_id FROM Patient;
        
        update_patient_details(
            p_patient_id => v_patient_id,
            p_first_name => 'Emma Updated',
            p_last_name => 'Watson Updated',
            p_city => 'Los Angeles',
            p_state => 'CA'
        );
    END;
END;
/

-- Test Case 3: Update non-existent patient
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 3: Update non-existent patient (Error)');
    update_patient_details(
        p_patient_id => 9999,
        p_first_name => 'Nobody',
        p_last_name => 'Nowhere',
        p_city => 'Ghost Town',
        p_state => 'ZZ'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected Error: ' || SQLERRM);
END;
/

-- Test Case 4: Update patient with NULL ID
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 4: Update patient with NULL ID (Error)');
    update_patient_details(
        p_patient_id => NULL,
        p_first_name => 'Null',
        p_last_name => 'Patient',
        p_city => 'Void',
        p_state => 'XX'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected Error: ' || SQLERRM);
END;
/

-- Test Case 5: Register patient without address
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 5: Register patient without address (Success)');
    healthcare_pkg.register_patient(
        p_first_name => 'Tom',
        p_last_name => 'Hardy',
        p_street_name => NULL,
        p_city => NULL,
        p_state => NULL
    );
END;
/

-- Test Case 6: Update patient without previous address to add one
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 6: Add address to patient without one (Success)');
    -- Get the latest patient ID (should be Tom Hardy)
    DECLARE
        v_patient_id NUMBER;
    BEGIN
        SELECT MAX(patient_id) INTO v_patient_id FROM Patient;
        
        update_patient_details(
            p_patient_id => v_patient_id,
            p_first_name => NULL, -- Don't change the name
            p_last_name => NULL,  -- Don't change the name
            p_city => 'London',
            p_state => 'UK'
        );
    END;
END;
/

-- Test Case 7: Add medical record to a patient
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 7: Add medical record (Success)');
    -- Get a valid patient ID and doctor ID
    DECLARE
        v_patient_id NUMBER;
        v_doctor_id NUMBER;
    BEGIN
        SELECT MIN(patient_id) INTO v_patient_id FROM Patient;
        SELECT MIN(doctor_id) INTO v_doctor_id FROM Doctor_Details;
        
        healthcare_pkg.add_medical_record(
            p_patient_id => v_patient_id,
            p_doctor_id => v_doctor_id,
            p_symptoms => 'Fever, headache',
            p_diagnosis => 'Common cold',
            p_drug_id => 101
        );
    END;
END;
/

-- Test Case 8: Order diagnostic test
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 8: Order diagnostic test (Success)');
    -- Get a valid patient ID and diagnostic test ID
    DECLARE
        v_patient_id NUMBER;
        v_diagnostic_id NUMBER;
    BEGIN
        SELECT MIN(patient_id) INTO v_patient_id FROM Patient;
        SELECT MIN(diagnostic_id) INTO v_diagnostic_id FROM Diagnostic_Test;
        
        healthcare_pkg.order_diagnostic_test(
            p_patient_id => v_patient_id,
            p_diagnostic_id => v_diagnostic_id,
            p_test_result => 'Normal results'
        );
    END;
END;
/


-- Test Case 9: Calculate and display patient expenses
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 9: Display patient bill (Success)');
    -- Get a patient ID with medical records
    DECLARE
        v_patient_id NUMBER;
    BEGIN
        SELECT patient_id INTO v_patient_id 
        FROM Medication_Information 
        WHERE ROWNUM = 1;
        
        healthcare_pkg.display_patient_bill(p_patient_id => v_patient_id);
    END;
END;
/

-- Test Case 10: Get total expenses using function
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 10: Get patient total expenses (Success)');
    -- Get a patient ID with medical records
    DECLARE
        v_patient_id NUMBER;
        v_total_expenses NUMBER;
    BEGIN
        SELECT patient_id INTO v_patient_id 
        FROM Medication_Information 
        WHERE ROWNUM = 1;
        
        v_total_expenses := get_patient_total_expenses(p_patient_id => v_patient_id);
        
        DBMS_OUTPUT.PUT_LINE('Patient ID: ' || v_patient_id);
        DBMS_OUTPUT.PUT_LINE('Total Expenses: $' || TO_CHAR(v_total_expenses, '999,999.99'));
    END;
END;
/

-- Test Case 11: Delete patient record
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 11: Delete patient record (Success)');
    -- First create a test patient
    healthcare_pkg.register_patient(
        p_first_name => 'Delete',
        p_last_name => 'Me',
        p_street_name => '999 Temp St',
        p_city => 'Temporary',
        p_state => 'TMP'
    );
    
    -- Get the ID of the new patient
    DECLARE
        v_patient_id NUMBER;
    BEGIN
        SELECT MAX(patient_id) INTO v_patient_id FROM Patient;
        
        -- Add a medical record for more deletion testing
        DECLARE
            v_doctor_id NUMBER;
        BEGIN
            SELECT MIN(doctor_id) INTO v_doctor_id FROM Doctor_Details;
            
            healthcare_pkg.add_medical_record(
                p_patient_id => v_patient_id,
                p_doctor_id => v_doctor_id,
                p_symptoms => 'Test symptoms',
                p_diagnosis => 'Test diagnosis',
                p_drug_id => 101
            );
        END;
        
        -- Now delete the patient
        delete_patient_record(p_patient_id => v_patient_id);
        
        -- Verify deletion
        DECLARE
            v_count NUMBER;
        BEGIN
            SELECT COUNT(*) INTO v_count FROM Patient WHERE patient_id = v_patient_id;
            DBMS_OUTPUT.PUT_LINE('Patient exists after deletion: ' || CASE WHEN v_count > 0 THEN 'Yes' ELSE 'No' END);
        END;
    END;
END;
/

-- Test Case 12: Delete non-existent patient
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 12: Delete non-existent patient (Error)');
    delete_patient_record(p_patient_id => 9999);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected Error: ' || SQLERRM);
END;
/

-- Test Case 13: End-to-end workflow
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 13: End-to-end workflow (Success)');
    
    -- 1. Register new patient
    healthcare_pkg.register_patient(
        p_first_name => 'Complete',
        p_last_name => 'Workflow',
        p_street_name => '777 Test Rd',
        p_city => 'Testville',
        p_state => 'TS'
    );
    
    -- Get patient ID
    DECLARE
        v_patient_id NUMBER;
        v_doctor_id NUMBER;
        v_diagnostic_id NUMBER;
        v_med_expenses NUMBER;
        v_diag_expenses NUMBER;
        v_total_expenses NUMBER;
    BEGIN
        SELECT MAX(patient_id) INTO v_patient_id FROM Patient;
        SELECT MIN(doctor_id) INTO v_doctor_id FROM Doctor_Details;
        SELECT MIN(diagnostic_id) INTO v_diagnostic_id FROM Diagnostic_Test;
        
        -- 2. Add medical record
        healthcare_pkg.add_medical_record(
            p_patient_id => v_patient_id,
            p_doctor_id => v_doctor_id,
            p_symptoms => 'Workflow test symptoms',
            p_diagnosis => 'Workflow test diagnosis',
            p_drug_id => 102
        );
        
        -- 3. Order diagnostic test
        healthcare_pkg.order_diagnostic_test(
            p_patient_id => v_patient_id,
            p_diagnostic_id => v_diagnostic_id,
            p_test_result => 'Workflow test results'
        );
        
        -- 4. Update patient details
        update_patient_details(
            p_patient_id => v_patient_id,
            p_first_name => 'Complete Updated',
            p_last_name => 'Workflow Updated',
            p_city => 'Testville Updated',
            p_state => 'TS'
        );
        
        -- 5. Get expenses details
        healthcare_pkg.get_patient_expenses(
            p_patient_id => v_patient_id,
            p_med_expenses => v_med_expenses,
            p_diag_expenses => v_diag_expenses,
            p_total_expenses => v_total_expenses
        );
        
        DBMS_OUTPUT.PUT_LINE('Medication expenses: $' || TO_CHAR(v_med_expenses, '999,999.99'));
        DBMS_OUTPUT.PUT_LINE('Diagnostic expenses: $' || TO_CHAR(v_diag_expenses, '999,999.99'));
        DBMS_OUTPUT.PUT_LINE('Total expenses: $' || TO_CHAR(v_total_expenses, '999,999.99'));
        
        -- 6. Display bill
        healthcare_pkg.display_patient_bill(p_patient_id => v_patient_id);
        
        -- 7. Delete patient (Optional - comment if you want to keep the test data)
        -- delete_patient_record(p_patient_id => v_patient_id);
    END;
END;
/

-- Test Case 14: Error handling in medical record procedure
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 14: Error handling in add_medical_record (Error)');
    healthcare_pkg.add_medical_record(
        p_patient_id => NULL,
        p_doctor_id => 1,
        p_symptoms => 'Test',
        p_diagnosis => 'Test',
        p_drug_id => 101
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected Error: ' || SQLERRM);
END;
/

-- Test Case 15: Error handling in diagnostic test procedure
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test Case 15: Error handling in order_diagnostic_test (Error)');
    healthcare_pkg.order_diagnostic_test(
        p_patient_id => 1,
        p_diagnostic_id => NULL,
        p_test_result => 'Test'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected Error: ' || SQLERRM);
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

CREATE OR REPLACE FUNCTION get_patient_total_expenses(p_patient_id IN INTEGER) 
RETURN NUMBER 
IS
  v_total_expenses NUMBER := 0;
  v_med_expenses NUMBER := 0;
  v_diag_expenses NUMBER := 0;
BEGIN
  -- Calculate medication expenses
  SELECT NVL(SUM(dd.drug_price), 0)
  INTO v_med_expenses
  FROM Medication_Information mi
  JOIN Drug_Details dd ON mi.drug_id = dd.drug_id
  WHERE mi.patient_id = p_patient_id;
  
  -- Calculate diagnostic test expenses
  SELECT NVL(SUM(dt.test_charge), 0)
  INTO v_diag_expenses
  FROM Prescribed_Diagnostics pd
  JOIN Diagnostic_Test dt ON pd.diagnostic_test_id = dt.diagnostic_id
  WHERE pd.patient_id = p_patient_id;
  
  -- Total expenses
  v_total_expenses := v_med_expenses + v_diag_expenses;
  
  RETURN v_total_expenses;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0;
  WHEN OTHERS THEN
    RETURN -1; -- Return negative value to indicate error
END get_patient_total_expenses;
/

-- Test
-- SELECT patient_id, first_name, last_name, get_patient_total_expenses(patient_id) AS total_expenses
-- FROM Patient 
-- where patient_id = 1004;
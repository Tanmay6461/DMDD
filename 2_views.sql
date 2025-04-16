-- 1. Patient Medical Summary View
-- Provides a comprehensive overview of each patient's medical information
CREATE OR REPLACE VIEW Patient_Medical_Summary AS
SELECT 
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    mi.doctor_id,
    dd.first_name || ' ' || dd.last_name AS primary_doctor,
    dd.specialization,
    a.street_name || ', ' || a.city || ', ' || a.state AS patient_address,
    COUNT(DISTINCT mh.patient_history_id) AS total_medical_records,
    COUNT(DISTINCT mi.prescription_id) AS total_prescriptions,
    COUNT(DISTINCT pd.prescribed_diagnostics_id) AS total_diagnostics,
    MAX(mh.date_detected) AS last_visit_date
FROM 
    Patient p
LEFT JOIN 
    Patient_Address a ON p.address_id = a.address_id
LEFT JOIN 
    Medical_History mh ON p.patient_id = mh.patient_id
LEFT JOIN 
    Medication_Information mi ON p.patient_id = mi.patient_id
LEFT JOIN 
    Doctor_Details dd ON mi.doctor_id = dd.doctor_id
LEFT JOIN 
    Prescribed_Diagnostics pd ON p.patient_id = pd.patient_id
GROUP BY 
    p.patient_id, p.first_name, p.last_name, mi.doctor_id, 
    dd.first_name, dd.last_name, dd.specialization, 
    a.street_name, a.city, a.state;

-- 2. Doctor Performance View
-- Tracks doctor activity and patient load
CREATE OR REPLACE VIEW Doctor_Performance AS
SELECT 
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS doctor_name,
    d.specialization,
    COUNT(DISTINCT mi.patient_id) AS assigned_patients,
    COUNT(DISTINCT mi.prescription_id) AS prescriptions_issued,
    COUNT(DISTINCT mh.patient_history_id) AS diagnoses_made,
    NVL(SUM(dd.drug_price), 0) AS total_prescription_value,
    MAX(mi.date_administered) AS last_prescription_date
FROM 
    Doctor_Details d
LEFT JOIN 
    Medication_Information mi ON d.doctor_id = mi.doctor_id
LEFT JOIN 
    Patient p ON mi.patient_id = p.patient_id
LEFT JOIN 
    Medical_History mh ON p.patient_id = mh.patient_id
LEFT JOIN 
    Drug_Details dd ON mi.drug_id = dd.drug_id
GROUP BY 
    d.doctor_id, d.first_name, d.last_name, d.specialization;

-- 3. Drug Utilization View 
-- Analyzes prescription patterns and drug usage
CREATE OR REPLACE VIEW Drug_Utilization AS
SELECT 
    dd.drug_id,
    dd.drug_name,
    dd.drug_price,
    COUNT(mi.prescription_id) AS times_prescribed,
    COUNT(DISTINCT mi.patient_id) AS unique_patients,
    COUNT(DISTINCT mi.doctor_id) AS prescribing_doctors,
    SUM(dd.drug_price) AS total_revenue,
    MAX(mi.date_administered) AS last_prescribed_date
FROM 
    Drug_Details dd
LEFT JOIN 
    Medication_Information mi ON dd.drug_id = mi.drug_id
GROUP BY 
    dd.drug_id, dd.drug_name, dd.drug_price
ORDER BY 
    times_prescribed DESC;

-- 4. Patient Billing Summary View
-- Provides financial information for each patient
CREATE OR REPLACE VIEW Patient_Billing_Summary AS
SELECT 
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    MAX(d.first_name || ' ' || d.last_name) AS doctor_name,
    NVL(SUM(dd.drug_price), 0) AS medication_cost,
    NVL(SUM(dt.test_charge), 0) AS diagnostic_cost,
    NVL(SUM(dd.drug_price), 0) + NVL(SUM(dt.test_charge), 0) AS total_bill,
    MAX(GREATEST(NVL(mi.date_administered, TO_DATE('01-JAN-1900', 'DD-MON-YYYY')), 
                NVL(pd.date_administered, TO_DATE('01-JAN-1900', 'DD-MON-YYYY')))) AS last_billed_date
FROM 
    Patient p
LEFT JOIN 
    Medication_Information mi ON p.patient_id = mi.patient_id
LEFT JOIN 
    Doctor_Details d ON mi.doctor_id = d.doctor_id
LEFT JOIN 
    Drug_Details dd ON mi.drug_id = dd.drug_id
LEFT JOIN 
    Prescribed_Diagnostics pd ON p.patient_id = pd.patient_id
LEFT JOIN 
    Diagnostic_Test dt ON pd.diagnostic_test_id = dt.diagnostic_id
GROUP BY 
    p.patient_id, p.first_name, p.last_name;

-- 5. Diagnostic Test Analysis View
-- Tracks diagnostic test usage and revenue
CREATE OR REPLACE VIEW Diagnostic_Test_Analysis AS
SELECT 
    dt.diagnostic_id,
    dt.test_name,
    dt.test_charge,
    COUNT(pd.prescribed_diagnostics_id) AS times_ordered,
    COUNT(DISTINCT pd.patient_id) AS unique_patients,
    MIN(pd.date_administered) AS first_ordered_date,
    MAX(pd.date_administered) AS last_ordered_date,
    SUM(dt.test_charge) AS total_revenue,
    CASE 
        WHEN COUNT(pd.prescribed_diagnostics_id) = 0 THEN 0
        ELSE SUM(CASE WHEN pd.test_result IS NOT NULL THEN 1 ELSE 0 END) / COUNT(pd.prescribed_diagnostics_id) * 100
    END AS result_entry_rate
FROM 
    Diagnostic_Test dt
LEFT JOIN 
    Prescribed_Diagnostics pd ON dt.diagnostic_id = pd.diagnostic_test_id
GROUP BY 
    dt.diagnostic_id, dt.test_name, dt.test_charge
ORDER BY 
    times_ordered DESC;
    
    

SELECT * FROM PATIENT_MEDICAL_SUMMARY;
SELECT * FROM DOCTOR_PERFORMANCE;
SELECT * FROM DRUG_UTILIZATION;
SELECT * FROM PATIENT_BILLING_SUMMARY;
SELECT * FROM DIAGNOSTIC_TEST_ANALYSIS;
    

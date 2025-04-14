-- 1. Patient Medical Summary View
-- Provides a comprehensive overview of each patient's medical information
CREATE OR REPLACE VIEW Patient_Medical_Summary AS
SELECT 
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS primary_doctor,
    d.specialization,
    a.street_name || ', ' || a.city || ', ' || a.state AS patient_address,
    COUNT(DISTINCT mh.patient_history_id) AS total_medical_records,
    COUNT(DISTINCT mi.prescription_id) AS total_prescriptions,
    COUNT(DISTINCT pd.prescribed_diagnostics_id) AS total_diagnostics,
    MAX(mh.date_detected) AS last_visit_date
FROM 
    Patient p
JOIN 
    Doctor_Details d ON p.doctor_id = d.doctor_id
LEFT JOIN 
    Patient_Address a ON p.patient_id = a.patient_id
LEFT JOIN 
    Medical_History mh ON p.patient_id = mh.patient_id
LEFT JOIN 
    Medication_Information mi ON p.patient_id = mi.patient_id
LEFT JOIN 
    Prescribed_Diagnostics pd ON p.patient_id = pd.patient_id
GROUP BY 
    p.patient_id, p.first_name, p.last_name, d.doctor_id, 
    d.first_name, d.last_name, d.specialization, 
    a.street_name, a.city, a.state;
    



-- 2. Doctor Performance View
-- Tracks doctor activity and patient load
CREATE OR REPLACE VIEW Doctor_Performance AS
SELECT 
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS doctor_name,
    d.specialization,
    COUNT(DISTINCT p.patient_id) AS assigned_patients,
    COUNT(DISTINCT mi.prescription_id) AS prescriptions_issued,
    COUNT(DISTINCT mh.patient_history_id) AS diagnoses_made,
    NVL(SUM(dd.drug_price), 0) AS total_prescription_value,
    MAX(mi.date_administered) AS last_prescription_date
FROM 
    Doctor_Details d
LEFT JOIN 
    Patient p ON d.doctor_id = p.doctor_id
LEFT JOIN 
    Medical_History mh ON p.patient_id = mh.patient_id
LEFT JOIN 
    Medication_Information mi ON d.doctor_id = mi.doctor_id
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
    

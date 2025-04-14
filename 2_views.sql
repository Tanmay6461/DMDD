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
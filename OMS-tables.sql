

-- Patient address
CREATE TABLE IF NOT EXISTS Patient_Address (
    address_id VARCHAR2(50) PRIMARY KEY,
    street_name VARCHAR2(100),
    city VARCHAR2(50),
    state VARCHAR2(50),
    patient_id VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_patient_address FOREIGN KEY (patient_id) REFERENCES Patient_Records (patient_id)
);

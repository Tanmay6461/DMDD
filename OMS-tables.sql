-- doctor details
CREATE TABLE IF NOT EXISTS Doctor_Details (
    doctor_id VARCHAR2(50) PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    specialization VARCHAR2(50)
);


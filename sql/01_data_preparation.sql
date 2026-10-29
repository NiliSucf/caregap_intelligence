-- Create patient-clinic details.
-- Prerequisite: source CSV tables are already loaded
-- with their final column names and data types.

CREATE TABLE CAREGAP_DB.RAW.PATIENT_CLINIC_DETAILS AS
SELECT
    p.PATIENT_ID,
    p.CLINIC_ID,
    c.CLINIC_NAME,
    c.REGION
FROM CAREGAP_DB.RAW.PATIENTS p
LEFT JOIN CAREGAP_DB.RAW.CLINICS c
    ON p.CLINIC_ID = c.CLINIC_ID;

-- Remove exact duplicate screening rows.
CREATE TABLE CAREGAP_DB.RAW.SCREENINGS_CLEAN AS
SELECT DISTINCT *
FROM CAREGAP_DB.RAW.SCREENINGS;

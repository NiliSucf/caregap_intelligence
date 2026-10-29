-- Validation checks for CareGap Intelligence.
-- Run after the data preparation and analysis scripts.

-- 1. Identify repeated screening IDs in the raw data.
-- Review repeated IDs to distinguish exact duplicates
-- from records with conflicting values.
SELECT
    SCREENING_ID,
    COUNT(*) AS RECORD_COUNT
FROM CAREGAP_DB.RAW.SCREENINGS
WHERE SCREENING_ID IS NOT NULL
GROUP BY SCREENING_ID
HAVING COUNT(*) > 1
ORDER BY RECORD_COUNT DESC;


-- 2. Check screening record counts by type and status.
SELECT
    SCREENING_TYPE,
    GAP_STATUS,
    COUNT(*) AS SCREENING_RECORD_COUNT
FROM CAREGAP_DB.RAW.CAREGAP_GAP_ANALYSIS
GROUP BY
    SCREENING_TYPE,
    GAP_STATUS
ORDER BY
    SCREENING_TYPE,
    GAP_STATUS;


-- 3. Check total records and unique eligible patients.
-- Expected: 3,604 records and 1,992 unique patients.
SELECT
    COUNT(*) AS TOTAL_RECORDS,
    COUNT(DISTINCT PATIENT_ID) AS UNIQUE_PATIENTS
FROM CAREGAP_DB.RAW.CAREGAP_GAP_ANALYSIS;


-- 4. Review the clinic summary used in Power BI.
SELECT *
FROM CAREGAP_DB.RAW.CLINIC_GAP_SUMMARY
ORDER BY
    SCREENING_TYPE,
    OVERDUE_PERCENT DESC;

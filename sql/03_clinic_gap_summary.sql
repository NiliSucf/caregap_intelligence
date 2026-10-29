-- Summarize eligible and overdue screening records
-- by clinic, region, and screening type.
-- Run after 02_screening_gap_analysis.sql.

CREATE TABLE CAREGAP_DB.RAW.CLINIC_GAP_SUMMARY AS
SELECT
    CLINIC_NAME,
    REGION,
    SCREENING_TYPE,
    COUNT(*) AS ELIGIBLE_RECORDS,

    SUM(
        CASE
            WHEN GAP_STATUS = 'OVERDUE' THEN 1
            ELSE 0
        END
    ) AS OVERDUE_COUNT,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN GAP_STATUS = 'OVERDUE' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        1
    ) AS OVERDUE_PERCENT

FROM CAREGAP_DB.RAW.CAREGAP_GAP_ANALYSIS
GROUP BY
    CLINIC_NAME,
    REGION,
    SCREENING_TYPE;

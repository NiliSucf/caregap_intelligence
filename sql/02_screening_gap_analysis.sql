-- Identify eligible patient-screening combinations,
-- calculate due dates, and assign screening gap status.
-- Analysis date: October 1, 2026.
-- Run after 01_data_preparation.sql.

CREATE TABLE CAREGAP_DB.RAW.CAREGAP_GAP_ANALYSIS AS

WITH EligiblePatients AS (
    SELECT
        p.PATIENT_ID,
        p.DATE_OF_BIRTH,
        p.SEX,
        pc.CLINIC_NAME,
        pc.REGION,
        r.SCREENING_TYPE,
        r.INTERVAL_MONTHS
    FROM CAREGAP_DB.RAW.PATIENTS p

    CROSS JOIN CAREGAP_DB.RAW.SCREENING_RULES r

    LEFT JOIN CAREGAP_DB.RAW.PATIENT_CLINIC_DETAILS pc
        ON p.PATIENT_ID = pc.PATIENT_ID

    WHERE
        YEAR('2026-10-01'::DATE) - YEAR(p.DATE_OF_BIRTH)
        - CASE
            WHEN TO_CHAR(p.DATE_OF_BIRTH, 'MMDD') > '1001'
                THEN 1
            ELSE 0
          END
        BETWEEN r.MIN_AGE AND r.MAX_AGE

        AND (
            r.SCREENING_TYPE <> 'BREAST_SCREENING'
            OR LOWER(p.SEX) = 'female'
        )
),

LatestScreenings AS (
    SELECT
        PATIENT_ID,
        SCREENING_TYPE,
        MAX(SCREENING_DATE) AS LAST_COMPLETED_DATE
    FROM CAREGAP_DB.RAW.SCREENINGS_CLEAN
    WHERE RESULT_STATUS = 'Completed'
    GROUP BY
        PATIENT_ID,
        SCREENING_TYPE
)

SELECT
    e.PATIENT_ID,
    e.DATE_OF_BIRTH,
    e.SEX,
    e.CLINIC_NAME,
    e.REGION,
    e.SCREENING_TYPE,
    l.LAST_COMPLETED_DATE,
    e.INTERVAL_MONTHS,

    DATEADD(
        MONTH,
        e.INTERVAL_MONTHS,
        l.LAST_COMPLETED_DATE
    ) AS NEXT_DUE_DATE,

    CASE
        WHEN l.LAST_COMPLETED_DATE IS NULL
            THEN 'NO_COMPLETED_SCREENING'
        WHEN DATEADD(
            MONTH,
            e.INTERVAL_MONTHS,
            l.LAST_COMPLETED_DATE
        ) < '2026-10-01'::DATE
            THEN 'OVERDUE'
        ELSE 'UP_TO_DATE'
    END AS GAP_STATUS

FROM EligiblePatients e

LEFT JOIN LatestScreenings l
    ON e.PATIENT_ID = l.PATIENT_ID
    AND e.SCREENING_TYPE = l.SCREENING_TYPE;

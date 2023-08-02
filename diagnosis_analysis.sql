/*
 * This file finds shows stats reagrding Ds-connect vs CDM completeness in diagnosis data
 */
-------------------------
---find patient that have
---dementia, alzahimre, cognitive decline
---from CDM and DS connect
-------------------------
-- CDM
SELECT DISTINCT
    d.patid
FROM
    diagnosis_all d
    JOIN consented c ON c.record_id = d.patid
    JOIN ds_connect dc ON c.record_id = dc.col4
WHERE
    c.ehr_access_agree = 1
    AND dx LIKE 'F03%'
    OR dx LIKE 'F01%'
    OR dx LIKE 'F02%'
    OR dx LIKE 'G30'
    OR dx IN ('331.0', '331.1', '294.2', '294.1', '331.83', 'R41.81', 'G31.84')
    -- DS-connect
    SELECT
        col4,
        col224,
        col327,
        col328,
        col329,
        col941
    FROM
        ds_connect dc
        JOIN consented c ON c.record_id = dc.col4
    WHERE
        c.dsconnect_access_agree = 1
        AND col224 != 'No';


/** DS connect columns(col224, col327, col328, col329, col941): 
 * Has the participant ever been diagnosed with Dementia, Alzheimer's disease, or cognitive decline?
 * Has the participant ever been diagnosed with Dementia, Alzheimer's disease, or cognitive decline?_Adult
 * What was the age of the participant at the earliest onset of dementia symptoms?
 * What was the age of the participant at diagnosis of Dementia, Alzheimer's disease, or cognitive decline?
 * If the participant has had a brain imaging study, what was the reason for obtaining the study? (Select all that apply.) - Symptoms of dementia
 */
-- find the intersection between CDM and DS-connect patients
SELECT
    col4
FROM
    ds_connect dc
    JOIN consented c ON c.record_id = dc.col4
WHERE
    c.dsconnect_access_agree = 1
    AND col224 != 'No'
    AND (length(col224) > 10
        OR col327 = 'Yes')
INTERSECT
SELECT DISTINCT
    d.patid
FROM
    diagnosis_all d
    JOIN consented c ON c.record_id = d.patid
    JOIN ds_connect dc ON c.record_id = dc.col4
WHERE
    c.ehr_access_agree = 1
    AND dx LIKE 'F03%'
    OR dx LIKE 'F01%'
    OR dx LIKE 'F02%'
    OR dx LIKE 'G30'
    OR dx IN ('331.0', '331.1', '294.2', '294.1', '331.83', 'R41.81', 'G31.84')
    -------------------------
    ---find patient that have
    ---Sleep Apnea
    ---from CDM and DS connect
    -------------------------
    -- CDM
    SELECT DISTINCT
        d.patid
    FROM
        diagnosis_all d
        JOIN consented c ON c.record_id = d.patid
        JOIN ds_connect dc ON c.record_id = dc.col4
    WHERE
        c.ehr_access_agree = 1
        AND dx = 'G47.33'
        OR dx = '327.23'
        -- DS-connect
        SELECT
            col4,
            col91,
            col487
        FROM
            ds_connect dc
            JOIN consented c ON c.record_id = dc.col4
        WHERE
            c.dsconnect_access_agree = 1
            AND col91 = '1';


/* DS connect columns (col91, col487):
 * Which of the following sleep problems have been diagnosed? (Select all that apply.) - Sleep apnea
 * Has a doctor ever diagnosed the participant with sleep apnea based on a sleep study?
 * 
 */
-- find the intersection between CDM and DS-connect patients
SELECT DISTINCT
    d.patid
FROM
    diagnosis_all d
    JOIN consented c ON c.record_id = d.patid
    JOIN ds_connect dc ON c.record_id = dc.col4
WHERE
    c.ehr_access_agree = 1
    AND dx = 'G47.33'
    OR dx = '327.23'
UNION
SELECT
    col4
FROM
    ds_connect dc
    JOIN consented c ON c.record_id = dc.col4
WHERE
    c.dsconnect_access_agree = 1
    AND col91 = '1';

-------------------------
---find patient that have
---Diabetes
---from CDM and DS connect
-------------------------
-- CDM
SELECT DISTINCT
    d.patid
FROM
    diagnosis_all d
    JOIN consented c ON c.record_id = d.patid
    JOIN ds_connect dc ON c.record_id = dc.col4
WHERE
    c.ehr_access_agree = 1
    AND (dx LIKE 'E08%'
        OR dx LIKE 'E09%'
        OR dx LIKE 'E10%'
        OR dx LIKE 'E11%'
        OR dx LIKE 'E13%')
    -- DS-connect
    SELECT
        col4,
        col132,
        col735
    FROM
        ds_connect dc
        JOIN consented c ON c.record_id = dc.col4
    WHERE
        c.dsconnect_access_agree = 1
        AND col132 = 'Yes';


/* DS connect columns (col132, col735):
 * Has the participant ever been diagnosed with diabetes?
 * Did the participant's mother have any of the following conditions or treatments during her pregnancy with the participant? (Select all that apply.) - Gestational diabetes (diabetes during pregnancy)
 */
-- find the intersection between CDM and DS-connect patients
SELECT DISTINCT
    d.patid
FROM
    diagnosis_all d
    JOIN consented c ON c.record_id = d.patid
    JOIN ds_connect dc ON c.record_id = dc.col4
WHERE
    c.ehr_access_agree = 1
    AND (dx LIKE 'E08%'
        OR dx LIKE 'E09%'
        OR dx LIKE 'E10%'
        OR dx LIKE 'E11%'
        OR dx LIKE 'E13%')
INTERSECT
SELECT DISTINCT
    dc.col4
FROM
    ds_connect dc
    JOIN consented c ON c.record_id = dc.col4
WHERE
    c.dsconnect_access_agree = 1
    AND col132 = 'Yes';

-------------------------
---find patient that have
---Depression
---from CDM and DS connect
-------------------------
--CDM
SELECT DISTINCT
    d.patid
FROM
    diagnosis_all d
    JOIN consented c ON c.record_id = d.patid
    JOIN ds_connect dc ON c.record_id = dc.col4
WHERE
    c.ehr_access_agree = 1
    AND (dx LIKE 'F32%'
        OR dx LIKE 'F33%'
        OR dx LIKE 'F31%'
        OR dx LIKE '296.2%'
        OR dx LIKE '296.3%'
        OR dx LIKE '296%')
    -- DS-connect
    SELECT
        col192,
        col198,
        col319,
        col897,
        col909
    FROM
        ds_connect dc
        JOIN consented c ON c.record_id = dc.col4
    WHERE
        c.dsconnect_access_agree = 1
        AND (col192 = '1'
            OR col198 = '1'
            OR col897 = 'Currently a problem'
            OR col909 = 'Currently a problem')
        /* DS connect columns (col192, col198, col319, col897, col909):
         * Has the participant ever been diagnosed with any of the following behavioral or mental health conditions? (Select all that apply.) - Depression
         * Has the participant ever been diagnosed with any of the following behavioral or mental health conditions? (Select all that apply.) - Bipolar/manic depression
         * What is the status and age at diagnosis for each of these conditions? (Select all that apply.) - Depression - Status
         * For the following behavioral or mental health conditions, select the status and age in years at diagnosis for the participant. (Select all that apply) - Depression - Status
         * For the following behavioral or mental health conditions, select the status and age in years at diagnosis for the participant. (Select all that apply) - Bipolar/manic depression - Status
         * 
         */
        -- find the intersection between CDM and DS-connect patients
        SELECT DISTINCT
            d.patid
        FROM
            diagnosis_all d
            JOIN consented c ON c.record_id = d.patid
            JOIN ds_connect dc ON c.record_id = dc.col4
        WHERE
            c.ehr_access_agree = 1
            AND (dx LIKE 'F32%'
                OR dx LIKE 'F33%'
                OR dx LIKE 'F31%'
                OR dx LIKE '296.2%'
                OR dx LIKE '296.3%'
                OR dx LIKE '296%')
        INTERSECT
        SELECT
            dc.col4
        FROM
            ds_connect dc
            JOIN consented c ON c.record_id = dc.col4
        WHERE
            c.dsconnect_access_agree = 1
            AND (col192 = '1'
                OR col198 = '1'
                OR col897 = 'Currently a problem'
                OR col909 = 'Currently a problem')

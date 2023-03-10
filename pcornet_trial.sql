-- identify patients who do not have invite code
SELECT
    nm.record_id,
    dc.*,
    nm.*
FROM
    ds_connect dc
    JOIN names_map nm ON lower(nm.first_name_ds) = lower(dc.firstname)
        AND lower(nm.last_name_ds) = lower(dc.lastname)
WHERE
    lower(firstname) != 'test'
    AND lower(lastname) != 'test'
    AND dc.record_id != 'referraltest'
    AND dc.record_id NOT LIKE 'SA%';

-- match these patient based on first and last names
UPDATE
    ds_connect AS dc
SET
    record_id = nm.record_id
FROM
    names_map nm
WHERE
    lower(nm.first_name_ds) = lower(dc.firstname)
    AND lower(nm.last_name_ds) = lower(dc.lastname)
    AND lower(firstname) != 'test'
    AND lower(lastname) != 'test'
    AND dc.record_id != 'referraltest'
    AND dc.record_id NOT LIKE 'SA%';

SELECT
    rd.record_id,
    dc.*,
    rd.*
FROM
    ds_connect dc
    JOIN recruitment_data rd ON lower(rd.first_name_ds) = lower(dc.firstname)
        AND lower(rd.last_name_ds) = lower(dc.lastname)
WHERE
    lower(firstname) != 'test'
    AND lower(lastname) != 'test'
    AND dc.record_id != 'referraltest'
    AND dc.record_id NOT LIKE 'SA%';

UPDATE
    ds_connect AS dc
SET
    record_id = rd.record_id
FROM
    recruitment_data rd
WHERE
    lower(rd.first_name_ds) = lower(dc.firstname)
    AND lower(rd.last_name_ds) = lower(dc.lastname)
    AND lower(firstname) != 'test'
    AND lower(lastname) != 'test'
    AND dc.record_id != 'referraltest'
    AND dc.record_id NOT LIKE 'SA%';

COMMIT;

DROP TABLE IF EXISTS pat_map;

CREATE TABLE pat_map AS
SELECT
    rm.record_id,
    COALESCE(dr1.email, dr2.email, dr3.email) AS email,
    COALESCE(dr1.mrn, dr2.mrn, dr3.mrn, nm.mrn) AS mrn,
    rm.first_name_ds,
    rm.last_name_ds,
    COALESCE(dr1.patient_name, dr2.patient_name, dr3.patient_name) AS patient_name
FROM
    ds_determined.recruitment_mrn rm
    LEFT JOIN dua_request1980_1 dr1 ON lower(rm.email) = lower(dr1.email)
    LEFT JOIN dua_request1980_2 dr2 ON lower(rm.email) = lower(dr2.email)
    LEFT JOIN dua_request1980_3 dr3 ON lower(rm.email) = lower(dr3.email)
    LEFT JOIN names_map nm ON rm.record_id = nm.record_id
WHERE
    rm.email IS NOT NULL;

UPDATE
    pat_map
SET
    mrn = lpad(mrn, 7, '0');

--  delete duplicate rows
CREATE TABLE pat_map_tmp AS
SELECT
    record_id,
    email,
    mrn,
    first_name_ds,
    last_name_ds,
    patient_name
FROM
    pat_map pm
GROUP BY
    record_id,
    email,
    mrn,
    first_name_ds,
    last_name_ds,
    patient_name;

;

DROP TABLE IF EXISTS pat_map;

ALTER TABLE pat_map_tmp RENAME TO pat_map;

COMMIT;

DROP TABLE IF EXISTS pcornet_trial;

CREATE TABLE pcornet_trial AS
SELECT
    svp.pat_deid AS patid,
    'DS-DETERMINED' AS trialid,
    cd.record_id AS participantid,
    'SA' AS trial_siteid, --change to your site id
    cd.consent_to_link_timestamp AS trial_enroll_date,
    NULL AS trial_end_date,
    NULL AS trial_withdraw_date,
    NULL AS trial_invite_code
FROM
    consented_dates cd
    LEFT JOIN pat_map pm ON pm.record_id = cd.record_id
    LEFT JOIN pat_inclusion.static_valid_patients svp ON svp.fh_mrn = pm.mrn;

DELETE FROM pcornet_trial cd
WHERE patid IS NULL;

-- delete patients that have not consented (check redcap and verify before deletion)
COMMIT;


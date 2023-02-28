/** dua_request1980_1, dua_request1980_2 and dua_request1980_3 are provided from redcap project
 * schema: ds_determined
 **/
DROP TABLE pat_mrn;

CREATE TABLE pat_mrn AS
SELECT
    record_id,
    COALESCE(dr1.email, dr2.email, dr3.email) AS email,
    COALESCE(dr1.mrn, dr2.mrn, dr3.mrn) AS mrn,
    rm.first_name_ds,
    rm.last_name_ds,
    COALESCE(dr1.patient_name, dr2.patient_name, dr3.patient_name)
FROM
    ds_determined.recruitment_mrn rm
    LEFT JOIN dua_request1980_1 dr1 ON lower(rm.email) = lower(dr1.email)
    LEFT JOIN dua_request1980_2 dr2 ON lower(rm.email) = lower(dr2.email)
    LEFT JOIN dua_request1980_3 dr3 ON lower(rm.email) = lower(dr3.email)
WHERE
    rm.email IS NOT NULL;

DROP TABLE dua_request1980_all;

CREATE TABLE dua_request1980_all AS
SELECT
    patient_name,
    mrn,
    email
FROM
    dua_request1980_1
UNION
SELECT
    patient_name,
    mrn,
    email
FROM
    dua_request1980_2
UNION
SELECT
    patient_name,
    mrn,
    email
FROM
    dua_request1980_3;

DROP TABLE names_map;

CREATE TABLE names_map AS
SELECT
    dr.patient_name,
    rm.last_name_ds,
    rm.first_name_ds,
    rm.record_id,
    dr.mrn
FROM
    ds_determined.recruitment_mrn rm
    JOIN dua_request1980_all dr ON lower(dr.patient_name)
    LIKE lower(concat(rm.last_name_ds, ',', rm.first_name_ds, '%'))
WHERE
    dr.patient_name IS NOT NULL
    AND trim(last_name_ds) IS NOT NULL
    AND trim(first_name_ds) IS NOT NULL;

DROP TABLE pat_info;

CREATE TABLE pat_info AS
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

SELECT
    record_id,
    mrn
FROM
    pat_info
GROUP BY
    record_id,
    mrn;


/*
 * prepare the the data for synapse upload, verify the consented patients.
 */
SELECT
    s.record_id,
    browser_name,
    platform_name,
    browser_height,
    browser_width,
    has_js,
    is_complete,
    segment,
    pagelnk,
    measure_order,
    "Version",
    lastpage,
    pages,
    "Language",
    answerforself,
    demog1,
    demog2,
    demog2_other,
    demog3,
    demog4,
    demog5,
    demog5a,
    demog6,
    demog6a,
    demog7,
    demog8,
    demog10,
    demog11,
    demog11_other,
    demog12a,
    demog12b,
    demog12c,
    demog12d,
    demog12e,
    demog12f,
    demog12g,
    demog12h,
    demog12i,
    demog12j,
    demog12_other,
    demog13,
    demog14,
    demog14a,
    demog15,
    demog15a,
    demog16a,
    demog16b,
    demog16c,
    demog16d,
    demog_16_other,
    demog17,
    demog18,
    demog19,
    sdi_dsc38,
    sdi_dsc20,
    sdi_dsc9,
    sdi_dsc32,
    sdi_dsc1,
    sdi_dsc26,
    sdi_dsc14,
    sdi_dsc25,
    sdi_dsc2,
    sdi_dsc39,
    sdi_dsc22,
    sdi_dsc35,
    sdi_dsc10,
    sdi_dsc19,
    sdi_dsc30,
    sdi_dsc12,
    sdi_dsc42,
    sdi_dsc6,
    sdi_dsc18,
    sdi_dsc36,
    sdi_dsc23,
    overall_sdi
FROM
    sdi s
    JOIN consented c ON c.record_id = s.record_id
WHERE
    c.survey_access_agree = 1;

SELECT
    *
FROM
    ds_connect s
    JOIN consented c ON c.record_id = s.col4
WHERE
    c.dsconnect_access_agree = 1;

SELECT
    d.*
FROM
    demographic_all d
    JOIN consented c ON c.record_id = d.patid
WHERE
    c.ehr_access_agree = 1;

SELECT
    d.*
FROM
    encounter_all d
    JOIN consented c ON c.record_id = d.patid
WHERE
    c.ehr_access_agree = 1;

SELECT
    d.*
FROM
    diagnosis_all d
    JOIN consented c ON c.record_id = d.patid
WHERE
    c.ehr_access_agree = 1;

SELECT
    d.*
FROM
    procedures_all d
    JOIN consented c ON c.record_id = d.patid
WHERE
    c.ehr_access_agree = 1;

SELECT
    d.*
FROM
    lab_result_cm_all d
    JOIN consented c ON c.record_id = d.patid
WHERE
    c.ehr_access_agree = 1;

SELECT
    d.*
FROM
    condition_all d
    JOIN consented c ON c.record_id = d.patid
WHERE
    c.ehr_access_agree = 1;

SELECT
    d.*
FROM
    pro_cm_all d
    JOIN consented c ON c.record_id = d.patid
WHERE
    c.ehr_access_agree = 1;

SELECT
    d.*
FROM
    prescribing_all d
    JOIN consented c ON c.record_id = d.patid
WHERE
    c.ehr_access_agree = 1;

SELECT
    d.*
FROM
    death_all d
    JOIN consented c ON c.record_id = d.patid
WHERE
    c.ehr_access_agree = 1;

SELECT
    d.*
FROM
    med_admin_all d
    JOIN consented c ON c.record_id = d.patid
WHERE
    c.ehr_access_agree = 1;

SELECT
    d.*
FROM
    obs_clin_all d
    JOIN consented c ON c.record_id = d.patid
WHERE
    c.ehr_access_agree = 1;

SELECT
    d.*
FROM
    immunization_all d
    JOIN consented c ON c.record_id = d.patid
WHERE
    c.ehr_access_agree = 1;

SELECT
    d.*
FROM
    vital_all d
    JOIN consented c ON c.record_id = d.patid
WHERE
    c.ehr_access_agree = 1;


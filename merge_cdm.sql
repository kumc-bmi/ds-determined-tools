/*
 * Merge CDM tables of KUMC, MU, Allina, and Pitt into one table
 */
DROP TABLE IF EXISTS condition_all;

CREATE TABLE condition_all AS
SELECT
    conditionid,
    pt.participantid AS patid,
    encounterid,
    EXTRACT(YEAR FROM age(report_date::date, da.birth_date)) AS age_at_visit,
    condition_status,
    condition,
    condition_type,
    condition_source
FROM
    condition c
    JOIN pcornet_trial pt ON pt.patid = c.patid
    JOIN demographic_all da ON da.patid = pt.participantid
UNION
SELECT
    conditionid,
    study_id AS patid,
    encounterid,
    EXTRACT(YEAR FROM age(report_date::date, da.birth_date)) AS age_at_visit,
    condition_status,
    "CONDITION",
    condition_type::varchar,
    condition_source
FROM
    condition_pitt pt
    JOIN demographic_all da ON da.patid = pt.study_id
UNION
SELECT
    conditionid::varchar,
    pts.participantid::varchar AS patid,
    encounterid,
    EXTRACT(YEAR FROM age(report_date::date, da.birth_date)) AS age_at_visit,
    condition_status,
    "CONDITION",
    condition_type::varchar,
    condition_source
FROM
    condition_sc c
    JOIN pcornet_trial_sc pts ON pts.patid = c.patid
    JOIN demographic_all da ON da.patid = pts.participantid
UNION
SELECT
    conditionid::varchar,
    ptm.participantid::varchar AS patid,
    encounterid,
    EXTRACT(YEAR FROM age(report_date::date, da.birth_date)) AS age_at_visit,
    condition_status,
    "CONDITION",
    condition_type::varchar,
    condition_source
FROM
    condition_mu c
    JOIN pcornet_trial_mu ptm ON ptm.patid::varchar = c.patid::varchar
    JOIN demographic_all da ON da.patid = ptm.participantid;

DROP TABLE IF EXISTS diagnosis_all;

CREATE TABLE diagnosis_all AS
SELECT
    diagnosisid,
    pt.participantid AS patid,
    encounterid,
    enc_type,
    providerid,
    dx,
    dx_type,
    EXTRACT(YEAR FROM age(COALESCE(dx_date::date, ADMIT_DATE::date), da.birth_date)) AS age_at_diagnosis,
    dx_source,
    dx_origin,
    pdx,
    dx_poa
FROM
    diagnosis d
    JOIN pcornet_trial pt ON pt.patid = d.patid
    JOIN demographic_all da ON da.patid = pt.participantid
UNION
SELECT
    diagnosisid,
    study_id AS patid,
    encounterid,
    enc_type,
    providerid::varchar,
    dx,
    dx_type,
    EXTRACT(YEAR FROM age(COALESCE(dx_date::date, ADMIT_DATE::date), da.birth_date)) AS age_at_diagnosis,
    dx_source,
    dx_origin,
    pdx,
    dx_poa
FROM
    diagnosis_pitt
    JOIN demographic_all da ON da.patid = study_id
UNION
SELECT
    diagnosisid,
    pts.participantid::varchar AS patid,
    encounterid,
    enc_type,
    providerid::varchar,
    dx,
    dx_type,
    EXTRACT(YEAR FROM age(COALESCE(dx_date::date, ADMIT_DATE::date), da.birth_date)) AS age_at_diagnosis,
    dx_source,
    dx_origin,
    pdx,
    dx_poa
FROM
    diagnosis_sc d
    JOIN pcornet_trial_sc pts ON pts.patid::varchar = d.patid
    JOIN demographic_all da ON da.patid = pts.participantid
UNION
SELECT
    diagnosisid,
    ptm.participantid::varchar AS patid,
    encounterid,
    enc_type,
    providerid::varchar,
    dx,
    dx_type,
    EXTRACT(YEAR FROM age(COALESCE(dx_date::date, ADMIT_DATE::date), da.birth_date)) AS age_at_diagnosis,
    dx_source,
    dx_origin,
    pdx,
    dx_poa
FROM
    diagnosis_mu d
    JOIN pcornet_trial_mu ptm ON ptm.patid::varchar = d.patid
    JOIN demographic_all da ON da.patid = ptm.participantid;

DROP TABLE IF EXISTS prescribing_all;

CREATE TABLE prescribing_all AS
SELECT
    prescribingid,
    pt.participantid AS patid,
    encounterid,
    rx_providerid,
    EXTRACT(YEAR FROM age(rx_order_date::date, da.birth_date)) AS age_at_order,
    rx_dose_ordered,
    rx_dose_ordered_unit,
    rx_quantity,
    rx_dose_form,
    rx_refills,
    rx_days_supply::varchar,
    rx_frequency,
    rx_prn_flag,
    rx_route,
    rx_basis,
    rxnorm_cui,
    rx_source,
    rx_dispense_as_written
FROM
    prescribing p
    JOIN pcornet_trial pt ON pt.patid = p.patid
    JOIN demographic_all da ON da.patid = pt.participantid
UNION
SELECT
    prescribingid,
    study_id,
    encounterid,
    rx_providerid::varchar,
    EXTRACT(YEAR FROM age(rx_order_date::date, da.birth_date)) AS age_at_order,
    rx_dose_ordered::int,
    rx_dose_ordered_unit,
    rx_quantity,
    rx_dose_form,
    rx_refills,
    rx_days_supply::varchar,
    rx_frequency,
    rx_prn_flag,
    rx_route,
    rx_basis::varchar,
    rxnorm_cui::varchar,
    rx_source,
    rx_dispense_as_written
FROM
    prescribing_pitt
    JOIN demographic_all da ON da.patid = study_id
UNION
SELECT
    prescribingid::varchar,
    pts.participantid::varchar AS patid,
    encounterid::varchar,
    rx_providerid::varchar,
    EXTRACT(YEAR FROM age(rx_order_date::date, da.birth_date)) AS age_at_order,
    rx_dose_ordered::int,
    rx_dose_ordered_unit,
    rx_quantity,
    rx_dose_form,
    rx_refills,
    rx_days_supply::varchar,
    rx_frequency,
    rx_prn_flag,
    rx_route,
    rx_basis::varchar,
    rxnorm_cui::varchar,
    rx_source,
    rx_dispense_as_written
FROM
    prescribing_sc p
    JOIN pcornet_trial_sc pts ON pts.patid = p.patid
    JOIN demographic_all da ON da.patid = pts.participantid
UNION
SELECT
    prescribingid::varchar,
    ptm.participantid::varchar AS patid,
    encounterid::varchar,
    rx_providerid::varchar,
    EXTRACT(YEAR FROM age(rx_order_date::date, da.birth_date)) AS age_at_order,
    rx_dose_ordered::int,
    rx_dose_ordered_unit,
    rx_quantity,
    rx_dose_form,
    rx_refills,
    rx_days_supply::varchar,
    rx_frequency,
    rx_prn_flag,
    rx_route,
    rx_basis::varchar,
    rxnorm_cui::varchar,
    rx_source,
    rx_dispense_as_written
FROM
    prescribing_mu p
    JOIN pcornet_trial_mu ptm ON ptm.patid::varchar = p.patid
    JOIN demographic_all da ON da.patid = ptm.participantid;

DROP TABLE IF EXISTS procedures_all;

CREATE TABLE procedures_all AS
SELECT
    proceduresid,
    pt.participantid AS patid,
    encounterid,
    enc_type,
    providerid,
    EXTRACT(YEAR FROM age(px_date::date, da.birth_date)) AS age_at_procedure,
    px,
    px_type,
    px_source,
    ppx
FROM
    PROCEDURES p
    JOIN pcornet_trial pt ON pt.patid = p.patid
    JOIN demographic_all da ON da.patid = pt.participantid
UNION
SELECT
    proceduresid,
    study_id,
    encounterid,
    enc_type,
    providerid::varchar,
    EXTRACT(YEAR FROM age(px_date::date, da.birth_date)) AS age_at_procedure,
    px,
    px_type,
    px_source,
    ppx
FROM
    procedures_pitt
    JOIN demographic_all da ON da.patid = study_id
UNION
SELECT
    proceduresid::varchar,
    pts.participantid::varchar AS patid,
    encounterid::varchar,
    enc_type,
    providerid::varchar,
    EXTRACT(YEAR FROM age(px_date::date, da.birth_date)) AS age_at_procedure,
    px,
    px_type,
    px_source,
    ppx
FROM
    procedures_sc p
    JOIN pcornet_trial_sc pts ON pts.patid = p.patid
    JOIN demographic_all da ON da.patid = pts.participantid
UNION
SELECT
    proceduresid::varchar,
    ptm.participantid::varchar AS patid,
    encounterid::varchar,
    enc_type,
    providerid::varchar,
    EXTRACT(YEAR FROM age(px_date::date, da.birth_date)) AS age_at_procedure,
    px,
    px_type,
    px_source,
    ppx
FROM
    procedures_mu p
    JOIN pcornet_trial_mu ptm ON ptm.patid::varchar = p.patid::varchar
    JOIN demographic_all da ON da.patid = ptm.participantid;

DROP TABLE IF EXISTS demographic_all;

CREATE TABLE demographic_all AS
SELECT
    pt.participantid AS patid,
    birth_date,
    EXTRACT(YEAR FROM age(CURRENT_DATE, birth_date)) AS age_in_years,
    sex,
    sexual_orientation,
    gender_identity,
    hispanic,
    race,
    biobank_flag,
    pat_pref_language_spoken
FROM
    demographic d
    JOIN pcornet_trial pt ON pt.patid = d.patid
UNION
SELECT
    pts.participantid AS patid,
    birth_date,
    EXTRACT(YEAR FROM age(CURRENT_DATE, birth_date)) AS age_in_years,
    sex,
    sexual_orientation,
    gender_identity,
    hispanic,
    race,
    biobank_flag,
    pat_pref_language_spoken
FROM
    demographic_sc d
    JOIN pcornet_trial_sc pts ON pts.patid::varchar = d.patid
UNION
SELECT
    ptm.participantid AS patid,
    birth_date,
    EXTRACT(YEAR FROM age(CURRENT_DATE, birth_date)) AS age_in_years,
    sex,
    sexual_orientation,
    gender_identity,
    hispanic,
    race,
    biobank_flag,
    pat_pref_language_spoken
FROM
    demographic_mu d
    JOIN pcornet_trial_mu ptm ON ptm.patid = d.patid::varchar
UNION
SELECT
    study_id AS patid,
    birth_date::timestamp,
    EXTRACT(YEAR FROM age(CURRENT_DATE, birth_date::timestamp)) AS age_in_years,
    sex,
    sexual_orientation,
    gender_identity,
    hispanic,
    race,
    biobank_flag,
    pat_pref_language_spoken
FROM
    demographic_pitt;

DROP TABLE IF EXISTS med_admin_all;

CREATE TABLE med_admin_all AS
SELECT
    medadminid,
    pt.participantid AS patid,
    encounterid,
    prescribingid,
    medadmin_providerid,
    EXTRACT(YEAR FROM age(medadmin_start_date, da.birth_date::timestamp)) AS age_at_med_started,
    medadmin_type,
    medadmin_code,
    medadmin_dose_admin,
    medadmin_dose_admin_unit,
    medadmin_route,
    medadmin_source
FROM
    med_admin d
    JOIN pcornet_trial pt ON pt.patid = d.patid
    JOIN demographic_all da ON da.patid = pt.participantid
UNION
SELECT
    medadminid,
    pts.participantid AS patid,
    encounterid,
    prescribingid,
    medadmin_providerid,
    EXTRACT(YEAR FROM age(medadmin_start_date, birth_date::timestamp)) AS age_at_med_started,
    medadmin_type,
    medadmin_code,
    medadmin_dose_admin,
    medadmin_dose_admin_unit,
    medadmin_route,
    medadmin_source
FROM
    med_admin_sc d
    JOIN pcornet_trial_sc pts ON pts.patid::varchar = d.patid
    JOIN demographic_all da ON da.patid = pts.participantid
UNION
SELECT
    medadminid,
    ptm.participantid AS patid,
    encounterid,
    prescribingid,
    medadmin_providerid,
    EXTRACT(YEAR FROM age(medadmin_start_date, birth_date::timestamp)) AS age_at_med_started,
    medadmin_type,
    medadmin_code,
    medadmin_dose_admin,
    medadmin_dose_admin_unit,
    medadmin_route,
    medadmin_source
FROM
    med_admin_mu d
    JOIN pcornet_trial_mu ptm ON ptm.patid = d.patid::varchar
    JOIN demographic_all da ON da.patid = ptm.participantid;

DROP TABLE IF EXISTS encounter_all;

CREATE TABLE encounter_all AS
SELECT
    encounterid,
    pt.participantid AS patid,
    EXTRACT(YEAR FROM age(admit_date, birth_date::timestamp)) AS age_at_admit,
    providerid,
    facility_location,
    enc_type,
    facilityid,
    discharge_disposition,
    discharge_status,
    drg,
    drg_type,
    admitting_source,
    payer_type_primary,
    payer_type_secondary,
    facility_type
FROM
    encounter e
    JOIN pcornet_trial pt ON pt.patid = e.patid
    JOIN demographic_all da ON da.patid = pt.participantid
UNION
SELECT
    encounterid::varchar,
    pt.participantid::varchar,
    EXTRACT(YEAR FROM age(admit_date::date, birth_date::timestamp)) AS age_at_admit,
    providerid::varchar,
    facility_location::varchar,
    enc_type,
    facilityid::varchar,
    discharge_disposition,
    discharge_status,
    drg,
    drg_type,
    admitting_source,
    payer_type_primary::varchar,
    payer_type_secondary,
    facility_type
FROM
    encounter_sc e
    JOIN pcornet_trial_sc pt ON pt.patid::varchar = e.patid::varchar
    JOIN demographic_all da ON da.patid = pt.participantid
UNION
SELECT
    encounterid::varchar,
    pt.participantid,
    EXTRACT(YEAR FROM age(nullif(admit_date, '')::timestamp, birth_date::timestamp)) AS age_at_admit,
    providerid::varchar,
    facility_location::varchar,
    enc_type,
    facilityid,
    discharge_disposition,
    discharge_status,
    drg::varchar,
    drg_type,
    admitting_source,
    payer_type_primary,
    payer_type_secondary::varchar,
    facility_type
FROM
    encounter_mu e
    JOIN pcornet_trial_mu pt ON pt.patid::varchar = e.patid::varchar
    JOIN demographic_all da ON da.patid = pt.participantid
UNION
SELECT
    encounterid::varchar,
    e.study_id,
    EXTRACT(YEAR FROM age(nullif(admit_date, '')::timestamp, birth_date::timestamp)) AS age_at_admit,
    providerid::varchar,
    facility_location::varchar,
    enc_type,
    facilityid,
    discharge_disposition,
    discharge_status,
    drg::varchar,
    drg_type,
    admitting_source,
    payer_type_primary,
    payer_type_secondary,
    facility_type
FROM
    encounter_pitt e
    JOIN demographic_all da ON da.patid = study_id;

DROP TABLE IF EXISTS lab_result_cm_all;

CREATE TABLE lab_result_cm_all AS
SELECT
    lab_result_cm_id,
    pt.participantid AS patid,
    encounterid,
    lab_name,
    specimen_source,
    lab_loinc,
    lab_result_source,
    lab_loinc_source,
    priority,
    result_loc,
    lab_px,
    lab_px_type,
    EXTRACT(YEAR FROM age(lab_order_date, birth_date::timestamp)) AS age_at_order,
    result_qual,
    result_num,
    result_modifier,
    result_unit,
    norm_range_low,
    norm_modifier_low,
    norm_range_high,
    norm_modifier_high,
    abn_ind,
    result_snomed
FROM
    lab_result_cm lrc
    JOIN pcornet_trial pt ON pt.patid = lrc.patid
    JOIN demographic_all da ON da.patid = pt.participantid
UNION
SELECT
    lab_result_cm_id::varchar,
    pt.participantid::varchar,
    encounterid::varchar,
    NULL AS lab_name,
    specimen_source,
    lab_loinc,
    lab_result_source,
    lab_loinc_source,
    priority,
    result_loc,
    lab_px,
    lab_px_type,
    EXTRACT(YEAR FROM age(lab_order_date::timestamp, birth_date::timestamp)) AS age_at_order,
    result_qual,
    result_num,
    result_modifier,
    result_unit,
    norm_range_low::varchar,
    norm_modifier_low,
    norm_range_high::varchar,
    norm_modifier_high,
    abn_ind,
    result_snomed
FROM
    lab_result_cm_sc lrc
    JOIN pcornet_trial_sc pt ON pt.patid::varchar = lrc.patid::varchar
    JOIN demographic_all da ON da.patid = pt.participantid
UNION
SELECT
    lab_result_cm_id::varchar,
    pt.participantid::varchar,
    encounterid::varchar,
    NULL AS lab_name,
    specimen_source,
    lab_loinc,
    lab_result_source,
    lab_loinc_source,
    priority,
    result_loc,
    lab_px,
    lab_px_type,
    EXTRACT(YEAR FROM age(lab_order_date::timestamp, birth_date::timestamp)) AS age_at_order,
    result_qual,
    nullif(result_num, '')::float,
    result_modifier,
    result_unit,
    norm_range_low::varchar,
    norm_modifier_low,
    norm_range_high::varchar,
    norm_modifier_high,
    abn_ind,
    result_snomed
FROM
    lab_result_cm_mu lrc
    JOIN pcornet_trial_mu pt ON pt.patid::varchar = lrc.patid::varchar
    JOIN demographic_all da ON da.patid = pt.participantid
UNION
SELECT
    lab_result_cm_id::varchar,
    study_id,
    encounterid::varchar,
    NULL AS lab_name,
    specimen_source,
    lab_loinc,
    lab_result_source,
    lab_loinc_source,
    priority,
    result_loc,
    lab_px,
    lab_px_type,
    EXTRACT(YEAR FROM age(lab_order_date::timestamp, birth_date::timestamp)) AS age_at_order,
    result_qual,
    nullif(result_num, '')::float,
    result_modifier,
    result_unit,
    norm_range_low::varchar,
    norm_modifier_low,
    norm_range_high::varchar,
    norm_modifier_high,
    abn_ind,
    result_snomed
FROM
    lab_result_cm_pitt lrc
    JOIN demographic_all da ON da.patid = study_id;

DROP TABLE IF EXISTS immunization_all;

CREATE TABLE immunization_all AS
SELECT
    immunizationid,
    pt.participantid AS patid,
    encounterid,
    proceduresid,
    vx_providerid,
    EXTRACT(YEAR FROM age(vx_record_date, birth_date::timestamp)) AS age_at_vx_record,
    vx_code_type,
    vx_code,
    vx_status,
    vx_status_reason,
    vx_source,
    vx_dose,
    vx_dose_unit,
    vx_route,
    vx_body_site,
    vx_manufacturer,
    vx_lot_num
FROM
    immunization i
    JOIN pcornet_trial pt ON pt.patid = i.patid
    JOIN demographic_all da ON da.patid = pt.participantid
UNION
SELECT
    immunizationid,
    pt.participantid AS patid,
    encounterid,
    proceduresid,
    vx_providerid,
    EXTRACT(YEAR FROM age(nullif(vx_record_date, '')::timestamp, birth_date::timestamp)) AS age_at_vx_record,
    vx_code_type,
    vx_code,
    vx_status,
    vx_status_reason,
    vx_source,
    vx_dose::float,
    vx_dose_unit,
    vx_route,
    vx_body_site,
    vx_manufacturer,
    vx_lot_num
FROM
    immunization_mu i
    JOIN pcornet_trial_mu pt ON pt.patid = i.patid
    JOIN demographic_all da ON da.patid = pt.participantid
UNION
SELECT
    immunizationid,
    pt.participantid AS patid,
    encounterid,
    proceduresid,
    vx_providerid,
    EXTRACT(YEAR FROM age(vx_record_date::date, birth_date::timestamp)) AS age_at_vx_record,
    vx_code_type,
    vx_code,
    vx_status,
    vx_status_reason,
    vx_source,
    vx_dose::float,
    vx_dose_unit,
    vx_route,
    vx_body_site,
    vx_manufacturer,
    vx_lot_num
FROM
    immunization_sc i
    JOIN pcornet_trial_sc pt ON pt.patid::varchar = i.patid
    JOIN demographic_all da ON da.patid = pt.participantid
UNION
SELECT
    immunizationid,
    i.study_id AS patid,
    encounterid,
    proceduresid,
    vx_providerid,
    EXTRACT(YEAR FROM age(vx_record_date::date, birth_date::timestamp)) AS age_at_vx_record,
    vx_code_type,
    vx_code,
    vx_status,
    vx_status_reason,
    vx_source,
    nullif(vx_dose, '')::float,
    vx_dose_unit,
    vx_route,
    vx_body_site,
    vx_manufacturer,
    vx_lot_num
FROM
    immunization_pitt i
    JOIN demographic_all da ON da.patid = study_id;

DROP TABLE IF EXISTS death_all;

CREATE TABLE death_all AS
SELECT
    pt.participantid AS patid,
    EXTRACT(YEAR FROM age(death_date::date, birth_date::timestamp)) AS age_at_death,
    death_date_impute,
    death_source,
    death_match_confidence
FROM
    death d
    JOIN pcornet_trial pt ON pt.patid = d.patid
    JOIN demographic_all da ON da.patid = pt.participantid
UNION
SELECT
    study_id AS patid,
    EXTRACT(YEAR FROM age(nullif(death_date, '')::timestamp, birth_date::timestamp)) AS age_at_death,
    death_date_impute,
    death_source,
    death_match_confidence
FROM
    death_pitt d
    JOIN demographic_all da ON da.patid = study_id;

DROP TABLE IF EXISTS pro_cm_all;

CREATE TABLE pro_cm_all AS
SELECT
    pt.participantid AS patid,
    encounterid::varchar,
    pro_cm_id::varchar,
    pro_loinc,
    EXTRACT(YEAR FROM age(pro_date::timestamp, birth_date::timestamp)) AS age_at_pro,
    pro_type,
    pro_item_name,
    pro_item_loinc,
    pro_response_text,
    pro_response_num,
    pro_method,
    pro_mode,
    pro_cat,
    pro_item_version,
    pro_measure_name,
    pro_measure_seq,
    pro_measure_score,
    pro_measure_theta,
    pro_measure_scaled_tscore,
    pro_measure_standard_error,
    pro_measure_count_scored,
    pro_measure_loinc,
    pro_measure_version,
    pro_item_fullname,
    pro_item_text,
    pro_measure_fullname,
    pro_source
FROM
    pro_cm_mu pcm
    JOIN pcornet_trial_mu pt ON pt.patid = pcm.patid::varchar
    JOIN demographic_all da ON da.patid = pt.participantid
UNION
SELECT
    study_id AS patid,
    encounterid::varchar,
    pro_cm_id::varchar,
    pro_loinc,
    EXTRACT(YEAR FROM age(pro_date::timestamp, birth_date::timestamp)) AS age_at_pro,
    pro_type,
    pro_item_name,
    pro_item_loinc,
    pro_response_text,
    pro_response_num,
    pro_method,
    pro_mode,
    pro_cat,
    pro_item_version,
    pro_measure_name,
    pro_measure_seq,
    pro_measure_score,
    pro_measure_theta,
    pro_measure_scaled_tscore,
    pro_measure_standard_error,
    pro_measure_count_scored,
    pro_measure_loinc,
    pro_measure_version,
    pro_item_fullname,
    pro_item_text,
    pro_measure_fullname,
    pro_source
FROM
    pro_cm_pitt pcm
    JOIN demographic_all da ON da.patid = study_id;

DROP TABLE IF EXISTS vital_all;

CREATE TABLE vital_all AS
SELECT
    vitalid,
    pt.participantid AS patid,
    encounterid,
    EXTRACT(YEAR FROM age(measure_date::timestamp, birth_date::timestamp)) AS age_at_measure,
    vital_source,
    ht,
    wt,
    diastolic,
    systolic,
    original_bmi,
    bp_position,
    smoking,
    tobacco,
    tobacco_type
FROM
    vital v
    JOIN pcornet_trial pt ON pt.patid = v.patid
    JOIN demographic_all da ON da.patid = pt.participantid
UNION
SELECT
    vitalid::varchar,
    pt.participantid AS patid,
    encounterid::varchar,
    EXTRACT(YEAR FROM age(measure_date::timestamp, birth_date::timestamp)) AS age_at_measure,
    vital_source,
    ht,
    wt,
    diastolic,
    systolic,
    original_bmi,
    bp_position,
    smoking,
    tobacco::varchar,
    tobacco_type::varchar
FROM
    vital_sc v
    JOIN pcornet_trial_sc pt ON pt.patid = v.patid
    JOIN demographic_all da ON da.patid = pt.participantid;


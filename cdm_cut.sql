/**
 * CDM cut for DS-DETERMINED cohort
 */
DROP TABLE IF EXISTS condition;

CREATE TABLE condition AS
SELECT
    c.*
FROM
    cdm60_deid_dataset."condition" c
    JOIN pcornet_trial pt ON pt.patid = c.patid
WHERE
    pt.trialid = 'DS-DETERMINED';

DROP TABLE IF EXISTS death;

CREATE TABLE death AS
SELECT
    d.*
FROM
    cdm60_deid_dataset."death" d
    JOIN pcornet_trial pt ON pt.patid = d.patid
WHERE
    pt.trialid = 'DS-DETERMINED';

DROP TABLE IF EXISTS death_cause;

CREATE TABLE death_cause AS
SELECT
    d.*
FROM
    cdm60_deid_dataset."death_cause" d
    JOIN pcornet_trial pt ON pt.patid = d.patid
WHERE
    pt.trialid = 'DS-DETERMINED';

DROP TABLE IF EXISTS demographic;

CREATE TABLE demographic AS
SELECT
    d.*
FROM
    cdm60_deid_dataset."demographic" d
    JOIN pcornet_trial pt ON pt.patid = d.patid
WHERE
    pt.trialid = 'DS-DETERMINED';

DROP TABLE IF EXISTS diagnosis;

CREATE TABLE diagnosis AS
SELECT
    d.*
FROM
    cdm60_deid_dataset."diagnosis" d
    JOIN pcornet_trial pt ON pt.patid = d.patid
WHERE
    pt.trialid = 'DS-DETERMINED';

DROP TABLE IF EXISTS dispensing;

CREATE TABLE dispensing AS
SELECT
    d.*
FROM
    cdm60_deid_dataset."dispensing" d
    JOIN pcornet_trial pt ON pt.patid = d.patid
WHERE
    pt.trialid = 'DS-DETERMINED';

DROP TABLE IF EXISTS encounter;

CREATE TABLE encounter AS
SELECT
    e.*
FROM
    cdm60_deid_dataset."encounter" e
    JOIN pcornet_trial pt ON pt.patid = e.patid
WHERE
    pt.trialid = 'DS-DETERMINED';

DROP TABLE IF EXISTS enrollment;

CREATE TABLE enrollment AS
SELECT
    e.*
FROM
    cdm60_deid_dataset."enrollment" e
    JOIN pcornet_trial pt ON pt.patid = e.patid
WHERE
    pt.trialid = 'DS-DETERMINED';

DROP TABLE IF EXISTS immunization;

CREATE TABLE immunization AS
SELECT
    i.*
FROM
    cdm60_deid_dataset."immunization" i
    JOIN pcornet_trial pt ON pt.patid = i.patid
WHERE
    pt.trialid = 'DS-DETERMINED';

DROP TABLE IF EXISTS lab_result_cm;

CREATE TABLE lab_result_cm AS
SELECT
    l.*
FROM
    cdm60_deid_dataset."lab_result_cm" l
    JOIN pcornet_trial pt ON pt.patid = l.patid
WHERE
    pt.trialid = 'DS-DETERMINED';

DROP TABLE IF EXISTS lds_address_history;

CREATE TABLE lds_address_history AS
SELECT
    l.*
FROM
    cdm60_deid_dataset."lds_address_history" l
    JOIN pcornet_trial pt ON pt.patid = l.patid
WHERE
    pt.trialid = 'DS-DETERMINED';

DROP TABLE IF EXISTS med_admin;

CREATE TABLE med_admin AS
SELECT
    m.*
FROM
    cdm60_deid_dataset."med_admin" m
    JOIN pcornet_trial pt ON pt.patid = m.patid
WHERE
    pt.trialid = 'DS-DETERMINED';

DROP TABLE IF EXISTS obs_clin;

CREATE TABLE obs_clin AS
SELECT
    o.*
FROM
    cdm60_deid_dataset."obs_clin" o
    JOIN pcornet_trial pt ON pt.patid = o.patid
WHERE
    pt.trialid = 'DS-DETERMINED';

DROP TABLE IF EXISTS obs_gen;

CREATE TABLE obs_gen AS
SELECT
    o.*
FROM
    cdm60_deid_dataset."obs_gen" o
    JOIN pcornet_trial pt ON pt.patid = o.patid
WHERE
    pt.trialid = 'DS-DETERMINED';

DROP TABLE IF EXISTS prescribing;

CREATE TABLE prescribing AS
SELECT
    p.*
FROM
    cdm60_deid_dataset."prescribing" p
    JOIN pcornet_trial pt ON pt.patid = p.patid
WHERE
    pt.trialid = 'DS-DETERMINED';

DROP TABLE IF EXISTS PROCEDURES;

CREATE TABLE PROCEDURES AS
SELECT
    p.*
FROM
    cdm60_deid_dataset."procedures" p
    JOIN pcornet_trial pt ON pt.patid = p.patid
WHERE
    pt.trialid = 'DS-DETERMINED';

DROP TABLE IF EXISTS tumor;

CREATE TABLE tumor AS
SELECT
    t.*
FROM
    cdm60_deid_dataset."tumor" t
    JOIN pcornet_trial pt ON pt.patid = t.patid
WHERE
    pt.trialid = 'DS-DETERMINED';

DROP TABLE IF EXISTS vital;

CREATE TABLE vital AS
SELECT
    v.*
FROM
    cdm60_deid_dataset."vital" v
    JOIN pcornet_trial pt ON pt.patid = v.patid
WHERE
    pt.trialid = 'DS-DETERMINED';


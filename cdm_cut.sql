/**
 * CDM cut for DS-DETERMINED cohort
 */
DROP TABLE condition;

CREATE TABLE condition AS
SELECT
    c.*
FROM
    cdm60_deid_dataset."condition" c
    JOIN pcornet_trial pt ON pt.patid = c.patid;

DROP TABLE death;

CREATE TABLE death AS
SELECT
    d.*
FROM
    cdm60_deid_dataset."death" d
    JOIN pcornet_trial pt ON pt.patid = d.patid;

DROP TABLE death_cause;

CREATE TABLE death_cause AS
SELECT
    d.*
FROM
    cdm60_deid_dataset."death_cause" d
    JOIN pcornet_trial pt ON pt.patid = d.patid;

DROP TABLE demographic;

CREATE TABLE demographic AS
SELECT
    d.*
FROM
    cdm60_deid_dataset."demographic" d
    JOIN pcornet_trial pt ON pt.patid = d.patid;

DROP TABLE diagnosis;

CREATE TABLE diagnosis AS
SELECT
    d.*
FROM
    cdm60_deid_dataset."diagnosis" d
    JOIN pcornet_trial pt ON pt.patid = d.patid;

DROP TABLE dispensing;

CREATE TABLE dispensing AS
SELECT
    d.*
FROM
    cdm60_deid_dataset."dispensing" d
    JOIN pcornet_trial pt ON pt.patid = d.patid;

DROP TABLE encounter;

CREATE TABLE encounter AS
SELECT
    e.*
FROM
    cdm60_deid_dataset."encounter" e
    JOIN pcornet_trial pt ON pt.patid = e.patid;

DROP TABLE enrollment;

CREATE TABLE enrollment AS
SELECT
    e.*
FROM
    cdm60_deid_dataset."enrollment" e
    JOIN pcornet_trial pt ON pt.patid = e.patid;

DROP TABLE immunization;

CREATE TABLE immunization AS
SELECT
    i.*
FROM
    cdm60_deid_dataset."immunization" i
    JOIN pcornet_trial pt ON pt.patid = i.patid;

DROP TABLE lab_result_cm;

CREATE TABLE lab_result_cm AS
SELECT
    l.*
FROM
    cdm60_deid_dataset."lab_result_cm" l
    JOIN pcornet_trial pt ON pt.patid = l.patid;

DROP TABLE lds_address_history;

CREATE TABLE lds_address_history AS
SELECT
    l.*
FROM
    cdm60_deid_dataset."lds_address_history" l
    JOIN pcornet_trial pt ON pt.patid = l.patid;

DROP TABLE med_admin;

CREATE TABLE med_admin AS
SELECT
    m.*
FROM
    cdm60_deid_dataset."med_admin" m
    JOIN pcornet_trial pt ON pt.patid = m.patid;

DROP TABLE obs_clin;

CREATE TABLE obs_clin AS
SELECT
    o.*
FROM
    cdm60_deid_dataset."obs_clin" o
    JOIN pcornet_trial pt ON pt.patid = o.patid;

DROP TABLE obs_gen;

CREATE TABLE obs_gen AS
SELECT
    o.*
FROM
    cdm60_deid_dataset."obs_gen" o
    JOIN pcornet_trial pt ON pt.patid = o.patid;

DROP TABLE prescribing;

CREATE TABLE prescribing AS
SELECT
    p.*
FROM
    cdm60_deid_dataset."prescribing" p
    JOIN pcornet_trial pt ON pt.patid = p.patid;

DROP TABLE PROCEDURES;

CREATE TABLE PROCEDURES AS
SELECT
    p.*
FROM
    cdm60_deid_dataset."procedures" p
    JOIN pcornet_trial pt ON pt.patid = p.patid;

DROP TABLE tumor;

CREATE TABLE tumor AS
SELECT
    t.*
FROM
    cdm60_deid_dataset."tumor" t
    JOIN pcornet_trial pt ON pt.patid = t.patid;

DROP TABLE vital;

CREATE TABLE vital AS
SELECT
    v.*
FROM
    cdm60_deid_dataset."vital" v;

JOIN pcornet_trial pt ON pt.patid = t.patid;


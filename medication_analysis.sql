/**
 * Find Medication classes
 */
-- Antipsychotics Med
DROP TABLE IF EXISTS antipsychotics_med;

CREATE TABLE antipsychotics_med AS SELECT DISTINCT
    patid,
    1 AS Antipsychotics
FROM
    fh_export_i2b2_crc.concept_dimension
    JOIN prescribing_all p ON p.rxnorm_cui = split_part(concept_cd, ':', 2)
    JOIN consented c ON c.record_id = p.patid
WHERE
    concept_path LIKE '\\ACT\\Medications\\MedicationsByVaClass\\V2_09302018\\N0000029132\\N0000029150\\%';

-- Benzodiazepine Med
DROP TABLE IF EXISTS benzodiazepine_med;

CREATE TABLE benzodiazepine_med AS SELECT DISTINCT
    patid,
    1 AS Benzodiazepine
FROM
    fh_export_i2b2_crc.concept_dimension
    JOIN prescribing_all p ON p.rxnorm_cui = split_part(concept_cd, ':', 2)
    JOIN consented c ON c.record_id = p.patid
WHERE
    concept_path LIKE '\\ACT\\Medications\\MedicationsByVaClass\\V2_09302018\\N0000029132\\N0000029143\\N0000029144\\%';

-- Antidepressants Med
DROP TABLE IF EXISTS Antidepressants_med;

CREATE TABLE Antidepressants_med AS SELECT DISTINCT
    patid,
    1 AS Antidepressants
FROM
    fh_export_i2b2_crc.concept_dimension
    JOIN prescribing_all p ON p.rxnorm_cui = split_part(concept_cd, ':', 2)
    JOIN consented c ON c.record_id = p.patid
WHERE
    concept_path LIKE '\\ACT\\Medications\\MedicationsByVaClass\\V2_09302018\\N0000029132\\N0000029147\\%';

-- Anticonvulsants Med
DROP TABLE IF EXISTS Anticonvulsants_med;

CREATE TABLE Anticonvulsants_med AS SELECT DISTINCT
    patid,
    1 AS Anticonvulsants
FROM
    fh_export_i2b2_crc.concept_dimension
    JOIN prescribing_all p ON p.rxnorm_cui = split_part(concept_cd, ':', 2)
    JOIN consented c ON c.record_id = p.patid
WHERE
    concept_path LIKE '\\ACT\\Medications\\MedicationsByVaClass\\V2_09302018\\N0000029132\\N0000029145\\%';

DROP TABLE IF EXISTS med;

CREATE TABLE med AS
SELECT
    da.patid,
    benzodiazepine,
    antipsychotics,
    Antidepressants,
    Anticonvulsants,
    SDI.*
FROM
    demographic_all da
    JOIN consented c ON c.record_id = da.patid
    LEFT JOIN antipsychotics_med psy ON da.patid = psy.patid
    LEFT JOIN benzodiazepine_med benzo ON da.patid = benzo.patid
    LEFT JOIN Antidepressants_med dep ON da.patid = dep.patid
    LEFT JOIN Anticonvulsants_med con ON da.patid = con.patid
    JOIN sdi ON sdi.record_id = da.patid
WHERE
    c.ehr_access_agree = 1;

UPDATE
    med
SET
    antipsychotics = 0
WHERE
    antipsychotics IS NULL;

UPDATE
    med
SET
    benzodiazepine = 0
WHERE
    benzodiazepine IS NULL;

UPDATE
    med
SET
    Antidepressants = 0
WHERE
    Antidepressants IS NULL;

UPDATE
    med
SET
    Anticonvulsants = 0
WHERE
    Anticonvulsants IS NULL;

COMMIT;

UPDATE
    med
SET
    DEMOG15 = NULL
WHERE
    DEMOG15 = 255;

UPDATE
    med
SET
    SDI_DSC6 = NULL
WHERE
    SDI_DSC6 = 255;

UPDATE
    med
SET
    SDI_DSC6 = NULL
WHERE
    SDI_DSC6 = 200;

UPDATE
    med
SET
    DEMOG14A = NULL
WHERE
    DEMOG14A = 200;

COMMIT;

-- create analytical file for SPSS
SELECT
    Antipsychotics,
    Benzodiazepine,
    Antidepressants,
    Anticonvulsants,
    Antipsychotics + Benzodiazepine + Antidepressants + Anticonvulsants AS Medications_all,
    CASE WHEN Antipsychotics + Benzodiazepine + Antidepressants + Anticonvulsants > 0 THEN
        1
    ELSE
        0
    END AS Medications_all_binary,
    /*(CHAR_LENGTH(Antipsychotics ||Benzodiazepine||Antidepressants||Anticonvulsants) - CHAR_LENGTH(REPLACE(Antipsychotics||Benzodiazepine||Antidepressants||Anticonvulsants, 'Yes', ''))) 
/ CHAR_LENGTH('Yes') as Medications_all,*/
    DEMOG14 AS living_size,
    DEMOG14A AS ppl_dont_like,
    CASE WHEN DEMOG14 = 1 THEN
        'On my own'
    WHEN DEMOG14 = 2 THEN
        'With family member(s)'
    WHEN DEMOG14 = 3 THEN
        'Group setting'
    WHEN DEMOG14 = 4 THEN
        'Other'
    END AS Living,
    CASE WHEN DEMOG14A = 1 THEN
        'Small (1-3 people)'
    WHEN DEMOG14A = 2 THEN
        'Medium (4-6 people)'
    WHEN DEMOG14A = 3 THEN
        'Large (7-16 people)'
    WHEN DEMOG14A = 4 THEN
        'Very large (more than 16 people)'
    END AS Living_setting,
    CASE WHEN DEMOG15 = 1 THEN
        'Full-time'
    WHEN DEMOG15 = 2 THEN
        'Part-time'
    WHEN DEMOG15 = 3 THEN
        'Paid job in a sheltered work program'
    WHEN DEMOG15 = 4 THEN
        'Paid internship'
    WHEN DEMOG15 = 5 THEN
        'Unpaid internship/volunteer'
    WHEN DEMOG15 = 6 THEN
        'Currently looking for a job'
    WHEN DEMOG15 = 7 THEN
        'Not working'
    WHEN DEMOG15 = 8 THEN
        'Retired'
    WHEN DEMOG15 = 9 THEN
        'Other'
    END AS Employment,
    SDI_DSC6 AS Room_Choice,
    overall_sdi,
    CASE WHEN overall_sdi >= 50 THEN
        1
    ELSE
        0
    END AS overall_sdi_cat,
    CASE WHEN SDI_DSC6 >= 50 THEN
        1
    ELSE
        0
    END AS Room_Choice_cat,
    antipsychotics + benzodiazepine + Antidepressants + Anticonvulsants AS med_all
FROM
    med;


/*
DEMOG14	Where do you live? 1=On my own; 2=With family member(s) (spouse/partner, sibling, parent, grandparent, child etc.); 3=Group setting (e.g., group home, shared living); 4=Other   
DEMOG14A With people who I did not choose (please describe) 1=Small setting (1-3 people); 2=Medium setting (4-6 people); 3=Large setting (7-16 people); 4=Very large setting (more than 16 people)   
SDI_DSC6_R	I choose what my room looks like. response on scale of 0-99;  255=not answered; 200=question not presented to participant
What is your current employment status?	1=Full-time; 2=Part-time; 3=Paid job in a sheltered work program; 4=Paid internship; 5=Unpaid internship/volunteer; 6=Currently looking for a job; 7=Not working; 8=Retired; 9=Other
 */
---------------------------------------------
-------- Number of Medication classes Figure
---------------------------------------------
SELECT
    Antipsychotics + Benzodiazepine + Antidepressants + Anticonvulsants AS Medications_all,
    count(*),
    avg(overall_sdi)
FROM
    med
GROUP BY
    Medications_all;


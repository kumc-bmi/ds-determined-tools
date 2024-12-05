/*
 * This file finds shows stats reagrding Ds-connect vs CDM completeness in diagnosis data
 */
SET search_path TO hb_workspace;

drop table if exists dx_summary;
CREATE TABLE if not exists dx_summary (
	key_name text NOT NULL,
	avg_sdi numeric,
	stdev_sdi numeric,
	min_sdi numeric,
	max_sdi numeric,
	n numeric,
	percentage_sdi numeric,
	manual_squery_n numeric,
	timestamp timestamp default current_timestamp
);

insert into dx_summary
select
	'sdi_all' as key_name,
    avg(overall_sdi) as avg_sdi,
	stddev(overall_sdi) as stdev_sdi,
	min(overall_sdi) as min_sdi,
	max(overall_sdi) as max_sdi,
	count(overall_sdi) as cnt
from
	sdi;

-------------------------
---find patient that have
---dementia, alzahimre, cognitive decline
---from CDM and DS connect
-------------------------
-- CDM

insert into dx_summary
select
	'Cognitive - CDM' as key_name,
    avg(overall_sdi) as avg_sdi,
	stddev(overall_sdi) as stdev_sdi,
	min(overall_sdi) as min_sdi,
	max(overall_sdi) as max_sdi,
	count(overall_sdi) as cnt,
	null as percentage_sdi, --round(count(overall_sdi)::numeric/91*100,2) as percentage_sdi,
	6 as manual_squery_cnt
from
	sdi
where record_id in (	
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
--6
);
-- DS-connect
insert into dx_summary
select
	'Cognitive - DS' as key_name,
    avg(overall_sdi) as avg_sdi,
	stddev(overall_sdi) as stdev_sdi,
	min(overall_sdi) as min_sdi,
	max(overall_sdi) as max_sdi,
	count(overall_sdi) as cnt,
	null as percentage_sdi, --round(count(overall_sdi)::numeric/91*100,2) as percentage_sdi,
	9 as manual_squery_cnt
from
	sdi
where record_id in (
    SELECT
        col4
--        ,col224,
--        col327,
--        col328,
--        col329,
--        col941
    FROM
        ds_connect dc
        JOIN consented c ON c.record_id = dc.col4
    WHERE
        c.dsconnect_access_agree = 1
        AND col224 != 'No'
        AND (length(col224) > 10
        OR col327 = 'Yes')
    --12 (or 9?)
);


/** DS connect columns(col224, col327, col328, col329, col941): 
 * Has the participant ever been diagnosed with Dementia, Alzheimer's disease, or cognitive decline?
 * Has the participant ever been diagnosed with Dementia, Alzheimer's disease, or cognitive decline?_Adult
 * What was the age of the participant at the earliest onset of dementia symptoms?
 * What was the age of the participant at diagnosis of Dementia, Alzheimer's disease, or cognitive decline?
 * If the participant has had a brain imaging study, what was the reason for obtaining the study? (Select all that apply.) - Symptoms of dementia
 */
-- find the patient in CDM or DS-connect patients
insert into dx_summary
select
	'Cognitive - CDM or DS' as key_name,
    avg(overall_sdi) as avg_sdi,
	stddev(overall_sdi) as stdev_sdi,
	min(overall_sdi) as min_sdi,
	max(overall_sdi) as max_sdi,
	count(overall_sdi) as cnt,
	null as percentage_sdi, --round(count(overall_sdi)::numeric/91*100,2) as percentage_sdi,
	11 as manual_squery_cnt
from
	sdi
where record_id in (
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
UNION
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
--11
);

-- find the intersection between CDM and DS-connect patients
insert into dx_summary
select
	'Cognitive - CDM & DS' as key_name,
    avg(overall_sdi) as avg_sdi,
	stddev(overall_sdi) as stdev_sdi,
	min(overall_sdi) as min_sdi,
	max(overall_sdi) as max_sdi,
	count(overall_sdi) as cnt,
	null as percentage_sdi, --round(count(overall_sdi)::numeric/91*100,2) as percentage_sdi,
	4 as manual_squery_cnt
from
	sdi
where record_id in (
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
--4
);


    -------------------------
    ---find patient that have
    ---Sleep Apnea
    ---from CDM and DS connect
    -------------------------
    -- CDM
insert into dx_summary
select
	'Sleep Apnea - CDM' as key_name,
	avg(overall_sdi) as avg_sdi,
	stddev(overall_sdi) as stdev_sdi,
	min(overall_sdi) as min_sdi,
	max(overall_sdi) as max_sdi,
	count(overall_sdi) as cnt,
	null as percentage_sdi, --round(count(overall_sdi)::numeric/91*100,2) as percentage_sdi,
	51 as manual_squery_cnt
	from sdi
where record_id in (
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
   --51
   );
   -- DS-connect
insert into dx_summary
select
	'Sleep Apnea - DS' as key_name,
	avg(overall_sdi) as avg_sdi,
	stddev(overall_sdi) as stdev_sdi,
	min(overall_sdi) as min_sdi,
	max(overall_sdi) as max_sdi,
	count(overall_sdi) as cnt,
	null as percentage_sdi, --round(count(overall_sdi)::numeric/91*100,2) as percentage_sdi,
	57 as manual_squery_cnt
	from sdi
where record_id in (
        SELECT
            col4
--            ,col91,
--            col487
        FROM
            ds_connect dc
            JOIN consented c ON c.record_id = dc.col4
        WHERE
            c.dsconnect_access_agree = 1
            AND col91 = '1'
);


/* DS connect columns (col91, col487):
 * Which of the following sleep problems have been diagnosed? (Select all that apply.) - Sleep apnea
 * Has a doctor ever diagnosed the participant with sleep apnea based on a sleep study?
 * 
 */
-- find the UNION(not intersection) between CDM and DS-connect patients
insert into dx_summary
select
	'Sleep Apnea - CDM or DS' as key_name,
	avg(overall_sdi) as avg_sdi,
	stddev(overall_sdi) as stdev_sdi,
	min(overall_sdi) as min_sdi,
	max(overall_sdi) as max_sdi,
	count(overall_sdi) as cnt,
	null as percentage_sdi, --round(count(overall_sdi)::numeric/91*100,2) as percentage_sdi,
	68 as manual_squery_cnt
	from sdi
where record_id in (
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
    AND col91 = '1'
--68
);

-- find the intersection between CDM and DS-connect patients
insert into dx_summary
select
	'Sleep Apnea - CDM & DS' as key_name,
	avg(overall_sdi) as avg_sdi,
	stddev(overall_sdi) as stdev_sdi,
	min(overall_sdi) as min_sdi,
	max(overall_sdi) as max_sdi,
	count(overall_sdi) as cnt,
	null as percentage_sdi, --round(count(overall_sdi)::numeric/91*100,2) as percentage_sdi,
	40 as manual_squery_cnt
	from sdi
where record_id in (
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
INTERSECT
SELECT
    col4
FROM
    ds_connect dc
    JOIN consented c ON c.record_id = dc.col4
WHERE
    c.dsconnect_access_agree = 1
    AND col91 = '1'
--40
);


-------------------------
---find patient that have
---Diabetes
---from CDM and DS connect
-------------------------
-- CDM
insert into dx_summary
select
	'Diabetes - CDM' as key_name,
	avg(overall_sdi) as avg_sdi,
	stddev(overall_sdi) as stdev_sdi,
	min(overall_sdi) as min_sdi,
	max(overall_sdi) as max_sdi,
	count(overall_sdi) as cnt,
	null as percentage_sdi, --round(count(overall_sdi)::numeric/91*100,2) as percentage_sdi,
	10 as manual_squery_cnt
	from sdi
where record_id in (
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
--10       
);
-- DS-connect
insert into dx_summary
select
	'Diabetes - DS' as key_name,
	avg(overall_sdi) as avg_sdi,
	stddev(overall_sdi) as stdev_sdi,
	min(overall_sdi) as min_sdi,
	max(overall_sdi) as max_sdi,
	count(overall_sdi) as cnt,
	null as percentage_sdi, --round(count(overall_sdi)::numeric/91*100,2) as percentage_sdi,
	6 as manual_squery_cnt
	from sdi
where record_id in (
    SELECT
        col4
--        ,col132,
--        col735
    FROM
        ds_connect dc
        JOIN consented c ON c.record_id = dc.col4
    WHERE
        c.dsconnect_access_agree = 1
        AND col132 = 'Yes'
    --6
);

/* DS connect columns (col132, col735):
 * Has the participant ever been diagnosed with diabetes?
 * Did the participant's mother have any of the following conditions or treatments during her pregnancy with the participant? (Select all that apply.) - Gestational diabetes (diabetes during pregnancy)
 */
-- find the union between CDM and DS-connect patients
insert into dx_summary
select
	'Diabetes - CDM or DS' as key_name,
	avg(overall_sdi) as avg_sdi,
	stddev(overall_sdi) as stdev_sdi,
	min(overall_sdi) as min_sdi,
	max(overall_sdi) as max_sdi,
	count(overall_sdi) as cnt,
	null as percentage_sdi, --round(count(overall_sdi)::numeric/91*100,2) as percentage_sdi,
	10 as manual_squery_cnt
	from sdi
where record_id in (
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
union
SELECT DISTINCT
    dc.col4
FROM
    ds_connect dc
    JOIN consented c ON c.record_id = dc.col4
WHERE
    c.dsconnect_access_agree = 1
    AND col132 = 'Yes'
--10
);
   
-- find the intersection between CDM and DS-connect patients
insert into dx_summary
select
	'Diabetes - CDM and DS' as key_name,
	avg(overall_sdi) as avg_sdi,
	stddev(overall_sdi) as stdev_sdi,
	min(overall_sdi) as min_sdi,
	max(overall_sdi) as max_sdi,
	count(overall_sdi) as cnt,
	null as percentage_sdi, --round(count(overall_sdi)::numeric/91*100,2) as percentage_sdi,
	6 as manual_squery_cnt
	from sdi
where record_id in (
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
    AND col132 = 'Yes'
--6
);

-------------------------
---find patient that have
---Depression
---from CDM and DS connect
-------------------------
--CDM
insert into dx_summary
select
	'Depression - CDM' as key_name,
	avg(overall_sdi) as avg_sdi,
	stddev(overall_sdi) as stdev_sdi,
	min(overall_sdi) as min_sdi,
	max(overall_sdi) as max_sdi,
	count(overall_sdi) as cnt,
	null as percentage_sdi, --round(count(overall_sdi)::numeric/91*100,2) as percentage_sdi,
	15 as manual_squery_cnt
	from sdi
where record_id in (
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
);
    -- DS-connect
insert into dx_summary
select
	'Depression - DS' as key_name,
	avg(overall_sdi) as avg_sdi,
	stddev(overall_sdi) as stdev_sdi,
	min(overall_sdi) as min_sdi,
	max(overall_sdi) as max_sdi,
	count(overall_sdi) as cnt,
	null as percentage_sdi, --round(count(overall_sdi)::numeric/91*100,2) as percentage_sdi,
	21 as manual_squery_cnt
	from sdi
where record_id in (
    select
    	col4
--        ,col192,
--        col198,
--        col319,
--        col897,
--        col909
    FROM
        ds_connect dc
        JOIN consented c ON c.record_id = dc.col4
    WHERE
        c.dsconnect_access_agree = 1
        AND (col192 = '1'
            OR col198 = '1'
            OR col897 = 'Currently a problem'
            OR col909 = 'Currently a problem')
--21           
);            
        /* DS connect columns (col192, col198, col319, col897, col909):
         * Has the participant ever been diagnosed with any of the following behavioral or mental health conditions? (Select all that apply.) - Depression
         * Has the participant ever been diagnosed with any of the following behavioral or mental health conditions? (Select all that apply.) - Bipolar/manic depression
         * What is the status and age at diagnosis for each of these conditions? (Select all that apply.) - Depression - Status
         * For the following behavioral or mental health conditions, select the status and age in years at diagnosis for the participant. (Select all that apply) - Depression - Status
         * For the following behavioral or mental health conditions, select the status and age in years at diagnosis for the participant. (Select all that apply) - Bipolar/manic depression - Status
         * 
         */
        -- find the union between CDM and DS-connect patients
insert into dx_summary
select
	'Depression - CDM or DS' as key_name,
	avg(overall_sdi) as avg_sdi,
	stddev(overall_sdi) as stdev_sdi,
	min(overall_sdi) as min_sdi,
	max(overall_sdi) as max_sdi,
	count(overall_sdi) as cnt,
	null as percentage_sdi, --round(count(overall_sdi)::numeric/91*100,2) as percentage_sdi,
	29 as manual_squery_cnt
	from sdi
where record_id in (
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
        union
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
--29
);

        -- find the intersection between CDM and DS-connect patients
insert into dx_summary
select
	'Depression - CDM & DS' as key_name,
	avg(overall_sdi) as avg_sdi,
	stddev(overall_sdi) as stdev_sdi,
	min(overall_sdi) as min_sdi,
	max(overall_sdi) as max_sdi,
	count(overall_sdi) as cnt,
	null as percentage_sdi, --round(count(overall_sdi)::numeric/91*100,2) as percentage_sdi,
	7 as manual_squery_cnt
	from sdi
where record_id in (
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
--7
);
commit;
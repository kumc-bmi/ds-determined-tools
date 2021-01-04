/** ds_pcornet_cdm_slice -- export slice of PCORNet CDM for DS-DETERMINED consented cohort.

  "We will only access data on
   diagnosis, procedures, condition, medications, vital signs, and provider."
    -- IRB consent docs 8/27/2020 3:28 PM

*/

-- dependencies:
select record_id from ds_consented_match where 'dep' = 'ds_consented_cohort_match.sql';
select patid from pcornet_cdm.demographic where 'dep' = 'PCORNet CDM ETL';

whenever sqlerror continue;
drop table diagnosis_ds;
drop table procedures_ds;
drop table condition_ds;
drop table prescribing_ds;
drop table med_admin_ds;
drop table vital_ds;
whenever sqlerror exit;

create table     diagnosis_ds compress nologging as select *
from pcornet_cdm.diagnosis
where patid in (select patient_num from ds_consented_match);

-- QC:
select xwalk.record_id, dx.*, dxm.c_name, dxm.c_fullname from (
select patid, dx_type, dx, min(dx_date), max(dx_date)
from diagnosis_ds
group by patid, dx_type, dx
) dx
join pcorimetadata.pcornet_diag dxm on
  dxm.pcori_basecode = dx.dx
  and dxm.c_basecode = 'ICD' || dx.dx_type || ':' || dx.dx
join ds_consented_match xwalk on xwalk.patient_num = dx.patid
order by record_id, patid, dx_type, dx
;


create table     procedures_ds compress nologging as select *
from pcornet_cdm.procedures
where patid in (select patient_num from ds_consented_match);

create table     condition_ds compress nologging as select *
from pcornet_cdm.condition
where patid in (select patient_num from ds_consented_match);

create table     prescribing_ds compress nologging as select *
from pcornet_cdm.prescribing
where patid in (select patient_num from ds_consented_match);
create table     med_admin_ds compress nologging as select *
from pcornet_cdm.med_admin
where patid in (select patient_num from ds_consented_match);

create table     vital_ds compress nologging as select *
from pcornet_cdm.vital
where patid in (select patient_num from ds_consented_match);

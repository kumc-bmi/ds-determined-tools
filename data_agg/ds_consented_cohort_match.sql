/** ds_consented_cohort_match - match EHR records with consented participants

This is a semi-automated process, subject to manual review.

*/

create table ds_consented_match as
select subj.record_id, subj.ehr_access_agree
     , subj.email_recruit
     , pd.mrn, pd.patient_num
     , subj.last_name_ds, subj.first_name_ds
     , pd.pat_name
     , pd.birth_date, pd.sex_cd
from ds_consented subj
left join nightherondata.patient_dimension pd on pd.email_address = subj.email_recruit
order by subj.record_id
;


-- QC:
select * from ds_consented_match;
-- of 5 subjects, currently: 4 matches + 1 dup.

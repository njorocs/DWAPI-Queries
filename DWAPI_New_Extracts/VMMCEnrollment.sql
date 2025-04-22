#VMMC Enrollment
select e.patient_id                                       as PatientPK,
       ''                                                 as PatientPKHash,
       e.uuid                                             as uuid,
       s.siteCode                                         as SiteCode,
       d.unique_patient_no                                as VMMCId,
       ''                                                 as VMMCIdHash,
       0                                                  as FacilityId,
       'KenyaEMR'                                         as Emr,
       'Kenya HMIS III'                                   as Project,
       s.FacilityName                                     as FacilityName,
       e.visit_date                                       as EncounterDate,
       case e.referee
           when 165650 then 'Self referral'
           when 163488 then 'Community Health Volunteer'
           when 5619 then 'Health Care Worker'
           when 1370 then 'HTS Counsellors'
           when 5622 then e.other_referee end             as ReferredBy,
       case e.source_of_vmmc_info
           when 167096 then 'Print Media'
           when 160542 then 'OPD/MCH/HT'
           when 1555 then 'Mobilizer CHW'
           when 167097 then 'Social Media'
           when 167098 then '"Road Show'
           when 167095 then '"Radio/Tv'
           when 5622 then e.other_source_of_vmmc_info end as SourceVMMCInformation,
       e.county_of_origin                                 as CountyofOrigin,
       e.date_created                                     as Date_Created,
       e.date_last_modified                               as Date_Last_Modified,
       e.voided                                           as voided
from dwapi_etl.etl_vmmc_enrolment e
         inner join dwapi_etl.etl_patient_demographics d on e.patient_id = d.patient_id
         join kenyaemr_etl.etl_default_facility_info s;



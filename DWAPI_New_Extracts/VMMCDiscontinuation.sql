#VMMC Discontinuation
select di.patient_id                                              as PatientPK,
       ''                                                         as PatientPKHash,
       di.uuid                                                    as uuid,
       s.siteCode                                                 as SiteCode,
       d.unique_patient_no                                        as VMMCId,
       ''                                                         as VMMCIdHash,
       0                                                          as FacilityId,
       'KenyaEMR'                                                 as Emr,
       'Kenya HMIS III'                                           as Project,
       s.FacilityName                                             as FacilityName,
       coalesce(di.effective_discontinuation_date, di.visit_date) as DiscontinuationDate,
       case di.discontinuation_reason
           when 162130 then 'Patient has healed'
           when 112992 then 'STI'
           when 159766 then '"Client has condition hindering them from going through VMMC'
           when 159808 then 'Consent is not provided'
           when 159492 then 'Transferred Out'
           when 160034 then 'Died'
           when 138405 then 'Newly Diagnosed HIV'
           when 160067
               then 'Assent is not provided' end                  as Reason,
       di.date_created                                            as Date_Created,
       di.date_last_modified                                      as Date_Last_Modified,
       di.voided                                                  as voided
from dwapi_etl.etl_patient_program_discontinuation di
         inner join dwapi_etl.etl_patient_demographics d on di.patient_id = d.patient_id
         join kenyaemr_etl.etl_default_facility_info s
where di.program_name = 'VMMC';



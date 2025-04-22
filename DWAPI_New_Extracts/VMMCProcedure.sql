#VMMC CIRCUMCISION PROCEDURE EXTRACT
select p.patient_id                                                                      as PatientPK,
       ''                                                                                as PatientPKHash,
       p.uuid                                                                            as uuid,
       s.siteCode                                                                        as SiteCode,
       d.unique_patient_no                                                               as VMMCId,
       ''                                                                                as VMMCIdHash,
       0                                                                                 as FacilityId,
       'KenyaEMR'                                                                        as Emr,
       'Kenya HMIS III'                                                                  as Project,
       s.FacilityName                                                                    as FacilityName,
       p.visit_date                                                                      as EncounterDate,

       p.date_created                                                                    as Date_Created,
       p.date_last_modified                                                              as Date_Last_Modified,
       p.voided                                                                          as voided
from dwapi_etl.etl_vmmc_circumcision_procedure p
         inner join dwapi_etl.etl_patient_demographics d on p.patient_id = d.patient_id
         join kenyaemr_etl.etl_default_facility_info s;



select d.patient_id         as PatientPK,
       l.uuid               as uuid,
       i.siteCode           as SiteCode,
       d.openmrs_id         as PatientMNCH_ID,
       ''                   as FacilityID,
       'KenyaEMR'           as Emr,
       'Kenya HMIS II'      as Project,
       i.FacilityName       as FacilityName,
       ''                   as SatelliteName,
       l.visit_id           as VisitID,
       l.sample_date        as OrderedByDate,
       l.results_date       as ReportedByDate,
       l.lab_test           as TestName,
       l.urgency      as OrderUrgency,
       l.test_result        as TestResult,
       l.order_reason       as LabReason,
       l.date_created       as Date_Created,
       l.date_last_modified as Date_Last_Modified,
       l.voided             as voided
from dwapi_etl.etl_patient_demographics d
         inner join (select l.patient_id,
                            l.uuid,
                            l.visit_id,
                            l.date_test_requested                                                      as sample_date,
                            l.date_test_result_received                                                as results_date,
                            case l.lab_test when 1305 then 'HIV VIRAL LOAD' else l.order_test_name end as lab_test,
                            l.urgency                                                                  as order_urgency,
                            l.order_reason_name                                                           order_reason,
                            l.result_name                                                              as test_result,
                            l.date_created,
                            l.date_last_modified,
                            l.voided
                     from dwapi_etl.etl_laboratory_extract l
                     where l.test_result <> ''
                       and l.test_result is not null) l on d.patient_id = l.patient_id
         join kenyaemr_etl.etl_default_facility_info i;

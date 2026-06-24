#Lab extracts for C&T
select ''                                                        AS SatelliteName,
       0                                                         AS FacilityId,
       d.unique_patient_no                                       as PatientID,
       l.uuid                                                    as uuid,
       d.patient_id                                              as PatientPK,
       l.encounter_id                                            as VisitId,
       coalesce(DATE(l.date_test_requested), DATE(l.visit_date)) as OrderedByDate,
       DATE(l.date_test_result_received)                         as ReportedByDate,
       i.siteCode                                                as SiteCode,
       i.facilityName                                            as FacilityName,
       (case l.lab_test
            when 1305 then 'HIV VIRAL LOAD'
            else l.order_test_name
           end)                                                  as TestName,
       date(l.date_test_requested)                               as DateSampleTaken,
       l.order_reason_name                                       as Reason,
       l.result_name                                             as TestResult,
       NULL                                                      as EnrollmentTest,
       o.sample_type                                             as SampleType,
       'KenyaEMR'                                                as Emr,
       'Kenya HMIS II'                                           as Project,
       l.date_created                                            as Date_Created,
       l.date_last_modified                                      as Date_Last_Modified,
       l.voided                                                  as voided
from dwapi_etl.etl_laboratory_extract l
         left join openmrs.kenyaemr_order_entry_lab_manifest_order o on l.order_id = o.order_id
         join dwapi_etl.etl_patient_demographics d on d.patient_id = l.patient_id
         join kenyaemr_etl.etl_default_facility_info i
where l.test_result <> ''
  and l.test_result is not null;
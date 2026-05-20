SELECT r.patient_id            as PatientPK,
       i.siteCode              as SiteCode,
       i.FacilityName          as FacilityName,
       'KenyaEMR'              as Emr,
       ''                      as EMRVersion,
       'Kenya HMIS RTC'        as Project,
       r.source_system_uuid    as SourceSysUUID,
       r.rtc_risk_score        as RtcRiskScore,
       r.rtc_category          as RtcRiskCategory,
       r.rtc_evaluation_date   as RtcEvaluationDate,
       r.date_created          as DateCreated,
       r.date_changed          as DateLastModified,
       r.voided                as voided,
       r.model_version         as ModelVersion
FROM openmrs.kenyaemr_ml_patient_risk_score r
         inner join dwapi_etl.etl_patient_demographics d on d.patient_id = r.patient_id
         join kenyaemr_etl.etl_default_facility_info i;

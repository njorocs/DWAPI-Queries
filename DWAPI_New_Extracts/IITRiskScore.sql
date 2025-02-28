SELECT r.patient_id            as PatientPK,
       i.siteCode              as SiteCode,
       i.FacilityName          as FacilityName,
       'KenyaEMR'              as Emr,
       ''                      as EMRVersion,
       'Kenya HMIS III'        as Project,
       r.source_system_uuid    as SourceSysUUID,
       r.risk_score            as RiskScore,
       r.risk_factors          as RiskFactors,
       r.description           as Description,
       r.evaluation_date       as EvaluationDate,
       e.latest_visit_date     as VisitDate,
       e.next_appointment_date as NextAppointmentDate,
       r.date_created          as DateCreated,
       r.date_changed          as DateLastModified,
       r.voided                as voided
FROM openmrs.kenyaemr_ml_patient_risk_score r
         inner join dwapi_etl.etl_patient_demographics d on d.patient_id = r.patient_id
         inner join(select f.patient_id,
                           max(f.visit_date)                                           as latest_visit_date,
                           mid(max(concat(f.visit_date, f.next_appointment_date)), 11) as next_appointment_date
                    from dwapi_etl.etl_patient_hiv_followup f
                    group by f.patient_id) e on r.patient_id = e.patient_id
         join kenyaemr_etl.etl_default_facility_info i;

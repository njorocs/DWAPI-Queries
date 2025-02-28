select d.openmrs_id                                                              PatientPK,
       f.uuid                                                                 as uuid,
       i.siteCode                                                                SiteCode,
       d.unique_patient_no                                                       PatientID,
       'KenyaEMR'                                                                Emr,
       'Kenya HMIS II'                                                           Project,
       i.facilityName                                                            FacilityName,
       f.visit_id                                                                VisitId,
       f.visit_date                                                              Covid19AssessmentDate,
       f.encounter_id                                                         as EncounterId,
       (case f.tracing_type
            when 1650 then 'Client Called'
            when 164965 then 'Physical Tracing'
            when 161642 then 'Treatment supporter' end)                       as TracingType,
       (case f.tracing_outcome
            when 1267 then 'Contact'
            when 1118 then 'No contact' end)                                  as TracingOutcome,
       f.attempt_number                                                       as AttemptNumber,
       (case f.is_final_trace when 1267 then 'Yes' when 163339 then 'No' end) as IsFinalTrace,
       if(f.is_final_trace = 1267, f.visit_date,null)                              as DateofOutcome,
       (case f.tracing_outcome
            when 165610 then 'COVID19 Positive'
            when 160432 then 'Dead'
            when 1693 then 'Receiving ART from another clinic/Transferred'
            when 160037 then 'Still in care at CCC'
            when 5240 then 'Lost to follow up'
            when 164435 then 'Stopped treatment' end)                         as TrueStatus,
       (case f.reason_for_missed_appointment
            when 165609 then 'Client has covid-19 infection'
            when 165610 then 'COVID-19 restrictions'
            when 164407 then 'Client refilled drugs from another facility'
            when 159367 then 'Client has enough drugs'
            when
                162619 then 'Client travelled'
            when 126240 then 'Client could not get an off from work/school'
            when 160583
                then 'Client is sharing drugs with partner'
            when 162192 then 'Client forgot clinic dates'
            when 164349
                then 'Client stopped medications'
            when 1654 then 'Client sick at home/admitted'
            when 5622 then 'Other' end)                                       as ReasonForMissedAppointment,
       case
           when fup.next_appointment_date < '1990-01-01' then null
           else CAST(fup.next_appointment_date AS DATE) end                   AS DatePromisedToCome,
       f.missed_appointment_date                                              as DateOfMissedAppointment,
       (case f.cause_of_death
            when 165609 then 'Infection due to COVID-19'
            when 162574 then 'Death related to HIV infection'
            when 116030 then 'Cancer'
            when 164500 then 'TB'
            when 151522 then 'Other infectious and parasitic diseases'
            when 133481 then 'Natural cause'
            when 1603 then 'Unnatural Cause'
            when 5622 then 'Unknown cause' end)                               as CauseOfDeath,
       f.comments                                                             as Comments,
       date(f.booking_date)                                                   as BookingDate,
       f.date_created                                                         as DateCreated,
       f.date_last_modified                                                   as DateModified,
       f.voided                                                               as voided
from dwapi_etl.etl_patient_demographics d
         join dwapi_etl.etl_ccc_defaulter_tracing f on d.patient_id = f.patient_id
         join dwapi_etl.etl_patient_hiv_followup fup on fup.patient_id = d.patient_id
         join kenyaemr_etl.etl_default_facility_info i
group by f.visit_id;

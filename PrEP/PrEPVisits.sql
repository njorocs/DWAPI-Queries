select d.patient_id                                                              as PatientPK,
       f.uuid                                                                    as uuid,
       i.siteCode                                                                as SiteCode,
       d.unique_prep_number                                                      as PrepNumber,
       d.openmrs_id                                                              as HtsNumber,
       f.encounter_id                                                            as EncounterId,
       'KenyaEMR'                                                                as Emr,
       'HMIS'                                                                    as Project,
       f.visit_date                                                              as VisitDate,
       f.visit_id                                                                as VisitId,
       concat_ws('/', t.systolic_pressure, t.diastolic_pressure)                 as BloodPressure,
       t.temperature                                                             as Tempereature,
       t.weight                                                                  as Weight,
       t.height                                                                  as Height,
       f.sti_screened                                                            as STIScreening,
       concat_ws(',', f.genital_ulcer_disease,
                 f.vaginal_discharge,
                 f.cervical_discharge,
                 f.pid,
                 f.urethral_discharge,
                 f.anal_discharge,
                 f.other_sti_symptoms)                                           as STISymptoms,
       f.sti_treated                                                             as STITreated,
       f.vmmc_status                                                             as Circumcised,
       f.vmmc_referred                                                           as VMMCReferral,
       f.lmp                                                                     as LMP,
       f.menopausal_status                                                       as MenopausalStatus,
       f.pregnant                                                                as PregnantAtThisVisit,
       f.edd                                                                     as EDD,
       f.wanted_pregnancy                                                        as PlanningToGetPregnant,
       f.planned_pregnancy                                                       as PregnancyPlanned,
       f.ended_pregnancy                                                         as PregnancyEnded,
       f.outcome_date                                                            as PregnancyEndDate,
       f.pregnancy_outcome                                                       as PregnancyOutcome,
       f.defects                                                                 as BirthDefects,
       f.breastfeeding                                                           as BreastFeeding,
       f.fp_status                                                               as FamilyPlanningStatus,
       f.fp_method                                                               as FPMethods,
       f.adherence_counselled                                                    as AdherenceDone,
       f.adherence_outcome                                                       as AdherenceOutcome,
       e.prep_type                                                               as TypeOfPrep,
       f.switching_option                                                        as ReasonForSwitching,
       f.switching_date                                                          as DateofSwitch,
       f.dosing_strategy                                                         as DosingStrategy,
       f.prep_contraindications                                                  as ContraindicationsPrEP,
       f.treatment_plan                                                          as PrEPTreatmentPlan,
       f.prescribed_PrEP                                                         as PrEPPrescribed,
       f.regimen_prescribed                                                      as RegimenPrescribed,
       f.months_prescribed_regimen                                               as MonthsPrescribed,
       f.condoms_issued                                                          as CondomsIssued,
       f.appointment_given                                                       as Tobegivennextappointment,
       f.reason_no_appointment                                                   as Reasonfornotgivingnextappointment,
       f.appointment_date                                                        as NextAppointment,
       f.clinical_notes                                                          as ClinicalNotes,
       case f.hepatitisB_vaccinated when 1065 then 'Yes' when 1066 then 'No' end as VaccinationForHepBStarted,
       case f.hepatitisB_treated
           when 1065 then 'Yes'
           when 1066 then 'No'
           when 1788
               then 'Referred' end                                               as TreatedForHepB,
       case f.hepatitisC_vaccinated when 1065 then 'Yes' when 1066 then 'No' end as VaccinationForHepCStarted,
       case f.hepatitisC_treated
           when 1065 then 'Yes'
           when 1066 then 'No'
           when 1788
               then 'Referred' end                                               as TreatedForHepC,
       f.date_created                                                            as DateCreated,
       f.date_last_modified                                                      as DateLastModified,
       f.voided                                                                  as voided
from dwapi_etl.etl_prep_followup f
         left join dwapi_etl.etl_patient_triage t on f.patient_id = t.patient_id and f.visit_date = t.visit_date
         inner join dwapi_etl.etl_prep_enrolment e on f.patient_id = e.patient_id
         inner join dwapi_etl.etl_patient_demographics d on e.patient_id = d.patient_id
         join kenyaemr_etl.etl_default_facility_info i;
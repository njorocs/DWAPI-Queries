#VMMC MEDICAL HISTORY and PHYSICAL EXAMINATION  EXTRACT
select h.patient_id                                                                      as PatientPK,
       ''                                                                                as PatientPKHash,
       h.uuid                                                                            as uuid,
       s.siteCode                                                                        as SiteCode,
       d.unique_patient_no                                                               as VMMCId,
       ''                                                                                as VMMCIdHash,
       0                                                                                 as FacilityId,
       'KenyaEMR'                                                                        as Emr,
       'Kenya HMIS III'                                                                  as Project,
       s.FacilityName                                                                    as FacilityName,
       h.visit_date                                                                      as EncounterDate,
       case h.hiv_status
           when 1067 then 'Unknown'
           when 664 then 'Negative'
           when 703 then 'Positive'
           when 1370
               then 'HTS Counsellors' end                                                as HIVStatus,
       h.hiv_unknown_reason                                                              as Reasonresultsunknown,
       coalesce(h.services_referral, h.other_services_referral)                          as ReferredServices,
       ''                                                                                as HIVStatusSelfReport,
       case h.hiv_care_facility
           when 163266 then s.FacilityName
           when 164407
               then h.hiv_care_facility_name end                                         as FacilityReceivingCare,
       h.ccc_number                                                                      as CCCNumber,
       h.current_regimen                                                                 as CurrentRegimen,
       h.vl                                                                              as LastVL,
       h.cd4_count                                                                       as CD4Count,
       if(h.bleeding_disorder = 147241, 'Yes', null)                                     as BleedingDisorder,
       if(h.diabetes = 119481, 'Yes', null)                                              as Diabetes,
       if(FIND_IN_SET('Urethral Discharge', h.client_presenting_complaints) > 0, 'Yes',
          'No')                                                                          as UrethralDischarge,
       if(FIND_IN_SET('Genital Sore', h.client_presenting_complaints) > 0, 'Yes',
          'No')                                                                          as GenitalSore,
       if(FIND_IN_SET('Pain on Urination', h.client_presenting_complaints) > 0, 'Yes',
          'No')                                                                          as PainUrination,
       if(FIND_IN_SET('Swelling of the scrotum', h.client_presenting_complaints) > 0, 'Yes',
          'No')                                                                          as SwellingScrotum,
       if(FIND_IN_SET('Difficulty in retracting foreskin', h.client_presenting_complaints) > 0, 'Yes',
          'No')                                                                          as DifficultyRetractingForeskin,
       if(FIND_IN_SET('Difficulty in returning foreskin to normal', h.client_presenting_complaints) > 0, 'Yes',
          'No')                                                                          as DifficultyReturninForeskinNormal,
       if(FIND_IN_SET('Concerns about erection/sexual function', h.client_presenting_complaints) > 0, 'Yes',
          'No')                                                                          as SexualFunctionConcerns,
       if(FIND_IN_SET('Epispadia', h.client_presenting_complaints) > 0, 'Yes',
          'No')                                                                          as Epispadia,
       if(FIND_IN_SET('Hypospadia', h.client_presenting_complaints) > 0, 'Yes',
          'No')                                                                          as Hypospadia,
       h.other_complaints                                                                as Other,
       if(FIND_IN_SET('Anaemia', h.ongoing_treatment) > 0, 'Yes', 'No')                  as Anaemia,
       if(FIND_IN_SET('Diabetes', h.ongoing_treatment) > 0, 'Yes', 'No')                 as Diabetes,
       if(FIND_IN_SET('HIV/AIDS', h.ongoing_treatment) > 0, 'Yes', 'No')                 as HIVAIDS,
       h.art_start_date                                                                  as StartARTDate,
       ''                                                                                as Adherance,
       h.next_appointment_date                                                           as NextAppointmentDate,
       h.hb_level                                                                        as HB,
       h.sugar_level                                                                     as SugarLevels,
       case h.ever_had_surgical_operation when 1065 then 'Yes' when 1066 then 'No' end   as ClientEverHadSurgery,
       h.specific_surgical_operation                                                     as SpecifySurgery,
       case h.ever_received_tetanus_booster when 1065 then 'Yes' when 1066 then 'No' end as TetanusBoosterGiven,
       h.date_received_tetanus_booster                                                   as DateTetanusBoosterGiven,
       h.blood_pressure                                                                  as BP,
       h.pulse_rate                                                                      as PulseRate,
       h.temperature                                                                     as Temperature,
       h.date_created                                                                    as Date_Created,
       h.date_last_modified                                                              as Date_Last_Modified,
       h.voided                                                                          as voided
from dwapi_etl.etl_vmmc_medical_history h
         inner join dwapi_etl.etl_patient_demographics d on h.patient_id = d.patient_id
         join kenyaemr_etl.etl_default_facility_info s;



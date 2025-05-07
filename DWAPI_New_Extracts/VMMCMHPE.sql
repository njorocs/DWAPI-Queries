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
       case h.current_regimen
           when 164968 then 'AZT/3TC/DTG'
           when 164969 then 'TDF/3TC/DTG'
           when 164970 then 'ABC/3TC/DTG'
           when 164505 then 'TDF-3TC-EFV'
           when 792 then 'D4T/3TC/NVP'
           when 160124 then 'AZT/3TC/EFV'
           when 160104 then 'D4T/3TC/EFV'
           when 1652 then '3TC/NVP/AZT'
           when 161361 then 'EDF/3TC/EFV'
           when 104565 then 'EFV/FTC/TDF'
           when 162201 then '3TC/LPV/TDF/r'
           when 817 then 'ABC/3TC/AZT'
           when 162199 then 'ABC/NVP/3TC'
           when 162200 then '3TC/ABC/LPV/r'
           when 162565 then '3TC/NVP/TDF'
           when 1652 then '3TC/NVP/AZT'
           when 162561 then '3TC/AZT/LPV/r'
           when 164511 then 'AZT-3TC-ATV/r'
           when 164512 then 'TDF-3TC-ATV/r'
           when 162560 then '3TC/D4T/LPV/r'
           when 162563 then '3TC/ABC/EFV'
           when 162562 then 'ABC/LPV/R/TDF'
           when 162559 then 'ABC/DDI/LPV/r' end                                          as CurrentRegimen,
       h.vl                                                                              as LastVL,
       h.cd4_count                                                                       as CD4Count,
       if(h.bleeding_disorder = 147241, 'Yes', null)                                     as BleedingDisorder,
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



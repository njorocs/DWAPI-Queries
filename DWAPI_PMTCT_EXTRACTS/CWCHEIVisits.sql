select d.patient_id           as PatientPK,
       v.uuid                 as uuid,
       i.siteCode             as SiteCode,
       'KenyaEMR'             as Emr,
       'Kenya HMIS II'        as Project,
       i.FacilityName         as FacilityName,
       d.openmrs_id           as PatientMNCH_ID,
       v.visit_date           as VisitDate,
       v.visit_id             as VisitID,
       v.revisit_this_year    as RevisitThisYear,
       v.height               as Height,
       v.weight               as Weight,
       v.height_length        as HeightLength,
       v.temperature          as Temp,
       v.pulse_rate           as PulseRate,
       v.respiratory_rate     as RespiratoryRate,
       v.oxygen_saturation    as OxygenSaturation,
       v.muac                 as MUAC,
       v.ZScoreAbsolute       as ZScoreAbsolute,
       v.ZScore               as ZScore,
       v.weight_category      as WeightCategory,
       v.stunted              as Stunted,
       v.infant_feeding       as InfantFeeding,
       v.medication_given     as MedicationGiven,
       v.tb_assessment        as TBAssessment,
       v.mnps_supplementation as MNPsSupplementation,
       ''                     as Immunization,
       ''                     as ImmunizationGiven,
       v.danger_signs         as DangerSigns,
       v.milestones           as Milestones,
       v.vitaminA_given       as VitaminA,
       v.disability           as Disability,
       v.llin                 as ReceivedMosquitoNet,
       v.dewormed             as Dewormed,
       v.referred             as Refferred,
       v.referred_from        as ReferredFrom,
       v.referred_to          as ReferredTo,
       v.referral_reason      as ReferralReasons,
       v.follow_up            as FollowUP,
       v.appointment_date     as NextAppointment,
       v.dna_pcr              as dnapcr,
       v.dna_pcr_date         as dnapcrdate,
       v.voided               as voided
from dwapi_etl.etl_patient_demographics d
         inner join (select v.patient_id,
                            v.uuid                                                                  as uuid,
                            v.visit_date,
                            v.visit_id,
                            (case v.revisit_this_year when 1065 then "Yes" when 1066 then "No" end) as revisit_this_year,
                            round(t.height, 2)                                                      as height,
                            round(t.weight, 2)                                                      as weight,
                            (case v.height_length
                                 when 1115 then "Normal"
                                 when 164085 then "Stunted"
                                 when 164086 then "Severe Stunded" end)                             as height_length,
                            round(t.temperature, 1)                                                 as temperature,
                            t.pulse_rate,
                            t.respiratory_rate,
                            t.oxygen_saturation,
                            (case v.muac
                                 when 160909 then 'Green'
                                 when 160910 then 'Yellow'
                                 when 127778 then 'Red'
                                 else '' end)                                                       as muac,
                            t.z_score_absolute                                                      as ZScoreAbsolute,
                            case t.z_score
                                when 1115 then 'Normal (Median)'
                                when 123814 then 'Mild (-1 SD)'
                                when 123815 then 'Moderate (-2 SD)'
                                when 164131 then 'Severe (-3 SD and -4 SD)' end                     as ZScore,
                            case v.weight_category
                                when 123814 then 'Underweight(UW)'
                                when 126598 then 'Severely Underweight(SUW)'
                                when 114413 then 'Overweight(OW)'
                                when 115115 then 'Obese(O)'
                                when 1115 then 'Normal(N)' end                                      as weight_category,
                            case v.stunted when 164085 then 'Yes' when 1115 then 'No' end           as stunted,
                            case v.infant_feeding
                                when 5526 then 'Exclusive breastfeeding <6 Months(EBF)'
                                when 5632 then 'Infant Breastfeeding >6 months (BF)'
                                when 164478 then 'Not Breastfeeding(NBF)' end                       as infant_feeding,
                            concat_ws('|', nullif(case v.azt_given when 'Yes' then 'AZT' when 'No' then '' end, ''),
                                      nullif(case v.nvp_given when 'Yes' then 'NVP' when 'No' then '' end, ''),
                                      nullif(case v.ctx_given when 'Yes' then 'CTX' when 'No' then '' end, ''),
                                      nullif(case v.multi_vitamin_given when 'Yes' then 'AZT' when 'No' then '' end,
                                             ''))                                                   as medication_given,
                            case v.tb_assessment_outcome
                                when 1660 then 'No TB Signs'
                                when 142177 then 'Presumed TB'
                                when 1661 then 'TB Confirmed'
                                when 1662 then 'TB Rx'
                                when 1679 then 'INH'
                                when 160737 then 'Not Done'
                                else '' end                                                         as tb_assessment,
                            case v.danger_signs
                                when 159861 then "Unable to breastfeed"
                                when 1983 then "Unable to drink"
                                when 164482 then "Vomits everything"
                                when 138868 then "Bloody Diarrhea"
                                when 460 then "Has Oedema"
                                when 164483 then "Has convulsions" end                              as danger_signs,
                            case v.review_of_systems_developmental
                                when 1115 then 'Normal(N)'
                                when 6022 then 'Delayed(D)'
                                when 6025 then 'Regressed(R)' end                                   as milestones,
                            case v.vitaminA_given when 1065 then 'Yes' when 1066 then 'No' end      as vitaminA_given,
                            case v.disability when 1065 then 'Yes' when 1066 then 'No' end          as disability,
                            (case LLIN when 1065 then "Yes" when 1066 then "No" else "" end)        as llin,
                            case v.deworming_drug when 79413 then 'Yes' when 70439 then 'Yes' end   as dewormed,
                            case v.counselled_on
                                when 1914 then 'HIV'
                                when 1380 then 'Nutrition Services' end                             as follow_up,
                            (case v.referred when 1065 then "Yes" when 1066 then "No" end)          as referred,
                            case v.referred_from
                                when 1537 then 'Another Health Facility'
                                when 163488 then 'Community Unit'
                                when 1175 then 'N/A' end                                            as referred_from,
                            case v.referred_to
                                when 1537 then 'Another Health Facility'
                                when 163488 then 'Community Unit'
                                when 1175 then 'N/A' end                                            as referred_to,
                            v.referral_reason                                                       as referral_reason,
                            v.next_appointment_date                                                 as appointment_date,
                            case v.dna_pcr_result
                                when 1138 then 'Indeterminate'
                                when 664 then 'Negative'
                                when 703 then 'Positive'
                                when 1304 then 'Poor sample quality' end                            as dna_pcr,
                            v.dna_pcr_sample_date                                                   as dna_pcr_date,
                            v.MNPS_Supplementation                                                  as mnps_supplementation,
                            i.fully_immunized                                                       as FullyImmunizedChild,
                            v.date_created                                                          as Date_Created,
                            v.date_last_modified                                                    as Date_Last_Modified,
                            v.voided                                                                as voided
                     from dwapi_etl.etl_hei_follow_up_visit v
                              left join dwapi_etl.etl_patient_triage t
                                        on v.visit_date = t.visit_date and v.patient_id = t.patient_id
                              left join dwapi_etl.etl_hei_immunization i
                                        on v.patient_id = i.patient_id and v.visit_date = i.visit_date) v
                    on d.patient_id = v.patient_id
         join kenyaemr_etl.etl_default_facility_info i;
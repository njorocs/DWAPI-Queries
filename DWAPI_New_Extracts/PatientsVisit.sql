select ''                                                                     AS SatelliteName,
       0                                                                      AS FacilityId,
       d.unique_patient_no                                                    as PatientID,
       fup.uuid                                                               as uuid,
       d.patient_id                                                           as PatientPK,
       i.facilityName                                                         as FacilityName,
       i.siteCode                                                             as SiteCode,
       fup.visit_id                                                           as VisitId,
       case
           when fup.visit_date < '1990-01-01' then null
           else CAST(fup.visit_date AS DATE) end                              AS VisitDate,
       'Out Patient'                                                          as Service,
       (case fup.visit_scheduled
            when 1 then "Scheduled"
            when 2 then 'Unscheduled'
            else "" end)                                                      as VisitType,
       (case fup.person_present
            when 978 then 'Self'
            when 161642 then 'Treatment supporter'
            when 159802 then 'Refill visit documentation'
            when 5622 then 'Other' end)                                       as VisitBy,
       case fup.who_stage
           when 1220 then 1
           when 1221 then 2
           when 1222 then 3
           when 1223 then 4
           when 1204 then 1
           when 1205 then 2
           when 1206 then 3
           when 1207 then 4
           else ''
           end                                                                as WHOStage,
       fup.who_stage_associated_oi                                              as WHOStagingOI,
       null                                                                   as WABStage,
       case fup.pregnancy_status
           when 1065 then 'Yes'
           when 1066 then 'No'
           end                                                                as Pregnant,
    case fup.wants_pregnancy when 1065 then 'Yes' when 1066 then 'No' end as WantsTogetPregnant,
       CAST(fup.last_menstrual_period AS DATE)                                as LMP,
       CAST(fup.expected_delivery_date AS DATE)                               as EDD,
       t.height                                                               as Height,
       t.weight                                                               as Weight,
       concat(t.systolic_pressure, '/', t.diastolic_pressure)                 as BP,
       t.temperature                                                          as Temp,
       t.z_score_absolute                                                              as ZScoreAbsolute,
       case t.z_score
           when 1115 then 'Normal (Median)'
           when 123814 then 'Mild (-1 SD)'
           when 123815 then 'Moderate (-2 SD)'
           when 164131 then 'Severe (-3 SD and -4 SD)' end                    as ZScore,
       t.pulse_rate                                                           as PulseRate,
       t.respiratory_rate                                                     as RespiratoryRate,
       t.oxygen_saturation                                                    as OxygenSaturation,
       t.muac                                                                 as Muac,
       (case t.nutritional_status
            when 1115 then "Normal"
            when 163302 then "Severe acute malnutrition"
            when 163303 then "Moderate acute malnutrition"
            when 114413 then "Overweight/Obese"
            else "" end)                                                      as nutritional_status,
       (case fup.ever_had_menses
            when 1065 then 'Yes'
            when 1066 then 'No'
            when 1175
                then 'N/A' end)                                               as EverHadMenses,
       if(d.gender = 'F', (case fup.breastfeeding when 1065 then 'Yes' when 1066 then 'No' end),
          'N/A')                                                              as Breastfeeding,
       (case menopausal when 113928 then 'Yes' end)                           as Menopausal,
       (case prophylaxis_given
            when 105281 then 'Cotrimoxazole'
            when 74250 then 'Dapsone'
            when 1107
                then 'None' end)                                              as ProphylaxisUsed,
       (case fup.ctx_adherence
            when 159405 then 'Good'
            when 163794 then 'Fair'
            when 159407 then 'Bad'
            else '' end)                                                      as CTXAdherence,
       de.regimen                                                             as CurrentRegimen,
       (case fup.reason_not_using_family_planning
            when 160572 then "Thinks can't get pregnant"
            when 160573 then "Not sexually active now"
            when 5622 then "Other"
            else "" end)                                                      as NoFPReason,
       'ART|CTX'                                                              as AdherenceCategory,
       concat(
               IF(fup.arv_adherence = 159405, 'Good',
                  IF(fup.arv_adherence = 159406, 'Fair', IF(fup.arv_adherence = 159407, 'Poor', ''))),
               IF(fup.arv_adherence in (159405, 159406, 159407), '|', ''),
               IF(fup.ctx_adherence = 159405, 'Good',
                  IF(fup.ctx_adherence = 159406, 'Fair', IF(fup.ctx_adherence = 159407, 'Poor', '')))
           )                                                                  AS Adherence,
       (case next_appointment_reason
            when 160523 then 'Follow up'
            when 1283 then 'Lab tests'
            when 159382 then 'Counseling'
            when 160521 then 'Pharmacy Refill'
            when 5622 then 'Other'
            else '' end)                                                      as TCAReason,
       fup.clinical_notes                                                     as ClinicalNotes,
       ''                                                                     as OI,
       NULL                                                                   as OIDate,
       fup.general_examination                                                as GeneralExamination,
       (case fup.system_examination
            when 1115 then 'Normal'
            when 1116
                then 'Abnormal' end)                                          as SystemExamination,
       (case fup.skin_findings
            when 150555 then 'Abscess'
            when 125201 then 'Swelling/Growth'
            when 135591 then 'Hair Loss'
            when 136455 then 'Itching'
            when 507 then 'Kaposi Sarcoma'
            when 1249 then 'Skin eruptions/Rashes'
            when 5244 then 'Oral sores' end)                                  as Skin,
       (case fup.eyes_findings
            when 123074 then 'Visual Disturbance'
            when 140940 then 'Excessive tearing'
            when 131040 then 'Eye pain'
            when 127777 then 'Eye redness'
            when 140827 then 'Light sensitive'
            when 139100 then 'Itchy eyes' end)                                as Eyes,
       (case fup.ent_findings
            when 148517 then 'Apnea'
            when 139075 then 'Hearing disorder'
            when 119558 then 'Dental caries'
            when 118536 then 'Erythema'
            when 106 then 'Frequent colds'
            when 147230 then 'Gingival bleeding'
            when 135841 then 'Hairy cell leukoplakia'
            when 117698
                then 'Hearing loss'
            when 138554 then 'Hoarseness'
            when 507 then 'Kaposi Sarcoma'
            when 152228 then 'Masses'
            when 128055 then 'Nasal discharge'
            when 133499 then 'Nosebleed'
            when 160285 then 'Pain'
            when 110099 then 'Post nasal discharge'
            when 126423 then 'Sinus problems'
            when 126318 then 'Snoring'
            when 158843 then 'Sore throat'
            when 5244 then 'Oral sores'
            when 5334 then 'Thrush'
            when 123588 then 'Tinnitus'
            when 124601 then 'Toothache'
            when 123919 then 'Ulcers'
            when 111525 then 'Vertigo' end)                                   as ENT,
       (case fup.chest_findings
            when 146893 then 'Bronchial breathing'
            when 127640 then 'Crackles'
            when 145712 then 'Dullness'
            when 164440 then 'Reduced breathing'
            when 127639 then 'Respiratory distress'
            when 5209 then 'Wheezing' end)                                    as Chest,
       (case fup.cvs_findings
            when 140147 then 'Elevated blood pressure'
            when 136522 then 'Irregular heartbeat'
            when 562 then 'Cardiac murmur'
            when 130560 then 'Cardiac rub' end)                               as CVS,
       (case fup.abdomen_findings
            when 150915 then 'Abdominal distension'
            when 5008 then 'Hepatomegaly'
            when 5103 then 'Abdominal mass'
            when 5009 then 'Splenomegaly'
            when 5105 then 'Abdominal tenderness' end)                        as Abdomen,
       (case fup.cns_findings
            when 118872 then 'Altered sensations'
            when 1836 then 'Bulging fontenelle'
            when 150817 then 'Abnormal reflexes'
            when 120345 then 'Confusion'
            when 157498 then 'Limb weakness'
            when 112721 then 'Stiff neck'
            when 136282 then 'Kernicterus' end)                               as CNS,
       (case fup.genitourinary_findings
            when 147241 then 'Bleeding'
            when 154311 then 'Rectal discharge'
            when 123529 then 'Urethral discharge'
            when 123396 then 'Vaginal discharge'
            when 124087
                then 'Ulceration' end)                                        as Genitourinary,
       case ifnull(fup.family_planning_status, '')
           when 695 then 'Currently using FP'
           when 160652 then 'Not using FP'
           when 1360 then 'Wants FP'
           else ''
           end                                                                as FamilyPlanningMethod,
       concat_ws('|',
                 nullif(case fup.substance_abuse_screening
                            when 1065 then 'Screened for substance abuse'
                            else ''
                            end, ''),
                 nullif(case fup.condom_provided
                            when 1065 then 'Condoms'
                            else ''
                            end, ''),
                 nullif(case fup.pwp_disclosure
                            when 1065 then 'Disclosure'
                            else ''
                            end, ''),
                 nullif(case fup.pwp_partner_tested
                            when 1065 then 'Partner Testing'
                            else ''
                            end, ''),
                 nullif(case fup.screened_for_sti
                            when 1065 then 'Screened for STI'
                            else ''
                            end, ''),
                 nullif(case fup.cacx_screening
                            when 703 then 'Screened for CaCx'
                            when 664 then 'Screened for CaCx'
                            end, ''))                                         as PwP,
       case fup.pwp_pead_disclosure
           when 1066 then 'No disclosure'
           when 162979 then 'Partial disclosure'
           when 166982 then 'Full disclosure' end                             as PeadsDisclosure,
       if(fup.last_menstrual_period is not null,
          timestampdiff(week, fup.last_menstrual_period, fup.visit_date), '') as GestationAge,
       case
           when fup.next_appointment_date < '1990-01-01' then null
           else CAST(fup.next_appointment_date AS DATE) end                   AS NextAppointmentDate,
       case
           when fup.refill_date < '1990-01-01' then null
           else CAST(fup.refill_date AS DATE) end                             AS refillDate,
       case fup.appointment_consent when 1065 then 'Yes' when 1066 then 'No' end as AppointmentReminderWillingness,
       'KenyaEMR'                                                             as Emr,
       'Kenya HMIS II'                                                        as Project,
       CAST(fup.substitution_first_line_regimen_date AS DATE)                 AS SubstitutionFirstlineRegimenDate,
       fup.substitution_first_line_regimen_reason                             AS SubstitutionFirstlineRegimenReason,
       CAST(fup.substitution_second_line_regimen_date AS DATE)                AS SubstitutionSecondlineRegimenDate,
       fup.substitution_second_line_regimen_reason                            AS SubstitutionSecondlineRegimenReason,
       CAST(fup.second_line_regimen_change_date AS DATE)                      AS SecondlineRegimenChangeDate,
       fup.second_line_regimen_change_reason                                  AS SecondlineRegimenChangeReason,
       CASE fup.stability
           WHEN 1 THEN 'Stable'
           WHEN 2
               THEN 'Not Stable' END                                          as StabilityAssessment,
       (case fup.differentiated_care
            when 164942 then "Standard Care"
            when 164943 then "Fast Track"
            when 164944 then "Community ART Distribution - HCW Led"
            when 164945 then "Community ART Distribution - Peer Led"
            when 164946 then "Facility ART Distribution Group"
            else "" end)                                                      as DifferentiatedCare,
       (case population_type
            when 164928 then "General Population"
            when 164929 then "Key Population"
            else "" end)                                                      as PopulationType,
       case fup.key_population_type
           WHEN 105 THEN 'PWID'
           WHEN 160578 THEN 'MSM'
           WHEN 160579 THEN 'FSW'
           when 165084 then 'MSW'
           when 165085 then 'PWUD'
           when 165100 then 'Transgender'
           WHEN 1175 THEN 'N/A' END                                           as KeyPopulationType,
       ''                                                                     as HCWConcern,
       fup.date_created                                                       as Date_Created,
       fup.date_last_modified                                                 as Date_Last_Modified,
       fup.voided                                                             as voided
from dwapi_etl.etl_patient_demographics d
         join dwapi_etl.etl_patient_hiv_followup fup on fup.patient_id = d.patient_id
         join kenyaemr_etl.etl_default_facility_info i
         left join (select t.patient_id,
                           t.visit_date,
                           t.weight,
                           t.height,
                           t.systolic_pressure,
                           t.diastolic_pressure,
                           t.temperature,
                           t.z_score_absolute,
                           t.z_score,
                           t.pulse_rate,
                           t.respiratory_rate,
                           t.oxygen_saturation,
                           t.muac,
                           t.nutritional_status
                    from dwapi_etl.etl_patient_triage t) t
                   on fup.patient_id = t.patient_id and date(fup.visit_date) = date(t.visit_date)
         left join (select de.patient_id, mid(max(concat(de.visit_date, de.regimen)), 11) as regimen
                    from dwapi_etl.etl_drug_event de
                    where de.discontinued is null
                    group by de.patient_id) de on fup.patient_id = de.patient_id
where d.unique_patient_no is not null
  and fup.visit_date > '1990-01-01'
  and fup.next_appointment_date is not null
  and fup.visit_id is not null;
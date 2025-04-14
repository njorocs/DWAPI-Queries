select d.patient_id                                                                         PatientPK,
       l.uuid                                                                  as           uuid,
       i.siteCode                                                                           SiteCode,
       d.openmrs_id                                                                         PatientMNCH_ID,
       'KenyaEMR'                                                                           Emr,
       'Kenya HMIS II'                                                                      Project,
       i.facilityName                                                                       FacilityName,
       l.visit_id                                                                           VisitId,
       l.visit_date                                                                         VisitDate,
       l.admission_number                                                                   AdmissionNumber,
       l.number_of_anc_visits                                                               ANCVisits,
       date(l.date_of_last_menstrual_period)                                                LMP,
       date(l.estimated_date_of_delivery)                                                   EDD,
       l.date_of_delivery                                                                   DateOfDelivery,
       l.duration_of_labor                                                                  DurationOfLabor,
       l.duration_of_pregnancy                                                              GestationAtBirth,
       case l.mode_of_delivery
           when 1170 then 'Normal delivery'
           when 1171 then 'CS'
           when 1172 then 'Breech'
           when 118159
               then 'Assisted vaginal delivery' end                                         ModeOfDelivery,
       case l.placenta_complete
           when 703 then 'Yes'
           when 664
               then 'No'
           when 1501 then 'Baby born before arrival' end                                    PlacentaComplete,
       (case l.uterotonic_given
            when 81369 then "Oxytocin"
            when 104590 then "Carbetocin"
            when 1107
                then "None" end)                                                            UterotonicGiven,
       (case l.vaginal_examination
            when 132681 then "Normal"
            when 5577 then "Episiotomy"
            when 159264 then "Vaginal Tear"
            when 118935 then "FGM"
            when 139505 then "Vaginal wart" end)                                            VaginalExamination,
       l.blood_loss                                                                         BloodLoss,
       ''                                                                                   BloodLossVisual,
       case l.condition_of_mother
           when 160429 then 'Alive'
           when 134612
               then 'Dead' end                                                              ConditonAfterDelivery,
       (case maternal_death_audited when 1065 then "Yes" when 1066 then "No" else "NA" end) MaternalDeathAudited,
       coalesce(case l.coded_delivery_complications
                    when 118744 then 'Eclampsia'
                    when 113195 then 'Ruptured Uterus'
                    when 115036 then 'Obstructed Labor'
                    when 228 then 'APH'
                    when 230 then 'PPH'
                    when 130 then 'Puerperal sepsis'
                    when 1067 then 'Uknown'
                    when 5622 then 'Other'
                    else 'None' end,
                l.other_delivery_complications)                                             DeliveryComplications,
       (case l.delivery_outcome
            when 159913 then 1
            when 159914 then 2
            when 159915
                then 3 end)                                                                 NoBabiesDelivered,
       ''                                                                      as           BabyBirthNumber,
       case l.baby_sex when 1534 then 'Male' when 1535 then 'Female' end       as           SexBaby,
       round(l.birth_weight, 2)                                                as           BirthWeight,
       case l.baby_condition
           when 151849 then 'Live birth'
           when 159916 then 'Fresh still birth'
           when 135436
               then 'Macerated still birth' end                                as           BirthOutcome,
       case l.type_of_birth_deformity
           when 143672 then 'Congenital syphilis'
           when 126208 then 'Spina bifida'
           when 117470 then 'Hydrocephalus'
           when 125048 then 'Talipes' end                                      as           BirthWithDeformity,
       case l.teo_given
           when 1 then 'Yes'
           when 0 then 'No' end                                                as           TetracyclineGiven,
       case l.bf_within_one_hour when 1065 then 'Yes' when 1066 then 'No' end  as           InitiatedBF,
       l.apgar_score_1min                                                      as           ApgarScore1,
       l.apgar_score_5min                                                      as           ApgarScore5,
       l.apgar_score_10min                                                     as           ApgarScore10,
       (case l.kangaroo_mother_care_given
            when 1065 then "Yes"
            when 1066 then "No"
            when 1175
                then "                      N/A" end)                          as           KangarooCare,
       (case l.chlohexidine_applied_on_code_stump
            when 1065 then "Yes"
            when 1066
                then "No" end)                                                 as           ChlorhexidineAppliedOnCordStump,
       (case l.vitamin_K_given when 1065 then "Yes" when 1066 then "No" end)   as           VitaminKGiven,
       case c.baby_status when 163016 then 'Alive' when 160432 then 'Dead' end as           StatusBabyDischarge,
       c.discharge_date                                                        as           MotherDischargeDate,
       (case l.vdrl_rpr_results
            when 703 then "Positive"
            when 664 then "Negative"
            when 1118
                then "Not Done" end)                                           as           SyphilisTestResults,
       ''                                                                      as           HIVStatusLastANC,
       if(l.final_test_result is not null, 'Yes', 'No')                        as           HIVTestingDone,
       l.test_1_kit_name                                                       as           HIVTest_1,
       l.test_1_result                                                         as           HIV_1Results,
       l.test_2_kit_name                                                       as           HIVTest_2,
       l.test_2_result                                                         as           HIV_2Results,
       l.test_3_kit_name                                                       as           HIVTest_3,
       l.test_3_result                                                         as           HIV_3Results,
       l.final_test_result                                                     as           HIVTestFinalResult,
       (case l.mother_on_haart_during_anc
            when 1065 then "Yes"
            when 1066 then "No"
            when 1067 then "N/A"
            else "" end)                                                                    OnARTANC,
       (case l.mother_started_haart_at_maternity
            when 1065 then "Yes"
            when 1066 then "No"
            when 1067 then "N/A" end)                                                       onARTMat,
       if(l.baby_nvp_dispensed = 1 or l.baby_azt_dispensed = 1, 'Yes',
          'No')                                                                as           BabyGivenProphylaxis,
       case l.prophylaxis_given
           when 105281 then 'Yes'
           when 1107 then 'No'
           else 'NA' end                                                       as           MotherGivenCTX,
       case l.partner_hiv_tested when 1065 then 'Yes' when 1066 then 'No' end  as           PartnerHIVTestingMAT,
       case l.partner_hiv_status
           when 703 then 'HIV Positive'
           when 664 then 'HIV Negative'
           when 1067
               then 'Unknown' end                                              as           PartnerHIVStatusMAT,
       concat_ws('|', nullif(case l.counseling_on_infant_feeding_for_hiv_infected
                                 when 1065 then 'Yes'
                                 when 1066 then 'No'
                                 when 1175 then 'NA' end, ''),
                 '')                                                           as           CounselledOnInfantFeeding,
       case
           when 1537 then 'Another Health Facility'
           when 163488 then 'Community Unit'
           when 1175
               then 'N/A' END                                                  as           ReferredFrom,
       case c.referred_to
           when 1537 then 'Another Health Facility'
           when 163488 then 'Community Unit'
           when 165093 then 'HIV preventive services'
           when 1175
               then 'N/A' END                                                  as           ReferredTo,
       l.reason_for_referral                                                                ReferralReason,
       l.clinical_notes                                                        as           ClinicalNotes,
       l.date_created                                                                       Date_Created,
       GREATEST(COALESCE(l.date_last_modified, e.date_last_modified, c.date_last_modified),
                COALESCE(l.date_last_modified, e.date_last_modified,
                         c.date_last_modified))                                as           Date_Last_Modified,
       l.voided                                                                as           voided
from dwapi_etl.etl_patient_demographics d
         join dwapi_etl.etl_mchs_delivery l on d.patient_id = l.patient_id
         left join dwapi_etl.etl_mchs_discharge c on d.patient_id = c.patient_id
         join dwapi_etl.etl_mch_enrollment e on d.patient_id = e.patient_id
         left join (select v.patient_id, mid(max(concat(v.visit_date, v.anc_visit_number)), 11) as anc_visits
                    from dwapi_etl.etl_mch_antenatal_visit v
                    group by v.patient_id) v on d.patient_id = v.patient_id
         join kenyaemr_etl.etl_default_facility_info i
where l.visit_id is not null
group by l.visit_id;

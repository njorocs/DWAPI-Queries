select d.patient_id                                                                             PatientPK,
       a.uuid                                    as                                             uuid,
       i.siteCode                                                                               SiteCode,
       d.openmrs_id                                                                             PatientMNCH_ID,
       'KenyaEMR'                                                                               Emr,
       'Kenya HMIS II'                                                                          Project,
       i.facilityName                                                                           FacilityName,
       a.visit_id                                                                               VisitId,
       a.visit_date                                                                             VisitDate,
       e.anc_number                                                                             ANCClinicNumber,
       a.anc_visit_number                                                                       ANCVisitNo,
       a.maturity                                                                               GestationWeeks,
       round(a.height, 2)                                                                       Height,
       round(a.weight, 2)                                                                       Weight,
       round(a.temperature, 1)                                                                  Temp,
       a.pulse_rate                                                                             PulseRate,
       a.respiratory_rate                                                                       RespiratoryRate,
       a.oxygen_saturation                                                                      OxygenSaturation,
       a.muac                                                                                   MUAC,
       concat_ws('/', a.systolic_bp, a.diastolic_bp)                                            BP,
       case a.breast_exam_done when 1115 then 'Normal' when 1116 then 'Abnormal' end            BreastExam,
       case a.anc_exercises when 1065 then 'Yes' when 1066 then 'No' end                        AntenatalExercises,
       (case a.fgm_done when 1065 then "Yes" when 1066 then "No" end)                           FGM,
       (case a.fgm_complications
            when 122949 then "Scarring"
            when 136308 then "Keloids"
            when 141615 then "dyspaneuria"
            when 111633 then "UTI" end)                                                         FGMComplications,
       a.hemoglobin                                                                             Haemoglobin,
       (case a.diabetes_test
            when 664 then "No Diabetes"
            when 703 then "Has Diabetes"
            when 160737 then "Not Done" end)                                                    DiabetesTest,
       case a.tb_screening
           when 1660 then 'NO signs'
           when 142177 then 'TB presumed'
           when 164128 then 'No signs and started on INH'
           when 1662 then 'TB Rx'
           when 160737
               then 'Not done (ND)' end                                                         TBScreening,
       case a.cacx_screening
           when 664 then 'Normal'
           when 159393 then 'Suspected'
           when 703 then 'Confirmed'
           when 1118 then 'Not done'
           when 1175 then 'N/A' end                                                             CACxScreen,
       case a.cacx_screening_method
           when 885 then 'Pap Smear'
           when 162816 then 'VIA'
           when 164977 then 'VILI'
           when 5622
               then 'Other' end                                                                 CACxScreenMethod,
       case a.who_stage
           when 1204 then 1
           when 1205 then 2
           when 1206 then 3
           when 1207
               then 4 end                                                                       WHOStaging,
       case a.vl_sample_taken when 856 then 'Yes' when 1066 then 'No' end                       VLSampleTaken,
       if(a.vl_sample_taken = 856, a.visit_date, '')                                            VLDate,
       coalesce(a.viral_load, a.ldl)                                                            VLResult,
       case a.syphilis_treated_status
           when 1065 then 'Yes'
           when 1066 then 'No'
           else 'NA' end                                                                        SyphilisTreatment,
       case e.hiv_status
           when 703 then 'KP'
           when 1067 then 'Unknown'
           when 664
               then 'Negative' end                                                              HIVStatusBeforeANC,
       if(a.final_test_result is not null, 'Yes',
          'No')                                                                                 HIVTestingDone,
       null                                                                                     HIVTestType,
       a.test_1_kit_name                                                                        HIVTest_1,
       a.test_1_result                                                                          HIVTest_1Result,
       a.test_2_kit_name                                                                        HIVTest_2,
       a.test_2_result                                                                          HIVTest_2Result,
       a.test_3_kit_name                                                                        HIVTest_3,
       a.test_3_result                                                                          HIVTest_3Result,
       a.final_test_result                                                                      HIVTestFinalResult,
       case a.syphilis_test_status
           when 1229 then 'Yes'
           when 1228 then 'Yes'
           when 1271 then 'Yes'
           when 1402 then 'ND'
           when 1304 then 'Yes'
           else 'No' end                                                                        SyphilisTestDone,
       if(a.syphilis_test_status in (1229, 1228, 12711304), 'Dual Testing', null)               SyphilisTestType,
       case a.syphilis_test_status
           when 1229 then 'Negative'
           when 1228 then 'Positive'
           else 'N/A' end                                                                       SyphilisTestResults,
       case a.syphilis_treated_status
           when 1065 then 'Yes'
           when 1066 then 'No'
           else 'NA' end                                                                        SyphilisTreated,
       case a.prophylaxis_given
           when 105281 then 'Yes'
           when 74250 then 'Yes'
           when 1107
               then 'No' end                                                                    MotherProphylaxisGiven,
       a.date_given_haart                                                                       DateMotherStartedHAART,
       if(a.baby_azt_dispensed = 160123 AND a.baby_nvp_dispensed = 80586, 'AN',
          if(a.baby_azt_dispensed = 160123, 'A', if(a.baby_nvp_dispensed = 160123, 'N', NULL))) InfantProphylaxis,
       case a.ABC_3TC_DTG_baby_prophylaxis_dispensed
           when 1065 then 'Yes'
           when 1066
               then 'No' end                     as                                             ABC_3TC_DTG_dispensed,
       case a.baby_azt_dispensed
           when 160123 then 'Yes'
           when 1066 then 'No'
           when 1175
               then 'NA' end                                                                    AZTBabyDispense,
       case a.baby_nvp_dispensed
           when 80586 then 'Yes'
           when 1066 then 'No'
           when 1175
               then 'NA' end                                                                    NVPBabyDispense,
       group_concat(case ci.chronic_illness
                        when 149019 then 'Alzheimers Disease and other Dementias'
                        when 148432 then 'Arthritis'
                        when 153754 then 'Asthma'
                        when 159351 then 'Cancer'
                        when 119270 then 'Cardiovascular diseases'
                        when 120637 then 'Chronic Hepatitis'
                        when 145438 then 'Chronic Kidney Disease'
                        when 1295 then 'Chronic Obstructive Pulmonary Disease(COPD)'
                        when 120576 then 'Chronic Renal Failure'
                        when 119692 then 'Cystic Fibrosis'
                        when 120291 then 'Deafness and Hearing impairment'
                        when 119481 then 'Diabetes'
                        when 118631 then 'Endometriosis'
                        when 117855 then 'Epilepsy'
                        when 117789 then 'Glaucoma'
                        when 139071 then 'Heart Disease'
                        when 115728 then 'Hyperlipidaemia'
                        when 117399 then 'Hypertension'
                        when 117321 then 'Hypothyroidism'
                        when 151342 then 'Mental illness'
                        when 133687 then 'Multiple Sclerosis'
                        when 115115 then 'Obesity'
                        when 114662 then 'Osteoporosis'
                        when 117703 then 'Sickle Cell Anaemia'
                        when 118976 then 'Thyroid disease'
                        end SEPARATOR
                    '|')                                                                        ChronicIllness,
       concat_ws('|', nullif(case a.counselled_on_birth_plans when 159758 then 'Birth plans' end, ''),
                 nullif(case a.counselled_on_danger_signs
                            when 159857 then 'Danger signs' end, ''), nullif(case a.counselled_on_family_planning
                                                                                 when 156277 then 'Family planning'
                                                                                 end, ''),
                 nullif(case a.counselled_on_hiv when 1914 then 'HIV' end, ''),
                 nullif(case a.counselled_on_supplimental_feeding
                            when 159854
                                then 'Supplimental feeding' end, ''),
                 nullif(case a.counselled_on_breast_care when 159856 then 'Breast care' end, ''),
                 nullif(case a.counselled_on_infant_feeding
                            when 161651 then 'Infant feeding' end, ''), nullif(case a.counselled_on_treated_nets
                                                                                   when 1381 then 'ITN'
                                                                                   end,
                                                                               ''))             CounselledOn,
       (case a.hepatitis_b_screening
            when 703 then "Positive"
            when 664 then "Negative"
            when 165649 then "Inconclusive"
            when 160737
                then "Not Done" end)                                                            HepatitisBScreening,
       (case a.maternal_Hep_B_management
            when 1107 then "None"
            when 1185 then "Treatment"
            when 2032267
                then "Prophylaxis" end)                                                         HepBMaternalManagement,
       case a.client_has_partner when 1065 then 'Yes' when 1066 then 'No' end                   ClientPartner,
       case a.partner_hiv_tested
           when 1065 then 'Yes'
           when 1066 then 'No'
           else 'NA' end                                                                        PartnerHIVTestingANC,
       case a.partner_hiv_status
           when 703 then 'HIV Positive'
           when 664 then 'HIV Negative'
           when 1000164 then 'Known HIV Status'
           when 1067
               then 'UNKNOWN' end                                                               PartnerHIVStatusANC,
       a.partner_hiv_test_date                                                                  PartnerHIVTestDate,
       (case a.fp_method_postpartum
            when 5275 then "IUD"
            when 159589 then "Implants"
            when 1472 then "BTL" end)                                                           PostParturmFP,
       a.deworming_done_anc                                                                     Deworming,
       case a.intermittent_presumptive_treatment_given
           when 1065 then 'Yes'
           when 1066 then 'No'
           when 1175 then 'Not Applicable' end   as                                             MalariaProphylaxis,
       a.TTT                                                                                    TetanusDose,
       a.iron_supplement                                                                        IronSupplementsGiven,
       case a.counselled_on_treated_nets when 1381 then 'Yes' end                               ReceivedMosquitoNet,
       concat_ws('|', nullif(case a.TTT when 'Yes' then 'Tetanus Toxoid' end, ''),
                 nullif(case a.intermittent_presumptive_treatment_given when 1065 then 'Malaria Prophylaxis' end,
                        ''),
                 nullif(case a.iron_supplement when 'Yes' then 'Folate / Iron ' end, ''),
                 nullif(case a.deworming_done_anc when 'Yes' then 'Mebendazole' end, ''),
                 nullif(case a.counselled_on_treated_nets
                            when 1381
                                then 'Long-Lasting Insecticidal Net' end,
                        ''))                     as                                             PreventiveServices,
       (case a.intermittent_presumptive_treatment_given
            when 1065 then "Yes"
            when 1066 then "No"
            when 1175
                then "Not Applicable" end)                                                      PresumptiveTreatmentGiven,
       (case a.intermittent_presumptive_treatment_dose
            when 1 then "IPT 1"
            when 2 then "IPT 2"
            when 3 then "IPT 3"
            when 4 then "IPT 4"
            when 5 then "IPT 5"
            when 0
                then "N"
            else 'NA' end)                                                                      PresumptiveTreatmentDose,
       (case a.minimum_care_package when 1065 then "Yes" when 1066 then "No" end)               MiminumPackageofCareReceived,
       a.minimum_package_of_care_services                                                       MiminumPackageofCareServices,
       if(a.urine_microscopy is not null or a.urinary_albumin is not null or a.glucose_measurement is not null
              or a.urine_ph is not null or a.urine_gravity is not null or a.urine_nitrite_test is not null
              or a.urine_dipstick_for_blood is not null or a.urine_leukocyte_esterace_test is not null or
          a.urinary_ketone is not null
              or a.urine_bile_pigment_test is not null or a.urine_bile_salt_test is not null or
          a.urine_colour is not null or a.urine_turbidity is not null, 'Yes',
          'No')                                                                                 UrinalysisVariables,
       case a.referred_from
           when 1537 then 'Another Health Facility'
           when 163488 then 'Community Unit'
           when 1175 then 'N/A' END                                                             ReferredFrom,
       case a.referred_to
           when 163266 then 'This health facility'
           when 1537 then 'Another Health Facility'
           when 163488 then 'Community Unit'
           when 165093 then 'HIV preventive services'
           when 166100 then 'Referral to PLHIV networks'
           when 1175 then 'N/A' END              as                                             ReferredTo,
       ''                                                                                       ReferralReasons,
       a.next_appointment_date                                                                  NextAppointmentANC,
       a.clinical_notes                          as                                             ClinicalNotes,
       d.national_unique_patient_identifier      as                                             NUPI,
       a.date_created                                                                           Date_Created,
       GREATEST(COALESCE(a.date_last_modified, e.date_last_modified, ci.date_last_modified),
                COALESCE(a.date_last_modified, e.date_last_modified,
                         ci.date_last_modified)) as                                             Date_Last_Modified,
       a.voided                                  as                                             voided
from dwapi_etl.etl_patient_demographics d
         join dwapi_etl.etl_mch_antenatal_visit a on d.patient_id = a.patient_id
         left join dwapi_etl.etl_allergy_chronic_illness ci on a.visit_id = ci.visit_id
         join dwapi_etl.etl_mch_enrollment e on d.patient_id = e.patient_id
         join kenyaemr_etl.etl_default_facility_info i
where a.visit_id is not null
group by a.visit_id;
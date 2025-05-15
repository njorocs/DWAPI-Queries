select d.patient_id                                                                       PatientPK,
       p.uuid                                                                          as uuid,
       i.siteCode                                                                         SiteCode,
       d.openmrs_id                                                                       PatientMNCH_ID,
       'KenyaEMR'                                                                         Emr,
       'Kenya HMIS II'                                                                    Project,
       i.facilityName                                                                     FacilityName,
       p.visit_id                                                                         VisitId,
       p.visit_date                                                                       VisitDate,
       p.pnc_register_no                                                                  PNCRegisterNumber,
       d.national_unique_patient_identifier                                               NUPI,
       p.pnc_visit_no                                                                     PNCVisitNo,
       (case p.visit_timing_mother
            when 1721 then '0-48 Hours'
            when 1722 then '3 days - 6 weeks'
            when 1723 then 'More than 6 weeks' end)                                       VisitTimingMother,
       (case p.visit_timing_baby
            when 167012 then '0-48 Hours'
            when 167013 then '3 days - 6 weeks'
            when 167015 then 'More than 6 weeks' end)                                     VisitTimingBaby,
       p.delivery_date                                                                    DeliveryDate,
       case p.mode_of_delivery
           when 1170 then 'Normal delivery'
           when 1171 then 'CS'
           when 1172 then 'Breech'
           when 118159 then 'Assisted vaginal delivery' end                               ModeOfDelivery,
       case p.place_of_delivery
           when 1589 then 'Facility'
           when 1536 then 'Home'
           when 1601 then 'Born Before Arrival'
           when 5622 then 'Other' end                                                     PlaceOfDelivery,
       p.height                                                                           Height,
       p.weight                                                                           Weight,
       p.temperature                                                                      Temp,
       p.pulse_rate                                                                       PulseRate,
       p.respiratory_rate                                                                 RespiratoryRate,
       p.oxygen_saturation                                                                OxygenSaturation,
       p.muac                                                                             MUAC,
       concat_ws('/', p.systolic_bp, p.diastolic_bp)                                      BP,
       if(breast is not null, 'Yes', 'No')                                                BreastExam,
       case p.general_condition
           when 1855 then 'Good'
           when 162133 then 'Fair'
           when 162132 then 'Poor' end                                                 as GeneralCondition,
       case p.pallor when 1065 then 'Yes' when 1066 then 'No' end                      as HasPallor,
       (case p.pallor_severity
            when 1498 then 'Mild'
            when 1499 then 'Moderate'
            when 1500 then 'Severe'
            else '' end)                                                                  Pallor,
       case p.breast
           when 1115 then 'Normal'
           when 143242 then 'Cracked nipple'
           when 127522 then 'Engorged nipple'
           when 115915 then 'Mastitis' end                                                Breast,
       case p.pph when 1065 then 'Present' when 1066 then 'Absent' end                 as PPH,
       case p.cs_scar
           when 147241 then 'Bleeding'
           when 1115 then 'Normal'
           when 156794 then 'Infected'
           when 145776 then 'Gapping'
           when 1175 then 'Not Applicable' end                                         as CSScar,
       case p.gravid_uterus
           when 162111 then 'On exam, uterine fundus 12-16 week size'
           when 162112 then 'On exam, uterine fundus 16-20 week size'
           when 162113 then 'On exam, uterine fundus 20-24 week size'
           when 162114 then 'On exam, uterine fundus 24-28 week size'
           when 162115 then 'On exam, uterine fundus 28-32 week size'
           when 162116 then 'On exam, uterine fundus 32-34 week size'
           when 162117 then 'On exam, uterine fundus 34-36 week size'
           when 162118 then 'On exam, uterine fundus 36-38 week size'
           when 123427 then 'Uterus Involuted' end                                     as UterusInvolution,
       case p.episiotomy
           when 159842 then 'Repaired'
           when 159843 then 'Healed'
           when 159841 then 'Gaping'
           when 113919 then 'Infected'
           when 1175 then 'Not Applicable' end                                         as Episiotomy,
       case p.lochia
           when 159721 then 'Normal'
           when 159846 then 'Foul smelling'
           when 159845 then 'Excessive' end                                            as Lochia,
       case p.fistula_screening
           when 1107 then 'None'
           when 49 then 'Vesicovaginal Fistula'
           when 127847 then 'Rectovaginal fistula'
           when 111521 then 'Vesicovaginal Reflux'
           when 1118 then 'Not done' end                                               as Fistula,
       ''                                                                              as MaternalComplications,
       (case tb.resulting_tb_status
            when 1660 then "No TB Signs"
            when 142177 then "Presumed TB"
            when 1662 then "TB Confirmed"
            when 160737 then "TB Screening Not Done"
            else "" end)                                                                  TBScreening,
       if(p.cacx_screening in (664, 703, 159393), 'Yes', 'No')                         as ClientScreenedCACx,
       case p.cacx_screening_method
           when 885 then 'Pap Smear'
           when 162816 then 'VIA'
           when 164977 then 'VILI'
           when 5622 then 'Other' end                                                  as CACxScreenMethod,
       case p.cacx_screening
           when 664 then 'Normal'
           when 159393 then 'Suspected'
           when 703 then 'Confirmed'
           when 1118 then 'Not done'
           when 1175 then 'N/A' end                                                    as CACxScreenResults,
       case e.hiv_status
           when 703 then 'Positive'
           when 664 then 'Negative'
           when 1067 then 'Unknown' end                                                as PriorHIVStatus,
       (case p.infant_prophylaxis_timing
            when 1065 then 'Less than 6 weeks'
            when 1066 then 'Greater 6 weeks' end)                                         InfactCameForHAART,
       (case p.mother_haart_given
            when 1065 then 'Yes'
            when 1066 then 'No'
            when 1175 then 'N/A'
            when 164142 then 'Revisit'
            else '' end)                                                                  MotherGivenHAART,
       if(p.final_test_result is not null, 'Yes', 'No')                                   HIVTestingDone,
       p.test_1_kit_lot_no                                                                HIVTest_1,
       p.test_1_result                                                                    HIVTest_1Result,
       p.test_2_kit_lot_no                                                                HIVTest_2,
       p.test_2_result                                                                    HIVTest_2Result,
       p.test_3_kit_lot_no                                                                HIVTest_3,
       p.final_test_result                                                                HIVTestFinalResult,
       if(p.baby_nvp_dispensed = 80586 or p.baby_azt_dispensed = 160123, 'Yes', 'No')  as InfantProphylaxisGiven,
       if(p.prophylaxis_given in (105281, 74250), 'Yes', 'No')                         as MotherProphylaxisGiven,
       (case p.couple_counselled when 1065 then "Yes" when 1066 then "No" else "" end) as CoupleCounselled,
       case p.partner_hiv_tested
           when 1065 then 'Yes'
           when 1066 then 'No'
           else 'N/A' end                                                              as PartnerHIVTestingPNC,
       case p.partner_hiv_status
           when 703 then 'Positive'
           when 664 then 'Negative'
           when 1067 then 'Unknown' end                                                as PartnerHIVResultPNC,
       case p.family_planning_counseling
           when 1065 then 'Yes'
           when 1066 then 'No'
           else '' end                                                                 as CounselledOnFP,
       case p.family_planning_method
           when 160570 then 'Emergency contraceptive pills'
           when 780 then 'Oral Contraceptives Pills'
           when 5279 then 'Injectable'
           when 1359 then 'Implant'
           when 136163 then 'Lactational Amenorhea Method'
           when 5275 then 'Intrauterine Device'
           when 5278 then 'Diaphram/Cervical Cap'
           when 5277 then 'Fertility Awareness'
           when 1472 then 'Tubal Ligation/Female sterilization'
           when 190 then 'Condoms'
           when 1489 then 'Vasectomy(Partner)'
           when 162332 then 'Undecided'
           else '' end                                                                 as ReceivedFP,
       case p.iron_supplementation when 1065 then 'Yes' when 1066 then 'No' end        as HaematinicsGiven,
       (case p.delivery_outcome
            when 159913 then 'Single'
            when 159914 then 'Twins'
            when 159915 then 'Triplets' end)                                           as DeliveryOutcome,
       case p.condition_of_baby
           when 1855 then 'Good'
           when 162133 then 'Poor'
           when 162132 then 'Died' end                                                 as BabyCondition,
       case p.baby_feeding_method
           when 5526 then 'Breastfed exclusively'
           when 1595 then 'Replacement feeding'
           when 6046 then 'Mixed feeding'
           when 159418 then 'Not at all sure' end                                      as BabyFeeding,
       case p.umblical_cord
           when 162122 then 'Neonatal umbilical stump clean'
           when 162123 then 'Neonatal umbilical stump not clean'
           when 162124 then 'Neonatal umbilical stump moist'
           when 162120 then 'Neonatal umbilical stump dry'
           when 162125 then 'Neonatal umbilical stump not healed'
           when 162126 then 'Neonatal umbilical stump healed' end                      as UmbilicalCord,
       case p.baby_immunization_started
           when 1065 then 'Yes'
           when 1066 then 'No'
           when 1067 then 'Unknown' end                                                as Immunization,
       case p.counselled_on_infant_feeding
           when 1065 then 'Yes'
           when 1066
               then 'No' end                                                           as InfantFeeding,
       ps.preventive_services                                                          as PreventiveServices,
       case p.referred_from
           when 1537 then 'Another Health Facility'
           when 163488 then 'Community Unit'
           when 1175 then 'N/A' end                                                    as ReferredFrom,
       case p.referred_to
           when 1537 then 'Another Health Facility'
           when 163488 then 'Community Unit'
           when 1175 then 'N/A' end                                                    as ReferredTo,
       p.referral_reason                                                               as ReferralReason,
       p.appointment_date                                                              as NextAppointmentPNC,
       p.clinical_notes                                                                as ClinicalNotes,
       p.date_created                                                                  as Date_Created,
       p.date_last_modified                                                            as Date_Last_Modified,
       p.voided                                                                        as voided
from dwapi_etl.etl_patient_demographics d
         inner join dwapi_etl.etl_mch_postnatal_visit p on d.patient_id = p.patient_id
         inner join (select e.patient_id, mid(max(concat(e.visit_date, e.hiv_status)), 11) as hiv_status
                     from dwapi_etl.etl_mch_enrollment e
                     group by e.patient_id) e on d.patient_id = e.patient_id
         left join (select tb.patient_id, tb.resulting_tb_status, tb.visit_date
                    from dwapi_etl.etl_tb_screening tb) tb
                   on tb.patient_id = p.patient_id and tb.visit_date = p.visit_date
         left join (select ps.patient_id,
                           ps.visit_date,
                           group_concat(CONCAT_WS(',',
                                                  if(DAYNAME(ps.malaria_prophylaxis_1) IS NOT NULL,
                                                     'Malaria prohylaxis 1st dose', NULL),
                                                  if(DAYNAME(ps.malaria_prophylaxis_2) IS NOT NULL,
                                                     'Malaria prohylaxis 2nd dose', NULL),
                                                  if(DAYNAME(ps.malaria_prophylaxis_3) IS NOT NULL,
                                                     'Malaria prohylaxis 3rd dose', NULL),
                                                  if(DAYNAME(ps.tetanus_taxoid_1) IS NOT NULL,
                                                     'Tetanus Taxoid 1st dose', NULL),
                                                  if(DAYNAME(ps.tetanus_taxoid_2) IS NOT NULL,
                                                     'Tetanus Taxoid 2nd dose', NULL),
                                                  if(DAYNAME(ps.tetanus_taxoid_3) IS NOT NULL,
                                                     'Tetanus Taxoid 3rd dose', NULL),
                                                  if(DAYNAME(ps.tetanus_taxoid_4) IS NOT NULL,
                                                     'Tetanus Taxoid 4th dose', NULL),
                                                  if(DAYNAME(ps.folate_iron_1) IS NOT NULL, 'Folate Iron 1st dose',
                                                     NULL),
                                                  if(DAYNAME(ps.folate_iron_2) IS NOT NULL, 'Folate Iron 2nd dose',
                                                     NULL),
                                                  if(DAYNAME(ps.folate_iron_3) IS NOT NULL, 'Folate Iron 3rd dose',
                                                     NULL),
                                                  if(DAYNAME(ps.folate_iron_4) IS NOT NULL, 'Folate Iron 4th dose',
                                                     NULL),
                                                  if(DAYNAME(ps.folate_1) IS NOT NULL, 'Folate 1st dose', NULL),
                                                  if(DAYNAME(ps.folate_2) IS NOT NULL, 'Folate 2nd dose', NULL),
                                                  if(DAYNAME(ps.folate_3) IS NOT NULL, 'Folate 3rd dose', NULL),
                                                  if(DAYNAME(ps.folate_4) IS NOT NULL, 'Folate 4th dose', NULL),
                                                  if(DAYNAME(ps.iron_1) IS NOT NULL, 'Iron 1st dose', NULL),
                                                  if(DAYNAME(ps.iron_2) IS NOT NULL, 'Iron 2nd dose', NULL),
                                                  if(DAYNAME(ps.iron_3) IS NOT NULL, 'Iron 3rd dose', NULL),
                                                  if(DAYNAME(ps.iron_4) IS NOT NULL, 'Iron 4th dose', NULL),
                                                  if(DAYNAME(ps.mebendazole) IS NOT NULL, 'Mebendazole', NULL),
                                                  if(DAYNAME(ps.long_lasting_insecticidal_net) IS NOT NULL,
                                                     'Long Lasting Insecticidal Net', NULL))) as preventive_services
                    from dwapi_etl.etl_preventive_services ps
                    group by ps.patient_id, ps.visit_date) ps
                   on p.patient_id = ps.patient_id and p.visit_date = ps.visit_date
         inner join kenyaemr_etl.etl_default_facility_info i
group by p.visit_id;
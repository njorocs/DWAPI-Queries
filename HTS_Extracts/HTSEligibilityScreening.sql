SELECT t.patient_id                                                                as PatientPK,
       t.uuid                                                                      as uuid,
       i.siteCode                                                                  as SiteCode,
       i.FacilityName                                                              as FacilityName,
       'KenyaEMR'                                                                  as Emr,
       'Kenya HMIS II'                                                             as Project,
       demographics.openmrs_id                                                     as HtsNumber,
       t.visit_id                                                                  as VisitID,
       t.encounter_id                                                              as EncounterId,
       t.visit_date                                                                as VisitDate,
       case t.population_type
           when 164928 then 'General Population'
           when 164929 then 'Key and Vulnerable Population'
           when 138643
               then 'Priority Population' end                                      as PopulationType,
       t.key_population_type                                                       as KeyAndVulnerablePopulation,
       t.priority_population_type                                                  as PriorityPopulation,
       t.patient_disabled                                                          as Disability,
       t.disability_type                                                           as DisabilityType,
       case t.test_strategy
           when 164163 then "HP: Hospital Patient Testing"
           when 164953 then "NP: HTS for non-patients"
           when 164954 then "VI:Integrated VCT Center"
           when 164955 then "VS:Stand Alone VCT Center"
           when 159938 then "HB:Home Based Testing"
           when 159939 then "MO: Mobile Outreach HTS"
           when 161557 then "Index testing"
           when 166606 then "SNS - Social Networks"
           when 5622
               then "O:Other" end                                                  as HTSStrategy,
       (case t.hts_entry_point
            when 5485 then "In Patient Department(IPD)"
            when 160542 then "Out Patient Department(OPD)"
            when 162181 then "Peadiatric Clinic"
            when 160552 then "Nutrition Clinic"
            when 160538 then "PMTCT ANC"
            when 160456 then "PMTCT MAT"
            when 1623 then "PMTCT PNC"
            when 160541 then "TB"
            when 162050 then "CCC"
            when 159940 then "VCT"
            when 159938 then "Home Based Testing"
            when 159939 then "Mobile Outreach"
            when 162223 then "VMMC"
            when 160546 then "STI Clinic"
            when 160522 then "Emergency"
            when 163096 then "Community Testing"
            when 5622
                then "Other" end)                                                  as HTSEntryPoint,
       t.hts_risk_category                                                         as HIVRiskCategory,
       t.hts_risk_score                                                            as HTSRiskScore,
       case t.department
           when 160542 then 'OPD:Out-patient department'
           when 5485 then 'IPD:In-patient department'
           when 160473 then 'Emergency'
           when 160538 then 'PMTCT'
           when 159940
               then 'VCT' end                                                      as Department,
       case t.patient_type
           when 164163 then 'HP:Hospital Patient'
           when 164953
               then 'NP:Non-Hospital Patient' end                                  as PatientType,
       case t.is_health_worker when 1065 then 'Yes' when 1066 then 'No' end        as IsHealthWorker,
       t.relationship_with_contact                                                 as RelationshipWithContact,
       case t.mother_hiv_status
           when 703 then 'Positive'
           when 664 then 'Negative'
           when 1067
               then 'Unknown' end                                                  as MothersStatus,
       case t.tested_hiv_before when 1065 then 'Yes' when 1066 then 'No' end       as TestedHIVBefore,
       case t.who_performed_test
           when 5619 then 'HTS Provider'
           when 164952
               then 'Self Tested' end                                              as WhoPerformedTest,
       (case t.test_results
            when 703 then 'Positive'
            when 664 then 'Negative'
            when 1067 then 'Unknown'
            else '' end)                                                           as ResultOfHIV,
       if(t.who_performed_test = 164952, t.date_tested, null)                      as DateTestedSelf,
       if(t.who_performed_test = 164952, case t.test_results
                                             when 703 then 'Positive'
                                             when 664 then 'Negative'
                                             when 1067 then 'Unknown'
                                             else '' end,
          null)                                                                    as ResultOfHIVSelf,
       if(t.who_performed_test = 5619, t.date_tested, null)                        as DateTestedProvider,
       case t.started_on_art when 1065 then 'Yes' when 1066 then 'No' end          as StartedOnART,
       t.upn_number                                                                as CCCNumber,
       case t.ever_had_sex
           when 1 then 'Yes'
           when 0 then 'No'
           end                                                                     as EverHadSex,
       case t.child_defiled
           when 1065 then 'Yes'
           when 1066 then 'No'
           when 162570
               then 'Declined to answer' end                                       as ChildDefiled,
       t.sexually_active                                                           as SexuallyActive,
       t.new_partner                                                               as NewPartner,
       t.partner_hiv_status                                                        as PartnerHIVStatus,
       case t.couple_discordant when 1065 then 'Yes' when 1066 then 'No' end       as CoupleDiscordant,
       t.multiple_partners                                                         as MultiplePartners,
       t.number_partners                                                           as NumberOfPartners,
       case t.alcohol_sex
           when 1066 then 'Not at all'
           when 1385 then 'Sometimes'
           when 165027
               then 'Always' end                                                   as AlcoholSex,
       t.money_sex                                                                 as MoneySex,
       t.condom_burst                                                              as CondomBurst,
       t.unknown_status_partner                                                    as UnknownStatusPartner,
       t.known_status_partner                                                      as KnownStatusPartner,
       t.pregnant                                                                  as Pregnant,
       t.breastfeeding_mother                                                      as BreastfeedingMother,
       t.experienced_gbv                                                           as ExperiencedViolence,
       t.type_of_gbv                                                               as TypeOfViolence,
       t.service_received                                                          as ReceivedServices,
       t.currently_on_prep                                                         as CurrentlyOnPrEP,
       t.recently_on_pep                                                           as CurrentlyOnPEP,
       t.recently_had_sti                                                          as CurrentlyHasSTI,
       t.tb_screened                                                                  ScreenedTB,
       case t.cough when 159799 then 'Yes' when 1066 then 'No' end                 as Cough,
       case t.fever when 1494 then 'Yes' when 1066 then 'No' end                   as Fever,
       case t.weight_loss when 832 then 'Yes' when 1066 then 'No' end              as WeightLoss,
       case t.night_sweats when 133027 then 'Yes' when 1066 then 'No' end          as NightSweats,
       case t.contact_with_tb_case when 124068 then 'Yes' when 1066 then 'No' end  as ContactWithTBCase,
       case t.lethargy when 116334 then 'Yes' when 1066 then 'No' end              as Lethargy,
       case t.tb_status
           when 1660 then 'No TB signs'
           when 142177 then 'Presumed TB'
           when 1662
               then 'TB Confirmed' end                                             as TBStatus,
       case t.shared_needle when 1065 then 'Yes' when 1066 then 'No' end           as SharedNeedle,
       case t.needle_stick_injuries when 153574 then 'Yes' when 1066 then 'No' end as NeedleStickInjuries,
       case t.traditional_procedures when 1065 then 'Yes' when 1066 then 'No' end  as TraditionalProcedures,
       t.child_reasons_for_ineligibility                                           as ChildReasonsForIneligibility,
       ''                                                                          as AssessmentOutcome,
       case t.eligible_for_test when 1065 then 'Yes' when 1066 then 'No' end       as EligibleForTest,
       t.recommended_test                                                          as RecommendedTest,
       case t.referred_for_testing when 1065 then 'Yes' when 1066 then 'No' end    as ReferredForTesting,
       t.reason_to_test                                                            as ReasonRefferredForTesting,
       t.reason_not_to_test                                                        as ReasonNotReffered,
       t.reasons_for_ineligibility                                                 as ReasonsForIneligibility,
       t.specific_reason_for_ineligibility                                         as SpecificReasonForIneligibility,
       t.date_created                                                              as DateCreated,
       t.date_last_modified                                                        as DateLastModified,
       t.voided                                                                    as voided
FROM dwapi_etl.etl_hts_eligibility_screening t
         inner join dwapi_etl.etl_patient_demographics demographics on t.patient_id = demographics.patient_id
         JOIN kenyaemr_etl.etl_default_facility_info i;
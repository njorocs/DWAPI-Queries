#CASE MANAGEMENT EXTRACT
-- Home visit checklist
select d.patient_id                                                                          as PatientPK,
       ''                                                                                    as PatientPKHash,
       h.uuid                                                                                as uuid,
       s.siteCode                                                                            as SiteCode,
       d.unique_patient_no                                                                   as PatientID,
       ''                                                                                    as PatientIDHash,
       0                                                                                     as FacilityId,
       'KenyaEMR'                                                                            as Emr,
       'Kenya HMIS III'                                                                      as Project,
       s.FacilityName                                                                        as FacilityName,
       h.visit_date                                                                          as EncounterDate,
       h.independence_in_daily_activities                                                    as PatientIndependentinActivities,
       h.other_independence_activities                                                       as OtherIndependenceActivities,
       h.meeting_basic_needs                                                                 as BasicNeedsMet,
       h.other_basic_needs                                                                   as OtherBasicNeeds,
       case h.disclosure_to_sexual_partner
           when 1065 then 'Yes'
           when 1066
               then 'No' end                                                                 as SexualPartnerAndDisclosure,
       case h.disclosure_to_household_members when 1065 then 'Yes' when 1066 then 'No' end   as Disclosure,
       h.disclosure_to                                                                       as Disclosedto,
       h.mode_of_storing_arv_drugs                                                           as ARVsStored,
       h.arv_drugs_taking_regime                                                             as ARVsTaken,
       case h.receives_household_social_support when 1065 then 'Yes' when 1066 then 'No' end as SupportGiven,
       h.household_social_support_given                                                      as HouseholdSupportGiven,
       case h.receives_community_social_support when 1065 then 'Yes' when 1066 then 'No' end as ReceivingSocialSupport,
       h.community_social_support_given                                                      as CommunitySupportGiven,
       h.linked_to_non_clinical_services                                                     as LinkedtoNonClinicalServices,
       h.linked_to_other_services                                                            as LinkedtoOtherServices,
       case h.has_mental_health_issues when 1065 then 'Yes' when 1066 then 'No' end          as MentalHealthIssues,
       case h.suffering_stressful_situation when 1065 then 'Yes' when 1066 then 'No' end     as IsStressed,
       case h.uses_drugs_alcohol when 1065 then 'Yes' when 1066 then 'No' end                as DrugandAlcoholUse,
       case h.has_side_medications_effects when 1065 then 'Yes' when 1066 then 'No' end      as HasSideEffects,
       h.medication_side_effects,
       h.assessment_notes,
       h.date_created                                                                        as Date_Created,
       h.date_last_modified                                                                  as Date_Last_Modified,
       h.voided                                                                              as voided
from dwapi_etl.etl_patient_demographics d
         inner join dwapi_etl.etl_home_visit_checklist h
                    on d.patient_id = h.patient_id
         join kenyaemr_etl.etl_default_facility_info s;
select d.patient_id                                                                 as PatientPK,
       h.uuid                                                                       as uuid,
       i.siteCode                                                                   as SiteCode,
       d.unique_prep_number                                                         as PrepNumber,
       d.openmrs_id                                                                 as HtsNumber,
       'KenyaEMR'                                                                   as Emr,
       'HMIS'                                                                       as Project,
       h.visit_date                                                                 as VisitDate,
       h.visit_id                                                                   as VisitId,
       h.sexual_partner_hiv_status                                                  as SexPartnerHIVStatus,
       h.sexual_partner_on_art                                                      as IsHIVPositivePartnerCurrentonART,
       (case h.high_risk_partner when 'High risk partner' then 'Yes' else 'No' end) as IsPartnerHighRisk,
       h.risk                                                                       as PartnerARTRisk,
       concat_ws(',', case sex_with_multiple_partners when 'Yes' then 'Has Sex with more than one partner' end,
                 case ipv_gbv when 'Yes' then 'Ongoing IPVor/and Violence' end,
                 case transactional_sex when 'Yes' then 'Transactional sex' end,
                 case recent_sti_infected when 'Yes' then 'Recent STI in the last 6 months' end,
                 case recurrent_pep_use when 'Yes' then 'Recurrent use of PEP' end,
                 case recurrent_sex_under_influence
                     when 'Yes' then 'Recurrent sex under influence of alcohol/recreational drugs'
                     end,
                 case inconsistent_no_condom_use when 'Yes' then 'Inconsistent or no condom use' end,
                 case sharing_drug_needles
                     when 'Yes' then 'IDU with shared needles and/or syringes'
                     end, other_reason_specify)                                     as ClientAssessments,
       h.assessment_outcome                                                         as ClientRisk,
       h.willing_to_take_prep                                                       as ClientWillingToTakePrEP,
       h.reason_not_willing                                                         as PrEPDeclineReason,
       h.risk_edu_offered                                                           as RiskReductionEducationOffered,
       h.referral_for_prevention_services                                           as ReferralToOtherPrevServices,
       date(h.time_partner_hiv_positive_known)                                      as FirstEstablishPartnerStatus,
       h.partner_enrolled_ccc                                                       as PartnerEnrolledToCCC,
       h.partner_ccc_number                                                         as HIVPartnerCCCNumber,
       h.partner_art_start_date                                                     as HIVPartnerARTStartDate,
       h.HIV_serodiscordant_duration_months                                         as MonthsKnownHIVSeroDiscordant,
       h.recent_unprotected_sex_with_positive_partner                               as SexWithoutCondom,
       h.children_with_hiv_positive_partner                                         as NumberofchildrenWithPartner,
       h.date_created                                                               as DateCreated,
       h.date_last_modified                                                         as DateLastModified,
       h.voided                                                                     as voided
from dwapi_etl.etl_prep_behaviour_risk_assessment h
         inner join dwapi_etl.etl_prep_enrolment e on h.patient_id = e.patient_id
         inner join dwapi_etl.etl_patient_demographics d on e.patient_id = d.patient_id
         join kenyaemr_etl.etl_default_facility_info i;
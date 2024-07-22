select ci.patient_id                                             as PatientPK,
       ci.uuid                                                   as uuid,
       s.siteCode                                                as SiteCode,
       de.unique_patient_no                                      as PatientID,
       0                                                         AS FacilityId,
       'KenyaEMR'                                                as Emr,
       'Kenya HMIS II'                                           as Project,
       s.FacilityName                                            as FacilityName,
       ci.visit_date                                             as VisitDate,
       ci.visit_id                                               as VisitID,
       if(ci.chronic_illness in (149019,148432,153754,159351,119270,120637,145438,1295,120576,119692,120291,119481,118631,117855,117789,139071,115728,117399,117321,151342,133687,115115,114662,117703,118976,141623),'Yes', 'No') as PatientHasChronicIllness,
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
                        when 141623 then 'Dyslipidemia'
                        end SEPARATOR
                    '|')                                         as ChronicIllness,
       group_concat(CASE ci.is_chronic_illness_controlled
                        when 1065 then 'Yes'
                        when 1066 then 'No'
                        else 'N/A'
           end SEPARATOR '|' )			                    as Controlled,
       group_concat(ci.chronic_illness_onset_date SEPARATOR '|') as ChronicOnsetDate,
       (case coalesce(v.has_known_allergies, p.known_allergies)
            when 1 then 'Yes'
            when 2
                then 'No' end)                                   as knownAllergies,
       group_concat(case ci.allergy_causative_agent
                        when 162543 then 'Beef'
                        when 72609 then 'Caffeine'
                        when 162544 then 'Chocolate'
                        when 162545 then 'Dairy Food'
                        when 162171 then 'Eggs'
                        when 162546 then 'Fish'
                        when 162547 then 'Milk Protein'
                        when 162172 then 'Peanuts'
                        when 162175 then 'Shellfish'
                        when 162176 then 'Soy'
                        when 162548 then 'Strawberries'
                        when 162177 then 'Wheat'
                        when 162542 then 'Adhesive Tape'
                        when 162536 then 'Bee Stings'
                        when 162537 then 'Dust'
                        when 162538 then 'Latex'
                        when 162539 then 'Mold'
                        when 162540 then 'Pollen'
                        when 162541 then 'Ragweed'
                        when 5622 then 'Other'
                        end SEPARATOR
                    '|')                                         as AllergyCausativeAgent,
       group_concat(case ci.allergy_reaction
                        when 1067 then 'Unknown'
                        when 121629 then 'Anaemia'
                        when 148888 then 'Anaphylaxis'
                        when 148787 then 'Angioedema'
                        when 120148 then 'Arrhythmia'
                        when 108 then 'Bronchospasm'
                        when 143264 then 'Cough'
                        when 142412 then 'Diarrhea'
                        when 118773 then 'Dystonia'
                        when 140238 then 'Fever'
                        when 140039 then 'Flushing'
                        when 139581 then 'GI upset'
                        when 139084 then 'Headache'
                        when 159098 then 'Hepatotoxicity'
                        when 111061 then 'Hives'
                        when 117399 then 'Hypertension'
                        when 879 then 'Itching'
                        when 121677 then 'Mental status change'
                        when 159347 then 'Musculoskeletal pain'
                        when 121 then 'Myalgia'
                        when 512 then 'Rash'
                        when 5622 then 'Other'
                        end SEPARATOR
                    '|')                                         as AllergicReaction,
       group_concat(case ci.allergy_severity
                        when 160754 then 'Mild'
                        when 160755 then 'Moderate'
                        when 160756 then 'Severe'
                        when 160758 then 'Fatal'
                        when 1067 then 'Unknown'
                        end SEPARATOR
                    '|')                                         as AllergySeverity,
       group_concat(ci.allergy_onset_date SEPARATOR '|')         as AllergyOnsetDate,
       ''                                                        as Skin,
       ''                                                        as Eyes,
       ''                                                        as ENT,
       ''                                                        as Chest,
       ''                                                        as CVS,
       ''                                                        as Abdomen,
       ''                                                        as CNS,
       ''                                                        AS Genitourinary,
       ci.date_created                                           as Date_Created,
       max(ci.date_last_modified)                                as Date_Last_Modified,
       ci.voided as voided
from dwapi_etl.etl_allergy_chronic_illness ci
         left join (select e.patient_id, max(e.visit_date) as latest_enrolment_date,uuid
                    from dwapi_etl.etl_hiv_enrollment e
                    group by e.patient_id) e on ci.patient_id = e.patient_id
         left join (select pe.patient_id, max(pe.visit_date) as prep_latest_enrolment_date,uuid
                    from dwapi_etl.etl_prep_enrolment pe
                    group by pe.patient_id) pe on ci.patient_id = pe.patient_id
         left join dwapi_etl.etl_patient_hiv_followup v on ci.encounter_id = v.encounter_id
         left join dwapi_etl.etl_prep_followup p on ci.encounter_id = p.encounter_id
         left join (select d.patient_id as                                                           hiv_disc_patient,
                           coalesce(max(date(d.effective_discontinuation_date)), date(d.visit_date)) hiv_outcome_date
                    from dwapi_etl.etl_patient_program_discontinuation d
                    where program_name = 'HIV'
                    group by d.patient_id) d on d.hiv_disc_patient = ci.patient_id
         left join (select d.patient_id as         PrEP_disc_patient,
                           max(date(d.visit_date)) PrEP_Outcome_date
                    from dwapi_etl.etl_prep_discontinuation d
                    group by d.patient_id) pd on pd.PrEP_disc_patient = ci.patient_id
         inner join dwapi_etl.etl_patient_demographics de on ci.patient_id = de.patient_id
         join kenyaemr_etl.etl_default_facility_info s
where ((d.hiv_disc_patient is null
    or d.hiv_outcome_date < e.latest_enrolment_date)
   or (pd.PrEP_disc_patient is null or pd.PrEP_Outcome_date < pe.prep_latest_enrolment_date)) and ci.complaint is null
group by ci.patient_id, ci.visit_date;

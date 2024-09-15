select v.patient_related_to                              as PatientPK,
       v.uuid                                            as uuid,
       v.patient_id                                      as ContactPatientPK,
       s.siteCode                                        as SiteCode,
       de.unique_patient_no                              as PatientID,
       'KenyaEMR'                                        as Emr,
       'Kenya HMIS II'                                   as Project,
       0                                                 AS FacilityId,
       s.FacilityName                                    as FacilityName,
       v.patient_id                                      as PartnerPersonID,
       timestampdiff(YEAR, date(de.DOB), current_date()) as ContactAge,
       de.gender                                         as ContactSex,
       de.marital_status                                 as ContactMaritalStatus,
       (case v.relationship_type
            when 2 then 'Sibling'
            when 3 then 'Child'
            when 6 then 'Spouse'
            when 7 then 'Partner'
            when 8 then 'Co-wife'
            when 9 then 'Injectable drug user'
            when 12 then 'SNS' end)                      as RelationshipWithPatient,
       if(v.ipv_outcome is not null, 'Yes', 'No')        as ScreenedForIpv,
       ''                                                as IpvScreening,
       v.ipv_outcome                                     as IPVScreeningOutcome,
       (case v.living_with_patient
            when 1065 then "Yes"
            when 1066 then "No"
            else "" end)                                 as CurrentlyLivingWithIndexClient,
       v.baseline_hiv_status                             as KnowledgeOfHivStatus,
       (case v.pns_approach
            when 162284 then "Dual referral"
            when 160551 then "Passive referral"
            when 161642 then "Contract referral"
            when 163096 then "Provider referral"
            else "" end)                                 as PnsApproach,
       v.date_created                                    as Date_Created,
       v.date_last_modified                              as Date_Last_Modified,
       v.voided                                          as voided
from dwapi_etl.etl_patient_contact v
         inner join dwapi_etl.etl_patient_demographics de on v.patient_related_to = de.patient_id
         inner join (select e.patient_id, max(e.visit_date) as latest_enrolment_date
                     from dwapi_etl.etl_hiv_enrollment e
                     group by e.patient_id) e on v.patient_related_to = e.patient_id
         left join (select d.patient_id as                                                           disc_patient,
                           coalesce(max(date(d.effective_discontinuation_date)), date(d.visit_date)) Outcome_date
                    from dwapi_etl.etl_patient_program_discontinuation d
                    where program_name = 'HIV'
                    group by d.patient_id) d on d.disc_patient = v.patient_id
         join kenyaemr_etl.etl_default_facility_info s
where d.disc_patient is null
   or d.Outcome_date < e.latest_enrolment_date;
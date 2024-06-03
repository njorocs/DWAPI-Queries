select v.patient_id                                                                               as PatientPK,
       v.uuid                                                                                     as uuid,
       site.siteCode                                                                              as SiteCode,
       de.unique_patient_no                                                                       as PatientID,
       0                                                                                          AS FacilityId,
       'KenyaEMR'                                                                                 as Emr,
       'Kenya HMIS II'                                                                            as Project,
       site.FacilityName                                                                          as FacilityName,
       coalesce(v.visit_date, s.visit_date)                                                       as VisitDate,
       coalesce(v.visit_id, s.visit_id)                                                           as VisitID,
       case v.on_anti_tb_drugs when 1065 then 'Yes' when 1066 then 'No' end                       as OnTBDrugs,
       coalesce(case v.on_ipt when 1065 then 'Yes' when 1066 then 'No' end, if(i.isStarted is not null and
                                                                               coalesce(v.visit_date, s.visit_date) between i.TPT_Initiation_date and d.Outcome_date,
                                                                               'Yes',
                                                                               'No'))             as OnIPT,
       i.TPT_Initiation_date                                                                      as TPTInitiationDate,
       coalesce(case v.ever_on_ipt when 1065 then 'Yes' when 1066 then 'No' end, if(i.isStarted is not null and
                                                                                    coalesce(v.visit_date, s.visit_date) >=
                                                                                    i.TPT_Initiation_date,
                                                                                    'Yes', 'No')) as EverOnIPT,
       (case s.cough when 159799 then 'Yes' when 1066 then 'No' end)                              as Cough,
       (case s.fever when 1494 then 'Yes' when 1066 then 'No' end)                                as Fever,
       (case s.weight_loss_poor_gain when 832 then 'Yes' when 1066 then 'No' end)                 as NoticeableWeightLoss,
       (case s.night_sweats when 133027 then 'Yes' when 1066 then 'No' end)                       as NightSweats,
       (case s.lethargy when 116334 then 'Yes' when 1066 then 'No' end)                           as Lethargy,
       concat_ws('|', case v.spatum_smear_ordered when 307 then 'Sputum smear' end,
                 case v.chest_xray_ordered when 12 then 'Chest Xray' end,
                 case v.genexpert_ordered when 162202 then 'GeneXpert' end)                       as ICFActionTaken,
       f.hepatotoxity as Hepatoxicity,
       f.peripheral_neuropathy as PeripheralNeuropathy,
       f.rash as Rash,
       f.adherence as Adherence,
       concat_ws('|', case v.spatum_smear_result
                          when 703 then 'Positive'
                          when 664 then 'Negative' end, case v.chest_xray_result
                                                            when 1115 then 'Normal'
                                                            when 152526 then 'Abnormal' end,
                 case v.genexpert_result
                     when 162203 then 'Mycobacterium Tuberculosis detected with Rifampicin resistance'
                     when 664 then 'Negative'
                     when 162204 then 'Mycobacterium Tuberculosis detected without Rifampicin resisrctance'
                     when 164104 then 'Mycobacterium tuberculosis detected with indeterminate rifampin resistance'
                     when 163611 then 'Invalid'
                     when 1138 then 'Indeterminate' end)                                          as TestResult,
       (case v.clinical_tb_diagnosis
            when 703 then 'Positive'
            when 664
                then 'Negative' end)                                                              as TBClinicalDiagnosis,
       (case v.contact_invitation when 1065 then 'Yes' when 1066 then 'No' end)                   as ContactsInvited,
       (case v.evaluated_for_ipt when 1065 then 'Yes' when 1066 then 'No' end)                    as EvaluatedForIPT,
       (case started_anti_TB when 1065 then 'Yes' when 1066 then 'No' end)                        as StartAntiTBs,
       v.tb_rx_date                                                                               as TBRxStartDate,
       (case v.tb_status
            when 1660 then 'No Signs'
            when 142177 then 'Presumed TB'
            when 1662 then 'TB Confirmed'
            when 160737 then 'TB Screening not done' end)                                         as TBScreening,
       s.IPTClientWorkUp                                                                          as IPTClientWorkUp,
       if(i.isStarted is not null and i.TPT_Initiation_date =
                                      coalesce(v.visit_date, s.visit_date),
          'Yes', 'No')                                                                            as StartIPT,
       if(ifnull(i.IndicationForIPT, ''), '', i.IndicationForIPT)                                 as IndicationForIPT,
       d.IPT_disc_reason                                                                          as IPTDiscontinuation,
       d.Outcome_date                                                                             as DateOfDiscontinuation,
       v.date_created                                                                             as Date_Created,
       v.date_last_modified                                                                       as Date_Last_Modified,
       v.voided                                                                                   as voided
from dwapi_etl.etl_patient_hiv_followup v
         inner join dwapi_etl.etl_patient_demographics de on v.patient_id = de.patient_id
         inner join (select a.patient_id
                     from (select e.patient_id, max(e.visit_date) as latest_enrolment_date
                           from dwapi_etl.etl_hiv_enrollment e
                           group by e.patient_id) a
                              left join (select d.patient_id as              disc_patient,
                                                coalesce(max(date(d.effective_discontinuation_date)),
                                                         date(d.visit_date)) Outcome_date
                                         from dwapi_etl.etl_patient_program_discontinuation d
                                         where program_name = 'HIV'
                                         group by d.patient_id) d on a.patient_id = d.disc_patient
                     where d.disc_patient is null
                        or d.Outcome_date < a.latest_enrolment_date
                     group by a.patient_id) e on v.patient_id = e.patient_id
         left join (select s.patient_id                                                            as patient_id,
                           s.visit_date                                                            as visit_date,
                           s.visit_id                                                              as visit_id,
                           s.cough,
                           s.fever,
                           s.weight_loss_poor_gain,
                           s.night_sweats,
                           s.lethargy,
                           concat_ws('|', (case Ifnull(s.yellow_urine, '')
                                               when 162311 then 'Yes'
                                               when 1066 then 'No' end), (case ifnull(s.numbness_bs_hands_feet, '')
                                                                              when 132652 then 'Yes'
                                                                              when 1066 then 'No' end),
                                     (case ifnull(s.eyes_yellowness, '')
                                          when 5192 then 'Yes'
                                          when 1066 then 'No' end), (case ifnull(s.upper_rightQ_abdomen_tenderness, '')
                                                                         when 124994 then 'Yes'
                                                                         when 1066 then 'No' end)) as IPTClientWorkUp
                    from dwapi_etl.etl_ipt_screening s) s
                   on v.patient_id = s.patient_id and v.visit_date = s.visit_date
    left join dwapi_etl.etl_ipt_follow_up f on v.patient_id = f.patient_id and v.visit_date = f.visit_date
         left join (select i.patient_id                                         as isStarted,
                           i.visit_date                                         as TPT_Initiation_date,
                           (case i.ipt_indication
                                when 138571 then 'PLHIV'
                                when 162277 then 'Prison setting'
                                when 162278 then 'Household contact'
                                when 1555 then 'HCW and other Facility staff'
                                when 5619 then 'Other clinical risk group' end) as IndicationForIPT
                    from dwapi_etl.etl_ipt_initiation i) i on v.patient_id = i.isStarted
         left join (select o.patient_id                    as disc_patient,
                           max(date(o.visit_date))            Outcome_date,
                           case mid(max(concat(o.visit_date, o.outcome)), 11)
                               when 1267 then 'Treatment completed'
                               when 5240 then 'Lost to followup'
                               when 159836 then 'Discontinued'
                               when 160034 then 'Died'
                               when 159492 then 'Transferred out'
                               when 112141 then 'Active TB Disease'
                               when 102 then 'Adverse drug reaction'
                               when 159598 then 'Poor adherence'
                               when 5622 then 'Others' end as IPT_disc_reason
                    from dwapi_etl.etl_ipt_outcome o
                    group by o.patient_id) d on d.disc_patient = v.patient_id
         join kenyaemr_etl.etl_default_facility_info site
where de.unique_patient_no is not null
group by v.encounter_id;
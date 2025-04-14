select d.patient_id                 as PatientPK,
       m.uuid                       as uuid,
       i.siteCode                   as SiteCode,
       'KenyaEMR'                   as Emr,
       'Kenya HMIS II'              as Project,
       i.FacilityName               as FacilityName,
       d.openmrs_id                 as PatientMNCH_ID,
       d.hei_no                     as PatientHEI_ID,
       d.nupi                       as NUPI,
       a.1st_DNA_PCR_date           as 1stDNAPCRDate,
       b.2nd_DNA_PCR_date           as 2ndDNAPCRDate,
       c.3rd_DNA_PCR_date           as 3rdDNAPCRDate,
       v.confirmatory_pcr_date      as ConfirmatoryPCRDate,
       baseline.baseline_vl_date    as BaselineVLDate,
       ab.final_antibody_date       as FinalAntibodyDate,
       a.1st_DNA_PCR_result         as 1stDNAPCR,
       b.2nd_DNA_PCR_result         as 2ndDNAPCR,
       c.3rd_DNA_PCR_result         as 3rdDNAPCR,
       v.dna_confirmatory_results   as ConfirmatoryPCR,
       baseline.baseline_vl_results as BaselineVL,
       ab.final_antibody_result     as FinalAntibody,
       m.exit_date                  as HEIExitDate,
       m.hiv_status                 as HEIHIVStatus,
       m.exit_reason                as HEIExitCriteria,
       m.Date_Created               as Date_Created,
       m.Date_Last_Modified         as Date_Last_Modified,
       m.voided                     as voided
from dwapi_etl.etl_patient_demographics d
         inner join (select m.patient_id,
                            m.uuid                                            as uuid,
                            m.hiv_status_at_exit                              as hiv_status,
                            m.exit_date                                       as exit_date,
                            case m.exit_reason
                                when 1403 then 'HIV Neg age >18 months'
                                when 5240 then 'Lost'
                                when 160432 then 'Dead'
                                when 159492 then 'Transfer Out'
                                when 138571 then 'Confirmed HIV Positive' end as exit_reason,
                            m.date_created                                    as Date_Created,
                            m.date_last_modified                              as Date_Last_Modified,
                            m.voided                                          as voided
                     from dwapi_etl.etl_hei_enrollment m) m on d.patient_id = m.patient_id
         left join (select t.patient_id,
                           case t.test_result when 664 then 'Negative' when 703 then 'Positive' end as 1st_DNA_PCR_result,
                           t.visit_date                                                             as 1st_DNA_PCR_date
                    from (select t.*,
                                 (@rn := if(@v = patient_id, @rn + 1,
                                            if(@v := patient_id, 1, 1)
                                         )
                                     ) as rn
                          from dwapi_etl.etl_laboratory_extract t
                                   cross join (select @v := -1, @rn := 0) params
                          where t.lab_test = 1030
                          order by t.patient_id, t.visit_date asc) t
                    where rn = 1) a on d.patient_id = a.patient_id
         left join (select t.patient_id,
                           case t.test_result when 664 then 'Negative' when 703 then 'Positive' end as 2nd_DNA_PCR_result,
                           t.visit_date                                                             as 2nd_DNA_PCR_date
                    from (select t.*,
                                 (@rn := if(@v = patient_id, @rn + 1,
                                            if(@v := patient_id, 1, 1)
                                         )
                                     ) as rn
                          from dwapi_etl.etl_laboratory_extract t
                                   cross join (select @v := -1, @rn := 0) params
                          where t.lab_test = 1030
                          order by t.patient_id, t.visit_date asc) t
                    where rn = 2) b on d.patient_id = b.patient_id
         left join (select t.patient_id,
                           case t.test_result when 664 then 'Negative' when 703 then 'Positive' end as 3rd_DNA_PCR_result,
                           t.visit_date                                                             as 3rd_DNA_PCR_date
                    from (select t.*,
                                 (@rn := if(@v = patient_id, @rn + 1,
                                            if(@v := patient_id, 1, 1)
                                         )
                                     ) as rn
                          from dwapi_etl.etl_laboratory_extract t
                                   cross join (select @v := -1, @rn := 0) params
                          where t.lab_test = 1030
                          order by t.patient_id, t.visit_date asc) t
                    where rn = 3) c on d.patient_id = c.patient_id
         left join (select ab.patient_id,
                           case ab.final_antibody_result
                               when 664 then 'Negative'
                               when 703 then 'Positive' end as final_antibody_result,
                           ab.final_antibody_sample_date    as final_antibody_date
                    from dwapi_etl.etl_hei_follow_up_visit ab
                    group by ab.patient_id) ab on d.patient_id = ab.patient_id
         left join (select v.patient_id,
                           v.dna_pcr_sample_date            as confirmatory_pcr_date,
                           case v.dna_pcr_result
                               when 664 then 'Negative'
                               when 703 then 'Positive' end as dna_confirmatory_results
                    from dwapi_etl.etl_hei_follow_up_visit v
                    where v.dna_pcr_contextual_status = 162082
                    group by v.patient_id) v on d.patient_id = v.patient_id
         left join (select x.patient_id,
                           if(mid(min(concat(x.visit_date, x.lab_test)), 11) = 856,
                              mid(min(concat(x.visit_date, x.test_result)), 11), if(
                                      mid(min(concat(x.visit_date, x.lab_test)), 11) = 1305 and
                                      mid(min(concat(x.visit_date, x.test_result)), 11) = 1302,
                                      'LDL', '')) as baseline_vl_results,
                           min(x.visit_date)      as baseline_vl_date
                    from dwapi_etl.etl_laboratory_extract x
                    where x.lab_test in (1305, 856)
                    group by x.patient_id) baseline on d.patient_id = baseline.patient_id
         join kenyaemr_etl.etl_default_facility_info i
where d.hei_no is not null;
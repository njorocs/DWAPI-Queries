select e.patient_id                                             as PatientPK,
       e.uuid                                                   as uuid,
       0                                                        AS FacilityId,
       s.siteCode                                               as SiteCode,
       de.unique_patient_no                                     as PatientID,
       'KenyaEMR'                                               as Emr,
       'Kenya HMIS II'                                          as Project,
       s.FacilityName                                           as FacilityName,
       e.visit_id                                               as VisitID,
       e.visit_date                                             as VisitDate,
       e.OTZEnrollmentDate,
       e.TransferInStatus,
       e.ModulesPreviouslyCovered,
       e.modules_attended_today                                 as ModulesCompletedToday,
       e.attended_support_group                                 as SupportGroupInvolvement,
       e.remarks                                                as Remarks,
       d.attrition_reason                                       as TransitionAttritionReason,
       d.Outcome_date                                           as OutcomeDate,
       e.date_created                                           as Date_Created,
       e.voided                                                 as voided,
       if(greatest(IFNULL(e.date_last_modified, '0000-00-00'), IFNULL(e.activity_date_last_modified, '0000-00-00'),
                   IFNULL(d.date_last_modified, '0000-00-00')) = '0000-00-00',
          NULL,
          greatest(IFNULL(e.date_last_modified, '0000-00-00'), IFNULL(e.activity_date_last_modified, '0000-00-00'),
                   IFNULL(d.date_last_modified, '0000-00-00'))) as Date_Last_Modified
from dwapi_etl.etl_patient_demographics de
         inner join (select e.patient_id,
                            e.uuid,
                            e.visit_date,
                            a.visit_id,
                            a.attended_support_group,
                            a.remarks,
                            greatest(max(e.visit_date), '0000-00-00')         as OTZEnrollmentDate,
                            mid(max(concat(e.visit_date, e.transfer_in)), 11) as TransferInStatus,
                            concat_ws(',', NULLIF(if(e.orientation = 'Yes', 'OTZ Orientation', null), ''),
                                      NULLIF(if(e.participation = 'Yes', 'OTZ Participation', ''), ''), NULLIF(
                                              if(e.making_decision_future = 'Yes',
                                                 'OTZ Making decisions for the future', ''), ''),
                                      NULLIF(if(e.transition_to_adult_care = 'Yes', 'OTZ Transition to Adult care', ''),
                                             ''),
                                      NULLIF(if(e.treatment_literacy = 'Yes', 'OTZ Treatment literacy', ''), ''),
                                      NULLIF(if(e.srh = 'Yes', 'OTZ SRH', ''), ''),
                                      NULLIF(if(e.beyond_third_ninety = 'Yes', 'OTZ Beyond the 3rd 90', null),
                                             ''))                             as ModulesPreviouslyCovered,
                            concat_ws(',', NULLIF(if(a.orientation = 'Yes', 'OTZ Orientation', null), ''),
                                      NULLIF(if(a.participation = 'Yes', 'OTZ Participation', ''), ''),
                                      NULLIF(if(a.making_decision_future = 'Yes', 'OTZ Making decisions for the future',
                                                ''), '')
                                , NULLIF(if(a.transition_to_adult_care = 'Yes', 'OTZ Transition to Adult care', ''),
                                         ''),
                                      NULLIF(if(a.treatment_literacy = 'Yes', 'OTZ Treatment literacy', ''), ''),
                                      NULLIF(if(a.srh = 'Yes', 'OTZ SRH', ''), ''),
                                      NULLIF(if(a.leadership = 'Yes', 'Leadership', ''), ''),
                                      NULLIF(if(a.beyond_third_ninety = 'Yes', 'OTZ Beyond the 3rd 90', null),
                                             ''))                             as modules_attended_today,
                            e.voided                                          as voided,
                            e.date_created                                    as date_created,
                            e.date_last_modified                              as date_last_modified,
                            a.date_last_modified                              as activity_date_last_modified
                     from dwapi_etl.etl_otz_enrollment e
                              inner join dwapi_etl.etl_patient_hiv_followup f on e.patient_id = f.patient_id
                              left join dwapi_etl.etl_otz_activity a on e.patient_id = a.patient_id
                     group by e.patient_id) e on de.patient_id = e.patient_id
         left join (select d.patient_id,
                           coalesce(max(date(d.effective_discontinuation_date)), date(d.visit_date)) Outcome_date,
                           (case mid(max(concat(date(d.visit_date), d.discontinuation_reason)), 11)
                                when 5240 then 'LTFU'
                                when 159492 then 'Transfer Out'
                                when 160034 then 'Died'
                                when 159836 then 'Opt out of OTZ'
                                when 165363 then 'Transition to Adult Care' end) as                  attrition_reason,
                           d.date_created,
                           d.date_last_modified
                    from dwapi_etl.etl_patient_program_discontinuation d
                    where program_name = 'OTZ'
                    group by d.patient_id) d on d.patient_id = e.patient_id
         join kenyaemr_etl.etl_default_facility_info s;
#CASE MANAGEMENT EXTRACT
-- High IIT Interventions
select d.patient_id                                                             as PatientPK,
       ''                                                                       as PatientPKHash,
       i.uuid                                                                   as uuid,
       s.siteCode                                                               as SiteCode,
       d.unique_patient_no                                                      as PatientID,
       ''                                                                       as PatientIDHash,
       0                                                                        as FacilityId,
       'KenyaEMR'                                                               as Emr,
       'Kenya HMIS III'                                                         as Project,
       s.FacilityName                                                           as FacilityName,
       i.visit_date                                                             as EncounterDate,
       i.interventions_offered                                                  as Interventionsoffered,
       i.appointment_mgt_interventions                                          as AppointmentManagementInterventions,
       i.reminder_methods                                                       as ReminderMethods,
       case i.enrolled_in_ushauri when 1065 then 'Yes' when 1066 then 'No' end  as EnrolledInUshauri,
       i.appointment_mngt_intervention_date                                     as DateOfAppointmentManagementInterventions,
       i.date_assigned_case_manager                                             as DateAssignedCaseManager,
       case i.eacs_recommended when 1065 then 'Yes' when 1066 then 'No' end     as EACsRecommended,
       case i.enrolled_in_psychosocial_support_group
           when 1065 then 'Yes'
           when 1066
               then 'No' end                                                    as SupportGroupEnrollement,
       i.robust_literacy_interventions_date                                     as DateofRobustClientInterventions,
       case i.enrolled_in_nishauri when 1065 then 'Yes' when 1066 then 'No' end as EnrolledinNishauri,
       i.expanded_differentiated_service_delivery_interventions_date            as DateofExpandingDSD,
       i.date_created                                                           as Date_Created,
       i.date_last_modified                                                     as Date_Last_Modified,
       i.voided                                                                 as voided
from dwapi_etl.etl_patient_demographics d
         inner join dwapi_etl.etl_high_iit_intervention i
                    on d.patient_id = i.patient_id
         join kenyaemr_etl.etl_default_facility_info s;
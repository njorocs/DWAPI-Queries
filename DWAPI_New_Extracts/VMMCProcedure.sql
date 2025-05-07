#VMMC CIRCUMCISION PROCEDURE EXTRACT
select p.patient_id                                                                         as PatientPK,
       ''                                                                                   as PatientPKHash,
       p.uuid                                                                               as uuid,
       s.siteCode                                                                           as SiteCode,
       d.unique_patient_no                                                                  as VMMCId,
       ''                                                                                   as VMMCIdHash,
       0                                                                                    as FacilityId,
       'KenyaEMR'                                                                           as Emr,
       'Kenya HMIS III'                                                                     as Project,
       s.FacilityName                                                                       as FacilityName,
       p.visit_date                                                                         as EncounterDate,
       case p.circumcision_method
           when 167119 then 'Conventional Surgical'
           when 167120
               then 'Device Circumcision' end                                               as Method,
       case p.surgical_circumcision_method
           when 167121 then 'Sleeve resection'
           when 167122 then 'Dorsal Slit'
           when 5622
               then 'Other' end                                                             as SurgicalMethod,
       case p.circumcision_device
           when 167124 then 'Shangring'
           when 5622
               then p.specific_other_device end                                             as DeviceName,
       p.device_size                                                                        as DeviceSize,
       case p.anaesthesia_type
           when 16191 then 'Local Anaesthesia'
           when 162797
               then 'Topical Anaesthesia' end                                               as AnaesthesiaUsed,
       case p.anaesthesia_used
           when 103960 then 'Lignocaine + Bupivacaine'
           when 72505 then 'Bupivacaine'
           when 104983 then 'Lignocaine + Prilocaine'
           when 82514 then 'Prilocaine'
           when 78849 then 'Lignocaine' end                                                 as Agent,
       p.anaesthesia_concentration                                                          as Concentration,
       p.anaesthesia_volume                                                                 as Volume,
       p.time_of_first_placement_cut                                                        as TimePlacementDevice,
       p.time_of_last_device_closure                                                        as TimeMakingLastSllit,
       case p.has_adverse_event when 1065 then 'Yes' when 1066 then 'No' end                as AdverseEvent,
       p.adverse_event                                                                      as AdverseEventtype,
       ''                                                                                   as AEDescription,
       p.severity                                                                           as AESeverity,
       p.adverse_event_management                                                           as AdverseEventsManagement,
       case p.clinician_cadre
           when 162592 then 'CO'
           when 162591 then 'MO'
           when 1577
               then 'Nurse' end                                                             as CadreClinician,
       case p.assist_clinician_cadre
           when 162592 then 'CO'
           when 162591 then 'MO'
           when 1577
               then 'Nurse' end                                                             as CadreAssistanClinician,
       p.theatre_number                                                                     as TheatreRegisterNumber,
       t.blood_pressure                                                                     as BP,
       t.pulse_rate                                                                         as PulseRate,
       t.temperature                                                                        as Temperature,
       case t.penis_elevated when 1065 then 'Yes' when 1066 then 'No' end                   as PenisElevatedAbdomen,
       case t.given_post_procedure_instruction when 1065 then 'Yes' when 1066 then 'No' end as PostProcedureInstruction,
       case t.given_post_operation_medication
           when 1065 then 'Yes'
           when 1066
               then 'No' end                                                                as PostOperationMedicationGiven,
       concat_ws(t.medication_given, t.other_medication_given)                              as Drug,
       t.removal_date                                                                       as RemovalDate,
       t.next_appointment_date                                                              as ScheduledNextVisit,
       case t.cadre
           when 162592 then 'CO'
           when 162591 then 'MO'
           when 1577
               then 'Nurse' end                                                             as CadreDischargedBy,
       p.date_created                                                                       as Date_Created,
       p.date_last_modified                                                                 as Date_Last_Modified,
       p.voided                                                                             as voided
from dwapi_etl.etl_vmmc_circumcision_procedure p
         inner join dwapi_etl.etl_patient_demographics d on p.patient_id = d.patient_id
         left join dwapi_etl.etl_vmmc_post_operation_assessment t
                   on p.patient_id = t.patient_id and p.visit_date = t.visit_date
         join kenyaemr_etl.etl_default_facility_info s;
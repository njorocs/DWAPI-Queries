#VMMC CIRCUMCISION FOLLOWUP EXTRACT
select f.patient_id                                                                                                   as PatientPK,
       ''                                                                                                             as PatientPKHash,
       f.uuid                                                                                                         as uuid,
       s.siteCode                                                                                                     as SiteCode,
       d.unique_patient_no                                                                                            as VMMCId,
       ''                                                                                                             as VMMCIdHash,
       0                                                                                                              as FacilityId,
       'KenyaEMR'                                                                                                     as Emr,
       'Kenya HMIS III'                                                                                               as Project,
       s.FacilityName                                                                                                 as FacilityName,
       f.visit_date                                                                                                   as EncounterDate,
       case f.visit_type
           when 1246 then 'Scheduled'
           when 160101
               then 'Unscheduled' end                                                                                 as VisitType,
       f.days_since_circumcision                                                                                      as DaySinceLastCircumsicion,
       case f.has_adverse_event when 1065 then 'Yes' when 1066 then 'No' end                                          as AdverseEventPostCircumcision,
       f.adverse_event                                                                                                   asAEType,
       ''                                                                                                             as AEDescription,
       f.severity                                                                                                     as AESeverity,
       f.adverse_event_management                                                                                     as AEManagement,
       if(FIND_IN_SET(f.medications_given, 'Analgesic') > 0 or FIND_IN_SET(f.medications_given, 'Antibiotics') > 0 or
          FIND_IN_SET(f.medications_given, 'TTCV') > 0 or FIND_IN_SET(f.medications_given, 'Other') > 0, 'Yes',
          'No')                                                                                                       as MedicationGiven,
       f.medications_given                                                                                            as Drug,
       case f.clinician_cadre
           when 162592 then 'CO'
           when 162591 then 'MO'
           when 1577
               then 'Nurse' end                                                                                       as CadreClinician,
       f.date_created                                                                                                 as Date_Created,
       f.date_last_modified                                                                                           as Date_Last_Modified,
       f.voided                                                                                                       as voided
from dwapi_etl.etl_vmmc_client_followup f
         inner join dwapi_etl.etl_patient_demographics d on f.patient_id = d.patient_id
         join kenyaemr_etl.etl_default_facility_info s;
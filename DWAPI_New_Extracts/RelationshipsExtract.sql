SELECT r.person_a PatientPK,
                   r.uuid                         as RecordUUID,
                   convert(r.voided  , SIGNED)    as Voided,
                   i.siteCode                     SiteCode,
                   d.unique_patient_no            PatientID,
                   'KenyaEMR'                     Emr,
                   'Kenya HMIS III'               Project,
                   i.facilityName                 FacilityName,
                   0                              as FacilityId,
                   t.a_is_to_b 					as PatientRelationshipToOther,
                   r.person_a 					as  PersonAPatientPk,
                   r.person_b 					as  PersonBPatientPk,
                   t.b_is_to_a                    as RelationshipToPatient,
                   r.start_date                   as EndDate,
                   r.end_date                     as StartDate,
                   r.date_created                 as Date_Created,
                   r.date_changed                 as Date_Last_Modified
                  FROM relationship r 
                  INNER JOIN relationship_type t ON r.relationship = t.relationship_type_id
                  join dwapi_etl.etl_patient_demographics d ON r.person_a = d.patient_id
                  join kenyaemr_etl.etl_default_facility_info i
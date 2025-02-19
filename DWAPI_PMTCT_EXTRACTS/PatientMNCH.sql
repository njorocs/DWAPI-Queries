select pkv.pkv                                                              as PKV,
       d.patient_id                                                         as PatientPK,
       d.uuid                                                               as uuid,
       d.national_unique_patient_identifier                                 as NUPI,
       i.siteCode                                                           as SiteCode,
       d.openmrs_id                                                         as PatientMNCH_ID,
       d.hei_no                                                             as PatientHEI_ID,
       d.sha_number                                                         as SHANumber,
       d.shif_number                                                        as SHIFNumber,
       'KenyaEMR'                                                           as Emr,
       'Kenya HMIS II'                                                      as Project,
       i.FacilityName                                                       as FacilityName,
       (case d.Gender when 'F' then 'Female' when 'M' then 'Male' end)      as Gender,
       d.DOB                                                                as DOB,
       coalesce(c.hei_enrolment_date, m.mch_enrolment_date)                 as FirstEnrollmentAtMnch,
       coalesce(c.hei_encounter_id, m.mch_encounter_id, r.fup_encounter_id) as EncounterId,
       d.occupation                                                         as Occupation,
       d.marital_status                                                     as MaritalStatus,
       d.education_level                                                    as EducationLevel,
       a.county                                                             as PatientResidentCounty,
       a.sub_county                                                         as PatientResidentSubCounty,
       a.ward                                                               as PatientResidentWard,
       (case e.in_school when 1 then 'Yes' when 2 then 'No' end)            as Inschool,
       d.date_created                                                       as Date_Created,
       d.date_last_modified                                                 as Date_Last_Modified,
       d.voided                                                             as voided
from dwapi_etl.etl_patient_demographics d
         left join (select m.patient_id,
                           min(date(m.visit_date))                                  as mch_enrolment_date,
                           mid(min(concat(date(m.visit_date), m.encounter_id)), 11) as mch_encounter_id
                    from dwapi_etl.etl_mch_enrollment m
                    group by m.patient_id) m on d.patient_id = m.patient_id
         left join (select c.patient_id,
                           min(date(c.visit_date))                                  as hei_enrolment_date,
                           mid(min(concat(date(c.visit_date), c.encounter_id)), 11) as hei_encounter_id
                    from dwapi_etl.etl_hei_enrollment c
                    group by c.patient_id) c on d.patient_id = c.patient_id
         left join (select a.patient_id, a.county, a.sub_county, a.ward from dwapi_etl.etl_person_address a) a
                   on d.patient_id = a.patient_id
         left join (select r.person_a, mid(min(concat(date(fup.visit_date), fup.encounter_id)), 11) as fup_encounter_id
                    from dwapi_etl.etl_patient_hiv_followup fup
                             inner join openmrs.relationship r on fup.patient_id = r.person_a
                             inner join openmrs.relationship_type t on r.relationship = t.relationship_type_id and
                                                                       t.uuid in
                                                                       ('8d91a210-c2cc-11de-8d13-0010c6dffd0f')
                    group by r.person_a) r on d.patient_id = r.person_a
         left join (select e.patient_id as patient_id, e.in_school as in_school from dwapi_etl.etl_hiv_enrollment e) e
                   on d.patient_id = e.patient_id
         inner join (select x.patient_id as patient_id,
                            x.sxFirstName,
                            x.sxLastname,
                            x.sxMiddleName,
                            x.dmFirstName,
                            x.dmLastName,
                            x.dmMiddleName,
                            x.Gender,
                            x.DOB,
                            CASE
                                WHEN locate(';', dmLastName) > 0 THEN CONCAT(
                                        CAST(LEFT(Gender, 1) AS CHAR CHARACTER SET utf8),
                                        CAST(sxFirstName AS CHAR CHARACTER SET utf8), CAST(
                                                SUBSTRING(dmLastName, locate(';', dmLastName) + 1, LENGTH(dmLastName))
                                            AS
                                            CHAR CHARACTER SET utf8),
                                        CAST(LTRIM(RTRIM(DATE_FORMAT(DOB, '%Y'))) AS CHAR CHARACTER SET utf8)
                                                                      )
                                ELSE CONCAT(
                                        CAST(LEFT(Gender, 1) AS CHAR CHARACTER SET utf8),
                                        CAST(sxFirstName AS CHAR CHARACTER SET utf8),
                                        CAST(dmLastName AS CHAR CHARACTER SET utf8),
                                        CAST(LTRIM(RTRIM(DATE_FORMAT(DOB, '%Y'))) AS CHAR CHARACTER SET utf8)
                                     )
                                END      AS PKV
                     from (SELECT patient_id,
                                  SOUNDEX(UPPER(REPLACE(given_name, '0', 'O')))                           AS sxFirstName,
                                  SOUNDEX(UPPER(REPLACE(family_name, '0', 'O')))                          AS sxLastName,
                                  SOUNDEX(UPPER(REPLACE(middle_name, '0', 'O')))                          AS sxMiddleName,
                                  fn_getPatientNameDoubleMetaphone(UPPER(REPLACE(given_name, '0', 'O')))  AS dmFirstName,
                                  fn_getPatientNameDoubleMetaphone(UPPER(REPLACE(family_name, '0', 'O'))) AS dmLastName,
                                  fn_getPatientNameDoubleMetaphone(UPPER(REPLACE(middle_name, '0', 'O'))) AS dmMiddleName,
                                  Gender,
                                  DOB
                           FROM dwapi_etl.etl_patient_demographics) x) pkv on pkv.patient_id = d.patient_id
         join kenyaemr_etl.etl_default_facility_info i
where m.patient_id is not null
   or c.patient_id is not null
   or r.person_a is not null
group by EncounterId;
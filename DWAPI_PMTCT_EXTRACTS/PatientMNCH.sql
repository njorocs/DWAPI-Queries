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
       coalesce(l.delivery_visit_date, m.enrolment_date)                    as FirstEnrollmentAtMnch,
       l.del_encounter_id                                                   as EncounterId,
       d.occupation                                                         as Occupation,
       d.marital_status                                                     as MaritalStatus,
       d.education_level                                                    as EducationLevel,
       a.county                                                             as PatientResidentCounty,
       a.sub_county                                                         as PatientResidentSubCounty,
       a.ward                                                               as PatientResidentWard,
       (case e.in_school when 1 then 'Yes' when 2 then 'No' end)            as Inschool,
       d.date_created                                                       as Date_Created,
       d.date_last_modified                                                 as Date_Last_Modified,
       (case
            when d.voided = 1
                or coalesce(m.enrollment_voided, 0) = 1
                or coalesce(l.delivery_voided, 0) = 1
                then 1 else 0 end)                                          as voided
from dwapi_etl.etl_patient_demographics d
         left join (select m.patient_id,
                           m.date_enrolled as enrolment_date,
                           m.voided        as enrollment_voided
                    from dwapi_etl.etl_patient_program m
                    where m.program in ('MCH-Child Services', 'Antenatal Care', 'Postnatal Care', 'MCH-Mother Services')
                      and m.date_completed is null) m on d.patient_id = m.patient_id
         left join (select l.patient_id,
                           max(date(l.visit_date))                                                as delivery_visit_date,
                           cast(substring(max(concat(date(l.visit_date), lpad(l.encounter_id, 10, '0'),
                                                     coalesce(l.voided, 0))), 11, 10) as unsigned) as del_encounter_id,
                           substring(max(concat(date(l.visit_date), lpad(l.encounter_id, 10, '0'),
                                                coalesce(l.voided, 0))), 21)                       as delivery_voided
                    from dwapi_etl.etl_mchs_delivery l
                    group by l.patient_id) l on d.patient_id = l.patient_id
         left join (select a.patient_id, a.county, a.sub_county, a.ward
                    from dwapi_etl.etl_person_address a
                             inner join (select ia.patient_id, max(ia.uuid) as uuid
                                         from dwapi_etl.etl_person_address ia
                                         group by ia.patient_id) latest_addr
                                        on a.uuid = latest_addr.uuid) a
                   on d.patient_id = a.patient_id
         inner join (select e.patient_id,
                            mid(max(concat(date(e.visit_date), coalesce(e.in_school, ''))), 11) as in_school
                     from dwapi_etl.etl_hiv_enrollment e
                     group by e.patient_id) e
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
   or l.patient_id is not null;

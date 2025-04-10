SELECT d.patient_id                                                      as PatientPK,
       t.uuid                                                            as uuid,
       d.national_unique_patient_identifier                              as NUPI,
       d.sha_number                                                      as SHANumber,
       d.shif_number                                                     as SHIFNumber,
       pkv.PKV                                                           as Pkv,
       (select FacilityName from kenyaemr_etl.etl_default_facility_info) as FacilityName,
       (select siteCode from kenyaemr_etl.etl_default_facility_info)     as SiteCode,
       'KenyaEMR'                                                        as Emr,
       'Kenya HMIS II'                                                   AS Project,
       d.openmrs_id                                                      AS HtsNumber,
       d.hts_recency_id                                                  as HTSRecencyId,
       d.DOB,
       case when d.Gender = 'M' then 'Male' else 'Female' end            as Gender,
       d.marital_status                                                  as MaritalStatus,
       d.occupation                                                      as Occupation,
       t.population_type                                                 as PopulationType,
       t.key_population_type                                             as KeyAndVulnerablePopulation,
       ''                                                                as PriorityPopulationType,
       t.patient_disabled                                                as PatientDisabled,
       t.disability_type                                                 as DisabilityType,
       A.county_district                                                 as County,
       A.state_province                                                  as SubCounty,
       A.address4                                                        as Ward,
       t.date_created                                                    as Date_Created,
       t.date_last_modified                                              as Date_Last_Modified,
       t.voided                                                          as voided
FROM dwapi_etl.etl_hts_test t
         inner join dwapi_etl.etl_patient_demographics d ON d.patient_id = t.patient_id
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
         LEFT JOIN location_attribute SC ON SC.location_id = t.encounter_location AND SC.attribute_type_id = 1
         LEFT JOIN location SN ON SN.location_id = t.encounter_location
         LEFT JOIN person_address A ON A.person_id = d.patient_id
group by t.patient_id
having min(t.date_created);
SELECT t.patient_id                                                      AS PatientPK,
       t.uuid                                                            as uuid,
       (select FacilityName from kenyaemr_etl.etl_default_facility_info) as FacilityName,
       (select siteCode from kenyaemr_etl.etl_default_facility_info)     as SiteCode,
       'KenyaEMR'                                                        as Emr,
       'Kenya HMIS II'                                                   AS Project,
       id.identifier                                                     AS HtsNumber,
       t.encounter_id                                                    AS EncounterId,
       t.test_1_kit_name                                                 AS TestKitName1,
       t.test_1_kit_lot_no                                               AS TestKitLotNumber1,
       t.test_1_kit_expiry                                               as TestKitExpiry1,
       t.test_1_result                                                   as TestResult1,
       t.test_2_kit_name                                                 as TestKitName2,
       t.test_2_kit_lot_no                                               as TestKitLotNumber2,
       t.test_2_kit_expiry                                               as TestKitExpiry2,
       t.test_2_result                                                   as TestResult2,
       t.test_3_kit_name                                                 as TestKitName3,
       t.test_3_kit_lot_no                                               as TestKitLotNumber3,
       t.test_3_kit_expiry                                               as TestKitExpiry3,
       t.test_3_result                                                   as TestResult3,
       t.syphillis_test_result                                           as SyphilisResult,
       t.date_created                                                    as DateCreated,
       t.date_last_modified                                                   as DateLastModified,
       t.voided                                                          as voided
FROM dwapi_etl.etl_hts_test t
         inner join dwapi_etl.etl_patient_demographics demographics on t.patient_id = demographics.patient_id
         LEFT JOIN location_attribute SC ON SC.location_id = t.encounter_location AND SC.attribute_type_id = 1
         LEFT JOIN location SN ON SN.location_id = t.encounter_location
         LEFT JOIN patient_identifier id ON id.patient_id = t.patient_id AND id.identifier_type =
                                                                             (select patient_identifier_type_id
                                                                              from patient_identifier_type
                                                                              where name = 'OpenMRS ID');
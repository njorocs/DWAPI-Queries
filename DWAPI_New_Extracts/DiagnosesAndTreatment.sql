SELECT d.patient_id                                        AS PatientPK,
       i.siteCode                                          AS SiteCode,
       i.FacilityName                                      AS FacilityName,
       'KenyaEMR'                                          AS Emr,
       'Kenya HMIS III'                                    AS Project,
       GROUP_CONCAT(DISTINCT dg.diagnosis SEPARATOR ' | ') AS Diagnosis,
       dg.encounter_id                                     AS EncounterId,
       DATE(dg.diagnosisDate)                              AS DiagnosisDate,
       GROUP_CONCAT(DISTINCT do.drug_name SEPARATOR ' + ') AS Treatment,
       DATE(do.visit_date)                                 AS TreatmentDate,
       MIN(dg.diagnosisDate)                               AS DateCreated,
       MAX(do.date_last_modified)                          AS DateLastModified,
       MAX(do.voided)                                      AS Voided,
       dg.uuid                                             as UUID
FROM dwapi_etl.etl_hiv_enrollment e
         INNER JOIN dwapi_etl.etl_patient_hiv_followup f
                    ON e.patient_id = f.patient_id
         INNER JOIN dwapi_etl.etl_patient_demographics d
                    ON e.patient_id = d.patient_id
         INNER JOIN (SELECT d.patient_id,
                            d.date_created                                AS diagnosisDate,
                            d.encounter_id,
                            GROUP_CONCAT(DISTINCT n.name SEPARATOR ' | ') AS diagnosis,
                            d.uuid
                     FROM openmrs.encounter_diagnosis d
                              INNER JOIN openmrs.concept_name n
                                         ON d.diagnosis_coded = n.concept_id
                                             AND n.locale = 'en'
                     WHERE n.concept_name_type = 'FULLY_SPECIFIED'
                       AND d.voided = 0
                       AND d.dx_rank = 2
                     GROUP BY d.patient_id, d.encounter_id, DATE(d.date_created)) dg
                    ON e.patient_id = dg.patient_id
         LEFT JOIN (SELECT do.patient_id,
                           do.encounter_id,
                           DATE(do.visit_date)                                 AS visit_date,
                           GROUP_CONCAT(DISTINCT do.drug_name SEPARATOR ' + ') AS drug_name,
                           MAX(do.date_last_modified)                          AS date_last_modified,
                           MAX(do.voided)                                      AS voided
                    FROM dwapi_etl.etl_drug_order do
                    WHERE do.voided = 0
                    GROUP BY do.patient_id, do.encounter_id, DATE(do.visit_date)) do
                   ON e.patient_id = do.patient_id
                       AND dg.diagnosisDate = do.visit_date
         JOIN kenyaemr_etl.etl_default_facility_info i
GROUP BY e.patient_id, DATE(dg.diagnosisDate);
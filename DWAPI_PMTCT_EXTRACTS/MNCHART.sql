WITH
    facility_info AS (
        SELECT
            SiteCode,
            FacilityName
        FROM kenyaemr_etl.etl_default_facility_info
        LIMIT 1
    ),
    patient_demographics AS (
        SELECT
            patient_id,
            openmrs_id,
            hei_no,
            unique_patient_no
        FROM dwapi_etl.etl_patient_demographics
    ),
    program_discontinuations AS (
        SELECT
            patient_id,
            program_name,
            DATE(visit_date) AS discontinuation_date,
            discontinuation_reason,
            date_last_modified
        FROM dwapi_etl.etl_patient_program_discontinuation
    ),
    program_status AS (
        SELECT
            p.patient_id,
            p.program,
            p.date_enrolled,
            p.date_completed,
            CASE
                WHEN p.date_completed IS NULL THEN 'Active'
                WHEN d.discontinuation_reason = 160035 THEN 'Completed'
                WHEN d.discontinuation_reason = 1267 THEN 'Completed'
                WHEN d.discontinuation_reason = 159492 THEN 'Transferred Out'
                WHEN d.discontinuation_reason = 160034 THEN 'Dead'
                WHEN d.discontinuation_reason = 5240 THEN 'Lost to Follow up'
                WHEN d.discontinuation_reason = 5622 THEN 'Other'
                ELSE 'Unknown'
                END AS status,
            d.discontinuation_reason
        FROM dwapi_etl.etl_patient_program p
                 LEFT JOIN program_discontinuations d
                           ON p.patient_id = d.patient_id
                               AND p.program = d.program_name
                               AND p.date_completed = d.discontinuation_date
    ),
    hiv_program_status AS (
        SELECT
            patient_id,
            status
        FROM (
                 SELECT
                     ps.patient_id,
                     ps.status,
                     ROW_NUMBER() OVER (
                         PARTITION BY ps.patient_id
                         ORDER BY ps.date_enrolled DESC
                         ) AS rn
                 FROM program_status ps
                 WHERE ps.program = 'HIV'
             ) t
        WHERE rn = 1
    ),
    hiv_enrollment AS (
        SELECT
            patient_id,
            MAX(uuid) AS uuid,
            MIN(visit_date) AS hiv_enrollment_date,
            MIN(COALESCE(date_first_enrolled_in_care, visit_date)) AS registration_at_ccc,
            MIN(date_started_art_at_transferring_facility) AS transfer_in_art_date,
            MAX(date_last_modified) AS date_last_modified,
            MAX(voided) AS voided
        FROM dwapi_etl.etl_hiv_enrollment
        GROUP BY patient_id
    ),
    art_events AS (
        SELECT
            patient_id,
            date_started,
            regimen_name,
            regimen_line,
            uuid,
            date_created,
            date_last_modified,
            voided,
            ROW_NUMBER() OVER (
                PARTITION BY patient_id
                ORDER BY date_started ASC, encounter_id ASC
                ) AS first_art_rank,
            ROW_NUMBER() OVER (
                PARTITION BY patient_id
                ORDER BY date_started DESC, encounter_id DESC
                ) AS current_art_rank
        FROM dwapi_etl.etl_drug_event
        WHERE program = 'HIV'
    ),
    first_art AS (
        SELECT
            patient_id,
            date_started AS start_art_date,
            regimen_name AS start_regimen,
            regimen_line AS start_regimen_line
        FROM art_events
        WHERE first_art_rank = 1
    ),
    current_art AS (
        SELECT
            patient_id,
            date_started AS current_regimen_date,
            regimen_name AS current_regimen,
            regimen_line AS current_regimen_line,
            date_created,
            date_last_modified,
            voided
        FROM art_events
        WHERE current_art_rank = 1
    ),
    legacy_mch AS (
        SELECT
            m.patient_id,
            m.uuid,
            m.visit_date AS enrollment_date,
            'LEGACY_MCH' AS source_type,
            1 AS priority,
            ps.status AS mch_status,
            ps.date_completed,
            m.date_last_modified,
            m.voided
        FROM dwapi_etl.etl_mch_enrollment m
                 LEFT JOIN program_status ps
                           ON ps.patient_id = m.patient_id
                               AND ps.program = 'MCH-Mother'
    ),
    anc_initial AS (
        SELECT
            a.patient_id,
            a.uuid,
            a.visit_date AS enrollment_date,
            'ANC' AS source_type,
            2 AS priority,
            ps.status AS mch_status,
            ps.date_completed,
            a.date_last_modified,
            a.voided
        FROM dwapi_etl.etl_mch_antenatal_visit a
                 LEFT JOIN program_status ps
                           ON ps.patient_id = a.patient_id
                               AND ps.program = 'MCH-ANC'
        WHERE a.anc_visit_number = 1
    ),
    pnc_initial AS (
        SELECT
            p.patient_id,
            p.uuid,
            p.visit_date AS enrollment_date,
            'PNC' AS source_type,
            3 AS priority,
            ps.status AS mch_status,
            ps.date_completed,
            p.date_last_modified,
            p.voided
        FROM dwapi_etl.etl_mch_postnatal_visit p
                 LEFT JOIN program_status ps
                           ON ps.patient_id = p.patient_id
                               AND ps.program = 'MCH-PNC'
        WHERE p.pnc_visit_no = 1
    ),
    delivery_events AS (
        SELECT
            d.patient_id,
            d.uuid,
            d.visit_date AS enrollment_date,
            'DELIVERY' AS source_type,
            4 AS priority,
            'Completed' AS mch_status,
            d.visit_date AS date_completed,
            d.date_last_modified,
            d.voided
        FROM dwapi_etl.etl_mchs_delivery d
    ),
    hei_enrollment AS (
        SELECT
            h.patient_id,
            h.uuid,
            h.visit_date AS enrollment_date,
            'HEI' AS source_type,
            5 AS priority,
            ps.status AS mch_status,
            ps.date_completed,
            h.date_last_modified,
            h.voided
        FROM dwapi_etl.etl_hei_enrollment h
                 LEFT JOIN program_status ps
                           ON ps.patient_id = h.patient_id
                               AND ps.program = 'MCH-Child Services'
    ),
    mch_sources AS (
        SELECT * FROM legacy_mch
        UNION ALL
        SELECT * FROM anc_initial
        UNION ALL
        SELECT * FROM pnc_initial
        UNION ALL
        SELECT * FROM delivery_events
        UNION ALL
        SELECT * FROM hei_enrollment
    ),
    canonical_mch AS (
        SELECT *
        FROM (
                 SELECT
                     s.*,
                     ROW_NUMBER() OVER (
                         PARTITION BY patient_id
                         ORDER BY priority, enrollment_date, uuid
                         ) AS rn
                 FROM mch_sources s
             ) ranked
        WHERE rn = 1
    ),
    eligible_patients AS (
        SELECT
            pd.patient_id,
            pd.openmrs_id,
            pd.unique_patient_no,
            pd.hei_no,
            h.uuid AS hiv_uuid,
            h.hiv_enrollment_date,
            h.registration_at_ccc,
            h.transfer_in_art_date,
            fa.start_art_date,
            fa.start_regimen,
            fa.start_regimen_line,
            ca.current_regimen_date,
            ca.current_regimen,
            ca.current_regimen_line,
            ca.date_created AS art_date_created,
            ca.date_last_modified AS art_date_last_modified,
            ca.voided AS art_voided,
            hps.status AS ccc_status,
            cm.source_type,
            cm.enrollment_date AS mch_enrollment_date,
            cm.mch_status,
            cm.date_completed AS mch_exit_date,
            cm.date_last_modified,
            cm.voided
        FROM patient_demographics pd
                 INNER JOIN hiv_enrollment h ON pd.patient_id = h.patient_id
                 INNER JOIN first_art fa ON pd.patient_id = fa.patient_id
                 INNER JOIN current_art ca ON pd.patient_id = ca.patient_id
                 INNER JOIN canonical_mch cm ON pd.patient_id = cm.patient_id
                 LEFT JOIN hiv_program_status hps ON pd.patient_id = hps.patient_id
    )
SELECT
    ep.patient_id                AS PatientPK,
    ep.hiv_uuid                  AS uuid,
    f.SiteCode                   AS SiteCode,
    ep.openmrs_id                AS PatientMNCHCWC_ID,
    ep.hei_no                    AS PatientHEI_ID,
    ep.unique_patient_no         AS PatientID,
    'KenyaEMR'                   AS Emr,
    'Kenya HMIS II'              AS Project,
    f.FacilityName               AS FacilityName,
    ep.registration_at_ccc       AS RegistrationAtCCC,
    ep.start_art_date            AS StartARTDate,
    f.FacilityName               AS FacilityReceivingARTCare,
    ep.start_regimen             AS StartRegimen,
    ep.start_regimen_line        AS StartRegimenLine,
    ep.ccc_status                AS StatusAtCCC,
    ep.current_regimen_date      AS DateStartedCurrentRegimen,
    ep.current_regimen           AS LastRegimen,
    ep.current_regimen_line      AS LastRegimenLine,
    ep.art_date_created          AS Date_Created,
    ep.art_date_last_modified    AS Date_Last_Modified,
    ep.art_voided                AS voided
FROM eligible_patients ep
         CROSS JOIN facility_info f;

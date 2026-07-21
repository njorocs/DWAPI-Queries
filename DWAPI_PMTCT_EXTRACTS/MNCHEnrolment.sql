with
    program_status as (
        select p.patient_id,
               p.program,
               p.date_enrolled,
               if(p.date_completed is null, 'Active',
                  (case dc.discontinuation_reason
                       when 160035 then 'Completed'
                       when 159492 then 'Transferred Out'
                       when 160034 then 'Died'
                       when 5240 then 'Lost to Follow up'
                       else '' end))                                              as status_in_prg,
               row_number() over (partition by p.patient_id, p.program, p.date_enrolled
                                  order by dc.visit_date desc)                    as rn
        from dwapi_etl.etl_patient_program p
                 left join dwapi_etl.etl_patient_program_discontinuation dc
                           on p.patient_id = dc.patient_id
                               and p.date_completed = date(dc.visit_date)
        where p.program in ('MCH-Mother Services', 'Antenatal Care', 'Postnatal Care')
    ),
    facility as (
        select siteCode, FacilityName
        from kenyaemr_etl.etl_default_facility_info
        limit 1
    ),
    episodes as (
        -- Legacy MCH enrolment: one row per (patient, enrolment visit_date).
        select mr.patient_id,
               mr.uuid,
               mr.service_type,
               mr.visit_date            as enrollment_date,
               mr.anc_number,
               mr.first_anc_visit_date  as first_anc_visit,
               mr.parity,
               mr.gravida,
               mr.lmp,
               mr.edd_ultrasound        as edd,
               mr.hiv_status            as hiv_status_before_anc,
               mr.hiv_test_date         as test_date,
               mr.partner_hiv_status    as partner_status,
               mr.partner_hiv_test_date as partner_test_date,
               mr.blood_group,
               ps.status_in_prg         as status_in_mnch,
               mr.date_created,
               mr.date_last_modified,
               mr.voided                as mvoided
        from (select m.*,
                     row_number() over (partition by m.patient_id, m.visit_date
                                        order by m.date_last_modified desc) as rn
              from dwapi_etl.etl_mch_enrollment m) mr
                 left join program_status ps
                           on ps.patient_id = mr.patient_id
                               and ps.program = 'MCH-Mother Services'
                               and ps.date_enrolled = date(mr.visit_date)
                               and ps.rn = 1
        where mr.rn = 1
        union all
        -- Delivery: one row per delivery encounter.
        select dr.patient_id,
               dr.uuid,
               164835                           as service_type, -- Delivery
               date(dr.visit_date)              as enrollment_date,
               null                             as anc_number,
               null                             as first_anc_visit,
               null                             as parity,       -- duration_of_pregnancy is gestation, NOT parity
               null                             as gravida,
               dr.date_of_last_menstrual_period as lmp,
               dr.estimated_date_of_delivery    as edd,
               null                             as hiv_status_before_anc,
               null                             as test_date,
               dr.partner_hiv_status            as partner_status,
               null         as partner_test_date,
               null                             as blood_group,
               'ACTIVE'                         as status_in_mnch,
               dr.date_created,
               dr.date_last_modified,
               dr.voided                        as mvoided
        from (select l.*,
                     row_number() over (partition by l.patient_id, l.encounter_id
                                        order by l.date_last_modified desc) as rn
              from dwapi_etl.etl_mchs_delivery l) dr
        where dr.rn = 1
        union all
        select ar.patient_id,
               ar.uuid,
               1622                      as service_type, -- ANC
               ar.visit_date             as enrollment_date,
               ar.anc_number,
               ar.visit_date             as first_anc_visit,
               ar.parity,
               ar.gravidae               as gravida,
               ar.lmp_date               as lmp,
               ar.expected_delivery_date as edd,
               null                      as hiv_status_before_anc,
               null                      as test_date,
               ar.partner_hiv_status     as partner_status,
               ar.partner_hiv_test_date  as partner_test_date,
               null                      as blood_group,
               ps.status_in_prg          as status_in_mnch,
               ar.date_created,
               ar.date_last_modified,
               ar.voided                 as mvoided
        from (select a.*,
                     row_number() over (partition by a.patient_id, date(a.visit_date)
                                        order by a.date_last_modified desc) as rn
              from dwapi_etl.etl_mch_antenatal_visit a
              where a.form = 'MCH Antenatal Initial Visit') ar
                 left join program_status ps
                           on ps.patient_id = ar.patient_id
                               and ps.program = 'Antenatal Care'
                               and ps.date_enrolled = date(ar.visit_date)
                               and ps.rn = 1
        where ar.rn = 1
          and not exists (select 1
                          from dwapi_etl.etl_mch_enrollment e
                          where e.patient_id = ar.patient_id
                            and date(e.visit_date) between date_sub(date(ar.visit_date), interval 12 month)
                                                       and date_add(date(ar.visit_date), interval 1 month))
        union all
        select pr.patient_id,
               pr.uuid,
               1623                  as service_type, -- PNC
               pr.visit_date         as enrollment_date,
               null                  as anc_number,
               null                  as first_anc_visit,
               null                  as parity,
               null                  as gravida,
               null                  as lmp,
               null                  as edd,
               null                  as hiv_status_before_anc,
               null                  as test_date,
               pr.partner_hiv_status as partner_status,
               null                  as partner_test_date,
               null                  as blood_group,
               ps.status_in_prg      as status_in_mnch,
               pr.date_created,
               pr.date_last_modified,
               pr.voided             as mvoided
        from (select pn.*,
                     row_number() over (partition by pn.patient_id, date(pn.visit_date)
                                        order by pn.date_last_modified desc) as rn
              from dwapi_etl.etl_mch_postnatal_visit pn
              where pn.pnc_visit_no = 1) pr
                 left join program_status ps
                           on ps.patient_id = pr.patient_id
                               and ps.program = 'Postnatal Care'
                               and ps.date_enrolled = date(pr.visit_date)
                               and ps.rn = 1
        where pr.rn = 1
          and not exists (select 1
                          from dwapi_etl.etl_mch_enrollment e
                          where e.patient_id = pr.patient_id
                            and date(e.visit_date) between date_sub(date(pr.visit_date), interval 12 month)
                                                       and date_add(date(pr.visit_date), interval 1 month))
    )
select d.patient_id                                                                as PatientPK,
       e.uuid                                                                      as uuid,
       i.siteCode                                                                  as SiteCode,
       d.openmrs_id                                                                as PatientMNCHCWC_ID,
       'KenyaEMR'                                                                  as Emr,
       'Kenya HMIS II'                                                             as Project,
       i.FacilityName                                                             as FacilityName,
       (case e.service_type
            when 1622 then 'ANC'
            when 164835 then 'Delivery'
            when 1623 then 'PNC'
            else '' end)                                                          as ServiceType,
       e.enrollment_date                                                          as EnrollmentDateATMNCH,
       e.anc_number                                                               as MNCHNumber,
       e.first_anc_visit                                                          as FirstVisitANC,
       e.parity                                                                   as Parity,
       e.gravida                                                                  as Gravidae,
       e.lmp                                                                      as LMP,
       coalesce(e.edd,
                date_add(date_add(e.lmp, interval 7 day), interval 9 month))      as EDDFromLMP, -- calendar-month approximation of Naegele's rule
       (case e.hiv_status_before_anc
            when 664 then 'Negative'
            when 703 then 'Positive'
            when 1067 then 'Unknown'
            else '' end)                                                          as HIVStatusBeforeANC,
       e.test_date                                                                as HIVTestDate,
       (case e.partner_status
            when 664 then 'Negative'
            when 703 then 'Positive'
            when 1067 then 'Unknown'
            else '' end)                                                          as PartnerHIVStatus,
       e.partner_test_date                                                        as PartnerHIVTestDate,
       (case e.blood_group
            when 690 then 'A POSITIVE'
            when 692 then 'A NEGATIVE'
            when 694 then 'B POSITIVE'
            when 696 then 'B NEGATIVE'
            when 699 then 'O POSITIVE'
            when 701 then 'O NEGATIVE'
            when 1230 then 'AB POSITIVE'
            when 1231 then 'AB NEGATIVE'
            else '' end)                                                          as BloodGroup,
       e.status_in_mnch                                                           as StatusAtMNCH,
       e.date_created                                                             as Date_Created,
       e.date_last_modified                                                       as Date_Last_Modified,
       e.mvoided                                                                  as voided
from episodes e
         join dwapi_etl.etl_patient_demographics d on d.patient_id = e.patient_id
         cross join facility i;

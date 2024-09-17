select 'HTS_INDEX'                                                                 AS 'INDICATOR',
       count(distinct a.patient_id)                                                as 'INDICATOR_VALUE',
       date_format(last_day(date_sub(current_date(), interval 1 MONTH)), '%Y%b%d') as 'INDICATOR_DATE'
from (select hts.patient_id,
             hts.final_test_result,
             hts.visit_date,
             hts.test_type,
             pc.patient_id as contact,
             r.person_a,
             r.person_b
      from (select hts.patient_id, hts.final_test_result, hts.visit_date, hts.test_type
            from dwapi_etl.etl_hts_test hts
            where hts.test_strategy = 161557
              and hts.patient_given_result = 'Yes'
              and hts.voided = 0
              and hts.visit_date
                between DATE_SUB(date(last_day(date_sub(current_date(), interval 1 MONTH))), INTERVAL
                                 day(date(last_day(date_sub(current_date(), interval 1 MONTH)))) - 1 DAY)
                and date(last_day(date_sub(current_date(), interval 1 MONTH)))
            group by hts.patient_id) hts
               left JOIN
           (select patient_id
            from dwapi_etl.etl_patient_contact c
            where (c.relationship_type in (971, 972, 1528, 162221, 163565, 970, 5617))
              and c.patient_id is not NULL
              and c.voided = 0
            group by c.patient_id) pc on hts.patient_id = pc.patient_id
               left join (select r.person_a, r.person_b
                          from openmrs.relationship r
                                   inner join openmrs.relationship_type t
                                              on r.relationship = t.relationship_type_id and t.uuid in
                                                                                             ('8d91a01c-c2cc-11de-8d13-0010c6dffd0f',
                                                                                              '8d91a210-c2cc-11de-8d13-0010c6dffd0f',
                                                                                              'd6895098-5d8d-11e3-94ee-b35a4132a5e3',
                                                                                              '007b765f-6725-4ae9-afee-9966302bace4',
                                                                                              '2ac0d501-eadc-4624-b982-563c70035d46'
                                                                                                 )) r
                         on hts.patient_id = r.person_a or hts.patient_id = r.person_b
      where r.person_a is not null
         or pc.patient_id
         or r.person_b is not null is not null) a;
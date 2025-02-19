select d.patient_id                                                  as PatientPK,
       e.uuid                                                        as uuid,
       i.siteCode                                                    as SiteCode,
       d.unique_prep_number                                          as PrepNumber,
       d.national_unique_patient_identifier                          as NUPI,
       d.openmrs_id                                                  as HtsNumber,
       d.sha_number                                                  as SHANumber,
       d.shif_number                                                 as SHIFNumber,
       'KenyaEMR'                                                    as Emr,
       'HMIS'                                                        as Project,
       e.visit_date                                                  as PrEPEnrolmentDate,
       e.prep_type                                                   as TypeOfPrEP,
       case d.gender when 'M' then 'Male' when 'F' then 'Female' end as Sex,
       d.dob                                                         as DateOfBirth,
       d.birth_place                                                 as CountyOfBirth,
       pa.county                                                     as County,
       pa.sub_county                                                 as SubCounty,
       pa.location                                                   as Location,
       pa.land_mark                                                  as LandMark,
       pa.ward                                                       as Ward,
       e.patient_type                                                as ClientType,
       e.transfer_in_entry_point                                     as ReferralPoint,
       d.marital_status                                              as MaritalStatus,
       case e.in_school when 1 then 'Yes' when 2 then 'No' end       as InSchool,
       (case e.population_type
            when 164928 then 'General Population'
            when 6096 then 'Discordant Couple'
            when 164929 then 'Key Population' end)                   as PopulationType,
       case e.kp_type
           when 162277 then 'People in prison and other closed settings'
           when 165100 then 'Transgender'
           when 105 then 'PWID'
           when 160578 then 'MSM'
           when 165084 then 'MSW'
           when 160579 then 'FSW' end                                as KeyPopulationType,
       e.referred_from                                               as ReferredFrom,
       if(e.transfer_in_date is not null, 'Yes', 'No')               as TransferIn,
       date(e.transfer_in_date)                                      as TransferInDate,
       e.transfer_from                                               as TransferFromFacility,
       e.date_started_prep_trf_facility                              as DateFirstInitiatedInPrEPCare,
       e.date_started_prep_trf_facility                              as DateStartedPrEPAtTransferringFacility,
       e.previously_on_prep                                          as ClientPreviouslyOnPrEP,
       e.regimen                                                     as PrevPrepReg,
       e.prep_last_date                                              as DateLastUsed_Prev,
       e.date_created                                                as DateCreated,
       e.date_last_modified                                          as DateLastModified,
       e.voided                                                      as voided
from dwapi_etl.etl_prep_enrolment e
         left join dwapi_etl.etl_person_address pa on e.patient_id = pa.patient_id
         inner join dwapi_etl.etl_patient_demographics d on e.patient_id = d.patient_id
         inner join dwapi_etl.etl_prep_behaviour_risk_assessment r on e.patient_id = r.patient_id
         join kenyaemr_etl.etl_default_facility_info i;
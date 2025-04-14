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
            when 164929 then 'Key and Vulnerable population' end)    as PopulationType,
       case e.kp_type
           when 162277 then 'People in prison and other closed settings'
           when 105 then 'People Who Inject Drugs'
           when 160666 then 'People Who Use Drugs'
           when 159674 then 'Fisher folk'
           when 162198 then 'Truck driver'
           when 160578 then 'Men who have sex with men'
           when 165084 then 'Male Sex Worker'
           when 6096 then 'Discordant Couple'
           when 160579 then 'Female sex worker' end                  as KeyPopulationType,
       e.referred_from                                               as ReferredFrom,
       if(e.transfer_in_date is not null, 'Yes', 'No')               as TransferIn,
       date(e.transfer_in_date)                                      as TransferInDate,
       e.transfer_from                                               as TransferFromFacility,
       e.date_started_prep_trf_facility                              as DateFirstInitiatedInPrEPCare,
       e.date_started_prep_trf_facility                              as DateStartedPrEPAtTransferringFacility,
       case f.reason_for_starting_prep
           when 6096 then 'Sero-Serodiscordant Couples trying to conceive'
           when 5566 then 'Partner +ve(not on ART, ART last 6mnt, Poor Viral suppression)'
           when 5568 then 'Sex partner(s) high risk;  HIV status is unknown, partner multiple sex partners'
           when 5567 then 'Client has sex with more than one partner'
           when 1000475 then 'On going IPV/ Violence Screening'
           when 160579 then 'Engaging in transactional sex'
           when 112992 then 'Recent STI last 6 months'
           when 1691 then 'Recurrent use of PEP'
           when 165090 then 'Injection drug use with shared needles'
           when 165089 then 'Inconsistent or no condom use during intercourse'
           when 5622 then 'Other reasons' end                        as ReasonForPrep,
       e.previously_on_prep                                          as ClientPreviouslyOnPrEP,
       e.regimen                                                     as PrevPrepReg,
       e.prep_last_date                                              as DateLastUsed_Prev,
       e.date_created                                                as DateCreated,
       e.date_last_modified                                          as DateLastModified,
       e.voided                                                      as voided
from dwapi_etl.etl_prep_enrolment e
         left join dwapi_etl.etl_person_address pa on e.patient_id = pa.patient_id
         left join dwapi_etl.etl_prep_followup f on e.patient_id = f.patient_id and f.form = '1bfb09fc-56d7-4108-bd59-b2765fd312b8'
         inner join dwapi_etl.etl_patient_demographics d on e.patient_id = d.patient_id
         inner join dwapi_etl.etl_prep_behaviour_risk_assessment r on e.patient_id = r.patient_id
         join kenyaemr_etl.etl_default_facility_info i;
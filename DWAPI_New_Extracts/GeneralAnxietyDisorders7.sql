SELECT ga.patient_id            as PatientPK,
                                   d.unique_patient_no     as PatientID,
                                   i.siteCode              as SiteCode,
                                   i.FacilityName          as FacilityName,
                                   0                       as FacilityId,
                                   'KenyaEMR'              as Emr,
                                   ''                      as EMRVersion,
                                   'Kenya HMIS III'        as Project,    
                                   ga.visit_date           as VisitDate,   
                                      case ga.feeling_nervous_anxious
                                          when 160215 then 'Not at all'
                                        when 167000 then 'Several days'
                                          when 167001 then 'More than half the days'
                                          when 167002 then 'Nearly everyday'
                                          end 	     as  FeelingNervous,
                                   case ga.control_worrying
                                          when 160215 then 'Not at all'
                                        when 167000 then 'Several days'
                                          when 167001 then 'More than half the days'
                                          when 167002 then 'Nearly everyday'
                                          end 	     as ControlWorrying,
                                   case ga.worrying_much
                                          when 160215 then 'Not at all'
                                        when 167000 then 'Several days'
                                          when 167001 then 'More than half the days'
                                          when 167002 then 'Nearly everyday'
                                          end 	     as WorryingMuch,
                                   case ga.trouble_relaxing
                                          when 160215 then 'Not at all'
                                        when 167000 then 'Several days'
                                          when 167001 then 'More than half the days'
                                          when 167002 then 'Nearly everyday'
                                          end 	     as TroubleRelaxing,
                                   case ga.being_restless
                                          when 160215 then 'Not at all'
                                        when 167000 then 'Several days'
                                          when 167001 then 'More than half the days'
                                          when 167002 then 'Nearly everyday'
                                          end 	     as BeingRestless,
                                   case ga.feeling_bad
                                          when 160215 then 'Not at all'
                                        when 167000 then 'Several days'
                                          when 167001 then 'More than half the days'
                                          when 167002 then 'Nearly everyday'
                                          end 	     as FeelingBad,
                                   case ga.feeling_afraid
                                          when 160215 then 'Not at all'
                                        when 167000 then 'Several days'
                                          when 167001 then 'More than half the days'
                                          when 167002 then 'Nearly everyday'
                                          end 	     as FeelingAfraid,
                                   -- ga.assessment_outcome   as AnxietyScoreRating,
                                   case ga.assessment_outcome
                                          when 159410 then 'Minimal Anxiety'
                                        when 1498 then 'Mild Anxiety'
                                          when 1499 then 'Moderate Anxiety'
                                          when 1500 then 'Severe Anxiety'
                                          end 	     as GAD7Rating,                                           
                                   ga.date_created         as Date_Created,
                                   ga.date_last_modified   as Date_Last_Modified,
                                   ga.voided               as Voided
                               FROM dwapi_etl.etl_generalized_anxiety_disorder ga
                                     inner join dwapi_etl.etl_patient_demographics d on d.patient_id = ga.patient_id
                                     join kenyaemr_etl.etl_default_facility_info i
-- FUNCTION: migration.migrateestablishments(integer)

-- DROP FUNCTION migration.migrateestablishments(integer);

CREATE OR REPLACE FUNCTION migration.migrateestablishments(
		estb_id integer)
	    RETURNS void
	    LANGUAGE 'plpgsql'

	    COST 100
	    VOLATILE 
	AS $BODY$
	DECLARE
	  AllEstablishments REFCURSOR;
	  CurrentEstablishment RECORD;
	  NotMapped VARCHAR(10);
	  MappedEmpty VARCHAR(10);
	  MigrationUser VARCHAR(10);
	  ThisEstablishmentID INTEGER;
	  NewEstablishmentUID UUID;
	  MigrationTimestamp timestamp without time zone;
	  FullAddress TEXT;
	  NewIsRegulated BOOLEAN;
	  NewEmployerType VARCHAR(40);
	  NewIsCqcRegistered BOOLEAN;
	BEGIN
		  NotMapped := 'Not Mapped';
		  MappedEmpty := 'Was empty';
		  MigrationUser := 'migration';
		  MigrationTimestamp := clock_timestamp();
		  
		  OPEN AllEstablishments FOR 	select
		      e.id,
		      e.name,
		      e.address1,
		      e.address2,
		      e.address3,
		      e.town,
		      p.locationid,
		      e.postcode,
		      e.type as employertypeid,
		      p.totalstaff as numberofstaff,
		      e.nmdsid,
		      e.createddate,
		      e,visiblecsci,
		      ms.sfcid as sfc_tribal_mainserviceid,
		      "Establishment"."EstablishmentID" as newestablishmentid
		    from establishment e
		      inner join (
			          select distinct establishment_id from establishment_user inner join users on establishment_user.user_id = users.id where users.mustchangepassword = 0
				        ) allusers on allusers.establishment_id = e.id
					      left join provision p
					        inner join provision_servicetype pst inner join migration.services ms on pst.servicetype_id = ms.tribalid
						          on pst.provision_id = p.id and pst.ismainservice = 1
							        on p.establishment_id = e.id
									  left join cqc."Establishment" on "Establishment"."TribalID" = e.id
									     where e.id = estb_id
									     order by e.id asc;

									  LOOP
										    BEGIN
											    FETCH AllEstablishments INTO CurrentEstablishment;
											    EXIT WHEN NOT FOUND;

												RAISE NOTICE 'Processing tribal establishment: % (%)', CurrentEstablishment.id, CurrentEstablishment.newestablishmentid;
												    IF CurrentEstablishment.newestablishmentid IS NOT NULL THEN
													      -- we have already migrated this record - prepare to enrich/embellish the Establishment
													            PERFORM migration.establishment_other_services(CurrentEstablishment.id, CurrentEstablishment.newestablishmentid);
														      PERFORM migration.establishment_capacities(CurrentEstablishment.id, CurrentEstablishment.newestablishmentid);
														      PERFORM migration.establishment_service_users(CurrentEstablishment.id, CurrentEstablishment.newestablishmentid);
														      PERFORM migration.establishment_local_authorities(CurrentEstablishment.id, CurrentEstablishment.newestablishmentid, CurrentEstablishment.visiblecsci);
														      PERFORM migration.establishment_jobs(CurrentEstablishment.id, CurrentEstablishment.newestablishmentid);
														    ELSE
															      -- we have not yet migrated this record because there is no "newestablishmentid" - prepare a basic Establishment for inserting
															      	    FullAddress = '';
																      IF (CurrentEstablishment.address1 IS NOT NULL) THEN
																	        FullAddress := concat(FullAddress, CurrentEstablishment.address1, ',');
																		      END IF;
																		      IF (CurrentEstablishment.address2 IS NOT NULL) THEN
																			        FullAddress := concat(FullAddress, CurrentEstablishment.address2, ',');
																				      END IF;
																				      IF (CurrentEstablishment.address3 IS NOT NULL) THEN
																					        FullAddress := concat(FullAddress, CurrentEstablishment.address3, ',');
																						      END IF;
																						      IF (CurrentEstablishment.town IS NOT NULL) THEN
																							        FullAddress := concat(FullAddress, CurrentEstablishment.town);
																								      END IF;

																								      -- target Establishment needs a UID; unlike User, there is no UID in tribal dataset
																								            SELECT CAST(substr(CAST(v1uuid."UID" AS TEXT), 0, 15) || '4' || substr(CAST(v1uuid."UID" AS TEXT), 16, 3) || '-89' || substr(CAST(v1uuid."UID" AS TEXT), 22, 36) AS UUID)
																									        FROM (
																											          SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) "UID"
																												        ) v1uuid
																													      INTO NewEstablishmentUID;

																													      CASE CurrentEstablishment.locationid
																														        WHEN NULL THEN
																																          NewIsRegulated = false;
																																	        ELSE
																																			          NewIsRegulated = true;
																																				      END CASE;

																																				      CASE CurrentEstablishment.employertypeid
																																					        WHEN 130 THEN
																																							          NewEmployerType = 'Local Authority (adult services)';
																																								        WHEN 131 THEN
																																										          NewEmployerType = 'Local Authority (generic/other)';
																																											        WHEN 132 THEN
																																													          NewEmployerType = 'Local Authority (generic/other)';
																																														        WHEN 133 THEN
																																																          NewEmployerType = 'Local Authority (generic/other)';
																																																	        WHEN 134 THEN
																																																			          NewEmployerType = 'Other';
																																																				        WHEN 135 THEN
																																																						          NewEmployerType = 'Private Sector';
																																																							        WHEN 136 THEN
																																																									          NewEmployerType = 'Voluntary / Charity';
																																																										        WHEN 137 THEN
																																																												          NewEmployerType = 'Other';
																																																													        WHEN 138 THEN
																																																															          NewEmployerType = 'Private Sector';
																																																																        ELSE
																																																																		          NewEmployerType = 'Other';
																																																																			      END CASE;
																																																																			      
																																																																			      SELECT nextval('cqc."Establishment_EstablishmentID_seq"') INTO ThisEstablishmentID;
																																																																			      INSERT INTO cqc."Establishment" (
																																																																				        "EstablishmentID",
																																																																					        "TribalID",
																																																																						        "EstablishmentUID",
																																																																							        "NameValue",
																																																																								        "MainServiceFKValue",
																																																																									        "Address",
																																																																										        "LocationID",
																																																																											        "PostCode",
																																																																												        "IsRegulated",
																																																																													        "NmdsID",
																																																																														        "EmployerTypeValue",
																																																																															        "NumberOfStaffValue",
																																																																																        "created",
																																																																																	        "updated",
																																																																																		        "updatedby"
																																																																																			      ) VALUES (
																																																																																			        ThisEstablishmentID,
																																																																																				        CurrentEstablishment.id,
																																																																																					        NewEstablishmentUID,
																																																																																						        CurrentEstablishment.name,
																																																																																							        CurrentEstablishment.sfc_tribal_mainserviceid,
																																																																																								        FullAddress,
																																																																																									        CurrentEstablishment.locationid,
																																																																																										        CurrentEstablishment.postcode,
																																																																																											        NewIsRegulated,
																																																																																												        CurrentEstablishment.nmdsid,
																																																																																													        NewEmployerType::cqc.est_employertype_enum,
																																																																																														        CurrentEstablishment.numberofstaff,
																																																																																															        CurrentEstablishment.createddate,
																																																																																																        MigrationTimestamp,
																																																																																																	        MigrationUser
																																																																																																		        );
																																																																																																			--commit;
																																																																																																			      -- having inserted the new establishment, adorn with additional properties
																																																																																																			            PERFORM migration.establishment_other_services(CurrentEstablishment.id, ThisEstablishmentID);
																																																																																																				--commit;
																																																																																																				      PERFORM migration.establishment_capacities(CurrentEstablishment.id, ThisEstablishmentID);
																																																																																																				--commit;
																																																																																																				      PERFORM migration.establishment_service_users(CurrentEstablishment.id, ThisEstablishmentID);
																																																																																																				--commit;

																																																																																																				      PERFORM migration.establishment_local_authorities(CurrentEstablishment.id, ThisEstablishmentID, CurrentEstablishment.visiblecsci);
																																																																																																				--commit;
																																																																																																				      PERFORM migration.establishment_jobs(CurrentEstablishment.id, ThisEstablishmentID);
																																																																																																				--commit;
																																																																																																				    END IF;

																																																																																																				    --EXCEPTION WHEN OTHERS THEN RAISE WARNING 'Skipping establishment with id: %', CurrentEstablishment.id;
																																																																																																				      END;
																																																																																																				  END LOOP;

																																																																																																			END;
																																																																																																			$BODY$;

																																																																																																			ALTER FUNCTION migration.migrateestablishments(integer)
																																																																																																			    OWNER TO postgres;


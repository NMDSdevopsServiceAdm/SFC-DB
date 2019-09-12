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
  NewIsRegulated BOOLEAN;
  DataSource VARCHAR(6);
  NewEmployerType VARCHAR(40);
  NewIsCqcRegistered BOOLEAN;
  Owner VARCHAR(10);
  DataAccess VARCHAR(20);
BEGIN
  NotMapped := 'Not Mapped';
  MappedEmpty := 'Was empty';
  MigrationUser := 'migration';
  
  OPEN AllEstablishments FOR select
      e.id,
      e.name,
      e.address1,
      e.address2,
      e.address3,
      e.town,
      e.nonownerviewrights,
      e.ismyparentallowedtoedit,
      e.isparent,
      case when ms.sfcid = 16 THEN NULL ELSE p.locationid END as locationid,    -- if main service is head office, the location id needs to be null
      p.registrationid,
      p.registrationtype,
      e.postcode,
	    e.localidentifier,
      e.type as employertypeid,
      p.totalstaff as numberofstaff,
      e.nmdsid,
      e.createddate,
	    e.updateddate,
      e.visiblecsci,
	    e.source,
      ms.sfcid as sfc_tribal_mainserviceid,
      "Establishment"."EstablishmentID" as newestablishmentid
    from establishment e
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

    CASE 
	  WHEN CurrentEstablishment.registrationtype = 2 THEN
	    NewIsRegulated = true;
	  ELSE
	    NewIsRegulated = false;
    END CASE;

    IF CurrentEstablishment.newestablishmentid IS NOT NULL THEN
      -- we have already migrated this record - prepare to enrich/embellish the Establishment
      PERFORM migration.establishment_other_services(CurrentEstablishment.id, CurrentEstablishment.newestablishmentid);
      PERFORM migration.establishment_capacities(CurrentEstablishment.id, CurrentEstablishment.newestablishmentid);
      PERFORM migration.establishment_service_users(CurrentEstablishment.id, CurrentEstablishment.newestablishmentid);
      PERFORM migration.establishment_local_authorities(CurrentEstablishment.id, CurrentEstablishment.newestablishmentid, CurrentEstablishment.visiblecsci, NewIsRegulated);
      PERFORM migration.establishment_jobs(CurrentEstablishment.id, CurrentEstablishment.newestablishmentid);
    ELSE
      -- we have not yet migrated this record because there is no "newestablishmentid" - prepare a basic Establishment for inserting

      -- target Establishment needs a UID; unlike User, there is no UID in tribal dataset
      SELECT CAST(substr(CAST(v1uuid."UID" AS TEXT), 0, 15) || '4' || substr(CAST(v1uuid."UID" AS TEXT), 16, 3) || '-89' || substr(CAST(v1uuid."UID" AS TEXT), 22, 36) AS UUID)
        FROM (
          SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) "UID"
        ) v1uuid
      INTO NewEstablishmentUID;

	  CASE CurrentEstablishment.nonownerviewrights
        WHEN 1 THEN
          DataAccess = 'Workplace';
        WHEN 3 THEN
          DataAccess = 'Workplace and Staff';
        ELSE
          DataAccess = 'None';
      END CASE;

      CASE CurrentEstablishment.ismyparentallowedtoedit
        WHEN 1 THEN
          Owner = 'Parent';
        ELSE
          Owner = 'Workplace';
      END CASE;

	  CASE CurrentEstablishment.source
	    WHEN 'BULK UPLOAD' THEN
		  DataSource = 'Bulk';
		WHEN 'BULK UPLOAD v2' THEN
		  DataSource = 'Bulk';
		ELSE
		  DataSource = 'Online';
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
        "Address1",
        "Address2",
        "Address3",
        "Town",
        "LocationID",
		"ProvID",
		"ReasonsForLeaving",
        "PostCode",
		"LocalIdentifierValue",
        "IsRegulated",
        "NmdsID",
        "EmployerTypeValue",
        "NumberOfStaffValue",
		"IsParent",
		"DataSource",
		"Owner",
		"DataAccess",
		"LastBulkUploaded",
        "created",
        "updated",
        "updatedby"
      ) VALUES (
        ThisEstablishmentID,
        CurrentEstablishment.id,
        NewEstablishmentUID,
        CurrentEstablishment.name,
        CurrentEstablishment.sfc_tribal_mainserviceid,
        CurrentEstablishment.address1,
        CurrentEstablishment.address2,
        CurrentEstablishment.address3,
        CurrentEstablishment.town,
        CurrentEstablishment.locationid,
        CurrentEstablishment.registrationid,
		NULL,
        CurrentEstablishment.postcode,
		CurrentEstablishment.localidentifier,
        NewIsRegulated,
        TRIM(CurrentEstablishment.nmdsid),
        NewEmployerType::cqc.est_employertype_enum,
        CurrentEstablishment.numberofstaff,
		CurrentEstablishment.isparent::boolean,
		DataSource::cqc."DataSource",
		Owner::cqc.establishment_owner,
		DataAccess::cqc.establishment_parent_access_permission,
		CurrentEstablishment.updateddate,
        CurrentEstablishment.createddate,
		CurrentEstablishment.updateddate,
		MigrationUser
        );

      -- having inserted the new establishment, adorn with additional properties
      PERFORM migration.establishment_other_services(CurrentEstablishment.id, ThisEstablishmentID);
      PERFORM migration.establishment_capacities(CurrentEstablishment.id, ThisEstablishmentID);
      PERFORM migration.establishment_service_users(CurrentEstablishment.id, ThisEstablishmentID);
      PERFORM migration.establishment_local_authorities(CurrentEstablishment.id, ThisEstablishmentID, CurrentEstablishment.visiblecsci, NewIsRegulated);
      PERFORM migration.establishment_jobs(CurrentEstablishment.id, ThisEstablishmentID);

    END IF;

    EXCEPTION WHEN OTHERS THEN RAISE WARNING 'Skipping establishment with id: %', CurrentEstablishment.id;
    INSERT INTO "migration"."errorlog"(message,type,value)values(SQLERRM,'establishment', CurrentEstablishment.id);
  END;
  END LOOP;

END;
$BODY$;

ALTER FUNCTION migration.migrateestablishments(integer)
    OWNER TO postgres;

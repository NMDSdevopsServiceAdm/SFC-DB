create schema if not exists migration;

DROP FUNCTION IF EXISTS migration.DeleteAllTransactional;
CREATE OR REPLACE FUNCTION migration.DeleteAllTransactional()
  RETURNS void AS $$
DECLARE
BEGIN
  delete from cqc."WorkerQualification" where "TribalID" IS NOT NUL;
  delete from cqc."WorkerTraining" where "TribalID" IS NOT NULL;
  delete from cqc."WorkerAudit" where "WorkerFK" in (select distinct "ID" from cqc."Worker" where "TribalID" IS NOT NULL);
  delete from cqc."WorkerJobs" where "WorkerFK" in (select distinct "ID" from cqc."Worker" where "TribalID" IS NOT NULL);
  delete from cqc."Worker" where "TribalID" IS NOT NULL;
  delete from cqc."EstablishmentCapacity" where "EstablishmentID" in (select distinct "EstablishmentID" from cqc."Establishment" where "TribalID" IS NOT NULL);
  delete from cqc."EstablishmentJobs" where "EstablishmentID" in (select distinct "EstablishmentID" from cqc."Establishment" where "TribalID" IS NOT NULL);
  delete from cqc."EstablishmentServices" where "EstablishmentID" in (select distinct "EstablishmentID" from cqc."Establishment" where "TribalID" IS NOT NULL);
  delete from cqc."EstablishmentLocalAuthority" where "EstablishmentID" in (select distinct "EstablishmentID" from cqc."Establishment" where "TribalID" IS NOT NULL);
  delete from cqc."EstablishmentServiceUsers" where "EstablishmentID" in (select distinct "EstablishmentID" from cqc."Establishment" where "TribalID" IS NOT NULL);

  delete from cqc."Login" where "RegistrationID" in (select distinct "RegistrationID" from cqc."User" where "TribalID" IS NOT NULL);
  delete from cqc."UserAudit" where "UserFK" in (select distinct "RegistrationID" from cqc."User" where "TribalID" IS NOT NULL);
  delete from cqc."PasswdResetTracking" where "UserFK" in (select distinct "RegistrationID" from cqc."User" where "TribalID" IS NOT NULL);
  delete from cqc."User" where "TribalID" IS NOT NULL;
  delete from cqc."EstablishmentAudit" where "EstablishmentFK" in (select distinct "EstablishmentID" from cqc."Establishment" where "TribalID" IS NOT NULL);
  delete from cqc."Establishment" where "TribalID" IS NOT NULL;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS migration.Validate;
CREATE OR REPLACE FUNCTION migration.Validate()
  RETURNS void AS $$
DECLARE
  NumberOfUsers INTEGER;
  NumberOfReadOnlyLogins INTEGER;
  NumberOfEditLogins INTEGER;
  NumberOfEstablishments INTEGER;
  NumberOfEstablishmentServices INTEGER;
  NumberOfEstablishmentCapacities INTEGER;
  NumberOfEstablishmentServiceUsers INTEGER;
  NumberOfEstablishmentLocalAuthorities INTEGER;
  NumberOfEstablishmentJobs INTEGER;
  NumberOfWorkers INTEGER;
  NumberOfWorkersQualifications INTEGER;
  NumberOfWorkersTraining INTEGER;
  NumberOfServiceCapacities INTEGER;
  NumberOfQualifications INTEGER;
  NumberOfQualificationsWithNullLevel INTEGER;
  NumberOfCountries INTEGER;
BEGIN
  select count(0)
  from cqc."Establishment"
  where "Establishment"."TribalID" in (156182, 59, 248, 669, 187078, 215842, 162286, 2533, 2952, 200560, 225586, 3278, 60682, 5228, 12937, 232842, 10121, 10757, 216264, 12041, 17047, 177958, 136485, 15000, 20876, 233642, 17661, 168369, 40762, 205162, 154806, 42683, 45882, 196119, 85603, 181062, 218926, 196840, 144133, 215263, 170258, 217893, 231842)
    into NumberOfEstablishments;

  select count(0)
  from cqc."EstablishmentServices"
    inner join cqc."Establishment" on "EstablishmentServices"."EstablishmentID" = "Establishment"."EstablishmentID"
  where "Establishment"."TribalID" in (156182, 59, 248, 669, 187078, 215842, 162286, 2533, 2952, 200560, 225586, 3278, 60682, 5228, 12937, 232842, 10121, 10757, 216264, 12041, 17047, 177958, 136485, 15000, 20876, 233642, 17661, 168369, 40762, 205162, 154806, 42683, 45882, 196119, 85603, 181062, 218926, 196840, 144133, 215263, 170258, 217893, 231842)
    into NumberOfEstablishmentServices;

  select count(0)
  from cqc."EstablishmentCapacity"
    inner join cqc."Establishment" on "EstablishmentCapacity"."EstablishmentID" = "Establishment"."EstablishmentID"
  where "Establishment"."TribalID" in (156182, 59, 248, 669, 187078, 215842, 162286, 2533, 2952, 200560, 225586, 3278, 60682, 5228, 12937, 232842, 10121, 10757, 216264, 12041, 17047, 177958, 136485, 15000, 20876, 233642, 17661, 168369, 40762, 205162, 154806, 42683, 45882, 196119, 85603, 181062, 218926, 196840, 144133, 215263, 170258, 217893, 231842)
    into NumberOfEstablishmentCapacities;

  select count(0)
  from cqc."EstablishmentServiceUsers"
    inner join cqc."Establishment" on "EstablishmentServiceUsers"."EstablishmentID" = "Establishment"."EstablishmentID"
  where "Establishment"."TribalID" in (156182, 59, 248, 669, 187078, 215842, 162286, 2533, 2952, 200560, 225586, 3278, 60682, 5228, 12937, 232842, 10121, 10757, 216264, 12041, 17047, 177958, 136485, 15000, 20876, 233642, 17661, 168369, 40762, 205162, 154806, 42683, 45882, 196119, 85603, 181062, 218926, 196840, 144133, 215263, 170258, 217893, 231842)
    into NumberOfEstablishmentServiceUsers;

  select count(0)
  from cqc."EstablishmentLocalAuthority"
    inner join cqc."Establishment" on "EstablishmentLocalAuthority"."EstablishmentID" = "Establishment"."EstablishmentID"
  where "Establishment"."TribalID" in (156182, 59, 248, 669, 187078, 215842, 162286, 2533, 2952, 200560, 225586, 3278, 60682, 5228, 12937, 232842, 10121, 10757, 216264, 12041, 17047, 177958, 136485, 15000, 20876, 233642, 17661, 168369, 40762, 205162, 154806, 42683, 45882, 196119, 85603, 181062, 218926, 196840, 144133, 215263, 170258, 217893, 231842)
    into NumberOfEstablishmentLocalAuthorities;

  select count(0)
  from cqc."EstablishmentJobs"
    inner join cqc."Establishment" on "EstablishmentJobs"."EstablishmentID" = "Establishment"."EstablishmentID"
  where "Establishment"."TribalID" in (156182, 59, 248, 669, 187078, 215842, 162286, 2533, 2952, 200560, 225586, 3278, 60682, 5228, 12937, 232842, 10121, 10757, 216264, 12041, 17047, 177958, 136485, 15000, 20876, 233642, 17661, 168369, 40762, 205162, 154806, 42683, 45882, 196119, 85603, 181062, 218926, 196840, 144133, 215263, 170258, 217893, 231842)
    into NumberOfEstablishmentJobs;


  select count(0)
  from cqc."User"
    inner join cqc."Establishment" on "Establishment"."EstablishmentID" = "User"."EstablishmentID"
  where "Establishment"."TribalID" in (156182, 59, 248, 669, 187078, 215842, 162286, 2533, 2952, 200560, 225586, 3278, 60682, 5228, 12937, 232842, 10121, 10757, 216264, 12041, 17047, 177958, 136485, 15000, 20876, 233642, 17661, 168369, 40762, 205162, 154806, 42683, 45882, 196119, 85603, 181062, 218926, 196840, 144133, 215263, 170258, 217893, 231842)
    and "User"."TribalPasswordAnswer" IS NOT NULL
    into NumberOfUsers;

  select count(0)
  from cqc."Login"
    inner join cqc."User"
      inner join cqc."Establishment" on "Establishment"."EstablishmentID" = "User"."EstablishmentID"
      on "User"."RegistrationID" = "Login"."RegistrationID"
  where "Establishment"."TribalID" in (156182, 59, 248, 669, 187078, 215842, 162286, 2533, 2952, 200560, 225586, 3278, 60682, 5228, 12937, 232842, 10121, 10757, 216264, 12041, 17047, 177958, 136485, 15000, 20876, 233642, 17661, 168369, 40762, 205162, 154806, 42683, 45882, 196119, 85603, 181062, 218926, 196840, 144133, 215263, 170258, 217893, 231842)
    and "Login"."TribalHash" is not null
    and "User"."UserRoleValue" = 'Read'
    into NumberOfReadOnlyLogins;

  select count(0)
  from cqc."Login"
    inner join cqc."User"
      inner join cqc."Establishment" on "Establishment"."EstablishmentID" = "User"."EstablishmentID"
      on "User"."RegistrationID" = "Login"."RegistrationID"
  where "Establishment"."TribalID" in (156182, 59, 248, 669, 187078, 215842, 162286, 2533, 2952, 200560, 225586, 3278, 60682, 5228, 12937, 232842, 10121, 10757, 216264, 12041, 17047, 177958, 136485, 15000, 20876, 233642, 17661, 168369, 40762, 205162, 154806, 42683, 45882, 196119, 85603, 181062, 218926, 196840, 144133, 215263, 170258, 217893, 231842)
    and "Login"."TribalHash" is not null
    and "User"."UserRoleValue" = 'Edit'
    into NumberOfEditLogins;

  select count(0)
  from cqc."Worker"
    inner join cqc."Establishment" on "Worker"."EstablishmentFK" = "Establishment"."EstablishmentID"
  where "Establishment"."TribalID" in (156182, 59, 248, 669, 187078, 215842, 162286, 2533, 2952, 200560, 225586, 3278, 60682, 5228, 12937, 232842, 10121, 10757, 216264, 12041, 17047, 177958, 136485, 15000, 20876, 233642, 17661, 168369, 40762, 205162, 154806, 42683, 45882, 196119, 85603, 181062, 218926, 196840, 144133, 215263, 170258, 217893, 231842)
    into NumberOfWorkers;


  select count(0)
  from cqc."WorkerTraining"
    inner join cqc."Worker"
      inner join cqc."Establishment" on "Establishment"."EstablishmentID" = "Worker"."EstablishmentFK"
      on "Worker"."ID" = "WorkerTraining"."WorkerFK"
  where "Establishment"."TribalID" in (156182, 59, 248, 669, 187078, 215842, 162286, 2533, 2952, 200560, 225586, 3278, 60682, 5228, 12937, 232842, 10121, 10757, 216264, 12041, 17047, 177958, 136485, 15000, 20876, 233642, 17661, 168369, 40762, 205162, 154806, 42683, 45882, 196119, 85603, 181062, 218926, 196840, 144133, 215263, 170258, 217893, 231842)
    and "WorkerTraining"."TribalID" IS NOT NULL
    into NumberOfWorkersTraining;

  select count(0)
  from cqc."WorkerQualifications"
    inner join cqc."Worker"
      inner join cqc."Establishment" on "Establishment"."EstablishmentID" = "Worker"."EstablishmentFK"
      on "Worker"."ID" = "WorkerQualifications"."WorkerFK"
  where "Establishment"."TribalID" in (156182, 59, 248, 669, 187078, 215842, 162286, 2533, 2952, 200560, 225586, 3278, 60682, 5228, 12937, 232842, 10121, 10757, 216264, 12041, 17047, 177958, 136485, 15000, 20876, 233642, 17661, 168369, 40762, 205162, 154806, 42683, 45882, 196119, 85603, 181062, 218926, 196840, 144133, 215263, 170258, 217893, 231842)
    and "WorkerQualifications"."TribalID" IS NOT NULL
    into NumberOfWorkersQualifications;


  IF (NumberOfEstablishments = 43) THEN
    RAISE INFO 'Establishment count matches';
  ELSE
    RAISE WARNING 'Establishment count fails match: %', NumberOfEstablishments;
  END IF;

  IF (NumberOfEstablishmentServices = 47) THEN
    RAISE INFO 'Establishment Services count matches';
  ELSE
    RAISE WARNING 'Establishment Services count fails match: %', NumberOfEstablishmentServices;
  END IF;
  IF (NumberOfEstablishmentCapacities = 83) THEN
    RAISE INFO 'Establishment Capacities count matches';
  ELSE
    RAISE WARNING 'Establishment Capacities count fails match: %', NumberOfEstablishmentCapacities;
  END IF;
  IF (NumberOfEstablishmentServiceUsers = 311) THEN
    RAISE INFO 'Establishment Service Users count matches';
  ELSE
    RAISE WARNING 'Establishment Service Users count fails match: %', NumberOfEstablishmentServiceUsers;
  END IF;
  IF (NumberOfEstablishmentLocalAuthorities = 51) THEN
    RAISE INFO 'Establishment Local Authorities count matches';
  ELSE
    RAISE WARNING 'Establishment Local Authorities count fails match: %', NumberOfEstablishmentLocalAuthorities;
  END IF;
  IF (NumberOfEstablishmentJobs = 249) THEN
    RAISE INFO 'Establishment Jobs count matches';
  ELSE
    RAISE WARNING 'Establishment Jobs count fails match: %', NumberOfEstablishmentJobs;
  END IF;


  IF (NumberOfUsers = 87) THEN
    RAISE INFO 'User count matches';
  ELSE
    RAISE WARNING 'User count fails match: %', NumberOfUsers;
  END IF;
  IF (NumberOfReadOnlyLogins = 9) THEN
    RAISE INFO 'Read Only Logins count matches';
  ELSE
    RAISE WARNING 'Read Only Logins count fails match: %', NumberOfReadOnlyLogins;
  END IF;
  IF (NumberOfEditLogins = 77) THEN
    RAISE INFO 'Edit Logins count matches';
  ELSE
    RAISE WARNING 'Edit Logins count fails match: %', NumberOfEditLogins;
  END IF;
  IF (NumberOfWorkers = 2257) THEN
    RAISE INFO 'Worker count matches';
  ELSE
    RAISE WARNING 'Worker count fails match: %', NumberOfWorkers;
  END IF;
  IF (NumberOfWorkersTraining = 18899) THEN
    RAISE INFO 'Worker Training count matches';
  ELSE
    RAISE WARNING 'Worker Training count fails match: %', NumberOfWorkersTraining;
  END IF;
  IF (NumberOfWorkersQualifications = 2050) THEN
    RAISE INFO 'Worker Qualifications count matches';
  ELSE
    RAISE WARNING 'Worker Qualifications count fails match: %', NumberOfWorkersQualifications;
  END IF;



  -- these counts double check the patch has been applied (two new service capacities, two new qualifications, six new qualifications without levels)
  select count(0)
  from cqc."ServicesCapacity"
    into NumberOfServiceCapacities;
  select count(0)
  from cqc."Qualifications"
    into NumberOfQualifications;
  select count(0)
  from cqc."Qualifications"
  where "Level" IS NULL
    into NumberOfQualificationsWithNullLevel;
  select count(0)
  from cqc."Country"
    into NumberOfCountries;

  IF (NumberOfServiceCapacities = 18) THEN
    RAISE INFO 'Capacities count matches';
  ELSE
    RAISE WARNING 'Capacities count fails match: %', NumberOfServiceCapacities;
  END IF;
  IF (NumberOfQualifications = 127) THEN
    RAISE INFO 'Qualifications count matches';
  ELSE
    RAISE WARNING 'Qualifications count fails match: %', NumberOfQualifications;
  END IF;
  IF (NumberOfQualificationsWithNullLevel = 23) THEN
    RAISE INFO 'Qualifications with no level count matches';
  ELSE
    RAISE WARNING 'Qualifications with no level count fails match: %', NumberOfQualificationsWithNullLevel;
  END IF;
  IF (NumberOfCountries = 246) THEN
    RAISE INFO 'Countries with no level count matches';
  ELSE
    RAISE WARNING 'Countries with no level count fails match: %', NumberOfCountries;
  END IF;

END;
$$ LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS migration.MigrateAll;
CREATE OR REPLACE FUNCTION migration.MigrateAll()
  RETURNS void AS $$
DECLARE
BEGIN
  PERFORM migration.MigrateEstablishments();
  PERFORM migration.MigrateUsers();
  PERFORM migration.MigrateWorkers();
  PERFORM migration.worker_bulk_training();
  PERFORM migration.worker_bulk_qualifications();
END;
$$ LANGUAGE plpgsql;
--Adding  a new function to call migrateUsers;

 -- FUNCTION: migration.loop_estbid_users(integer)

 -- DROP FUNCTION migration.loop_estbid_users(integer);

CREATE OR REPLACE FUNCTION migration.loop_estbid_users(n integer DEFAULT 100)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$
DECLARE
Allestbid  REFCURSOR;
currentestbid record;
Begin 
OPEN Allestbid  for 
select establishment_id from establishment_user where establishment_id not in  (156182, 59, 248, 669, 187078, 215842, 162286, 2533, 2952, 200560, 225586, 3278, 60682, 5228, 12937, 232842, 10121, 10757, 216264, 12041, 17047, 177958, 136485,15000, 20876, 233642, 17661, 168369, 40762, 205162, 154806, 42683, 45882, 196119, 85603, 181062, 218926,196840, 144133, 215263, 170258, 217893, 231842) limit n;
Loop
Begin
FETCH Allestbid INTO currentestbid;
EXIT WHEN NOT FOUND;
PERFORM  migration.MigrateUsers(currentestbid.establishment_id);            
--  RAISE NOTICE ' %', current_establishment_id.id;
END;
END LOOP;
END;
$BODY$;

ALTER FUNCTION migration.loop_estbid_users(integer)
OWNER TO postgres;


DROP FUNCTION IF EXISTS migration.MigrateUsers;
CREATE OR REPLACE FUNCTION migration.MigrateUsers(estb_id int)
  RETURNS void AS $$
DECLARE
  AllUsers REFCURSOR;
  CurrentUser RECORD;
  NewUserRole VARCHAR(4);
  NewJobTitle VARCHAR(120);
  NewIsPrimary BOOLEAN;
  NotMapped VARCHAR(10);
  MappedEmpty VARCHAR(10);
  MigrationUser VARCHAR(10);
  FullName VARCHAR(120);
  ThisRegistrationID INTEGER;
  MigrationTimestamp timestamp without time zone;
  TargetHash VARCHAR(10);
  NewUsername VARCHAR(120);
  NewUserRandomNumber INTEGER;
BEGIN
  NotMapped := 'Not Mapped';
  MappedEmpty := 'Was empty';
  MigrationUser := 'migration';
  MigrationTimestamp := clock_timestamp();
  TargetHash := NULL;
  
  OPEN AllUsers FOR select cqc."Establishment"."EstablishmentID" AS establishmentid, "User"."TribalID" AS newuserid, users.*, establishment_user.*, establishment.telephone as users_telephone
    from
      users
        inner join establishment_user on establishment_user.user_id = users.id
          inner join cqc."Establishment"
            inner join establishment on "Establishment"."TribalID" = establishment.id
            on "Establishment"."TribalID" = establishment_user.establishment_id
		    left join cqc."User" on "User"."TribalID" = users.id
    where users.status <> 4
      and establishment_user.establishment_id=estb_id ; --Removed the hardcoded values for establishmetid field passing this value from a parent function called migration.loop_estbid_users()
  LOOP
    FETCH AllUsers INTO CurrentUser;
    EXIT WHEN NOT FOUND;

    IF CurrentUser.newuserid IS NULL THEN
      FullName := CurrentUser.firstname || ' ' || CurrentUser.lastname;
      
      CASE CurrentUser.isreadonly
        WHEN 1 THEN
          NewUserRole = 'Read';
        ELSE
          NewUserRole = 'Edit';
      END CASE;
      
      CASE CurrentUser.isprimary
        WHEN 1 THEN
          NewIsPrimary = true;
        ELSE
          NewIsPrimary = false;
      END CASE;
      
      -- handle null job title
      CASE CurrentUser.jobtitle
        WHEN NULL THEN
          NewJobTitle = MappedEmpty;
        ELSE
          NewJobTitle = CurrentUser.jobtitle;
      END CASE;
      
      SELECT nextval('cqc."User_RegistrationID_seq"') INTO ThisRegistrationID;
      INSERT INTO cqc."User" (
        "RegistrationID",
        "TribalID",
        "UserUID",
        "EstablishmentID",
        "AdminUser",
        "FullNameValue",
        "JobTitleValue",
        "EmailValue",
        "PhoneValue",
        "SecurityQuestionValue",
        "SecurityQuestionAnswerValue",
      "UserRoleValue",
        "created",
        "updated",
        "updatedby",
        "Archived",
        "TribalPasswordAnswer",
        "IsPrimary") VALUES (
          ThisRegistrationID,
          CurrentUser.id,
          uuid(CurrentUser.uniqueid),
          CurrentUser.establishmentid,
          false,
          FullName,
          COALESCE(CurrentUser.jobtitle, 'Empty'),
          CurrentUser.loweremail,
          CurrentUser.users_telephone,
          CurrentUser.passwordquestion,
          NULL,
          NewUserRole::cqc.user_role,
          CurrentUser.creationdate,
          MigrationTimestamp,
          MigrationUser,
          false,
          CurrentUser.passwordanswer,
          NewIsPrimary
        );

      -- owing to not being able to handle a "read" user in target application
      --   rename the login username to prevent read users from login
      NewUsername = CurrentUser.lowerusername;
      IF (NewUserRole = 'Read') THEN
        SELECT floor(random() * 100 + 1)::int into NewUserRandomNumber;
        NewUsername = CONCAT('migration_', NewUserRandomNumber, '_', CurrentUser.lowerusername);
      END IF;
        
      INSERT INTO cqc."Login" (
        "RegistrationID",
        "Username",
        "Active",
        "InvalidAttempt",
        "Hash",
        "FirstLogin",
        "LastLoggedIn",
        "PasswdLastChanged",
        "TribalHash",
        "TribalSalt"
      ) VALUES (
        ThisRegistrationID,
        NewUsername,
        true,
        0,
        TargetHash,
        null,
        CurrentUser.lastlogindate,
        COALESCE(CurrentUser.lastpasswordchangeddate, CurrentUser.creationdate),
        CurrentUser.password,
        CurrentUser.salt
      );
    END IF;

  END LOOP;

END;
$$ LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS migration.migrateestablishments;
CREATE OR REPLACE FUNCTION migration.migrateestablishments(
	)
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
     where e.id in (156182, 59, 248, 669, 187078, 215842, 162286, 2533, 2952, 200560, 225586, 3278, 60682, 5228, 12937, 232842, 10121, 10757, 216264, 12041, 17047, 177958, 136485, 15000, 20876, 233642, 17661, 168369, 40762, 205162, 154806, 42683, 45882, 196119, 85603, 181062, 218926, 196840, 144133, 215263, 170258, 217893, 231842)
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

      -- having inserted the new establishment, adorn with additional properties
      PERFORM migration.establishment_other_services(CurrentEstablishment.id, ThisEstablishmentID);
      PERFORM migration.establishment_capacities(CurrentEstablishment.id, ThisEstablishmentID);
      PERFORM migration.establishment_service_users(CurrentEstablishment.id, ThisEstablishmentID);
      PERFORM migration.establishment_local_authorities(CurrentEstablishment.id, ThisEstablishmentID, CurrentEstablishment.visiblecsci);
      PERFORM migration.establishment_jobs(CurrentEstablishment.id, ThisEstablishmentID);

    END IF;

    EXCEPTION WHEN OTHERS THEN RAISE WARNING 'Skipping establishment with id: %', CurrentEstablishment.id;
  END;
  END LOOP;

END;
$BODY$;

DROP FUNCTION IF EXISTS migration.migrateworkers;
CREATE OR REPLACE FUNCTION migration.migrateworkers(
	)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
DECLARE
  AllWorkers REFCURSOR;
  CurrentWorker RECORD;
  NotMapped VARCHAR(10);
  MappedEmpty VARCHAR(10);
  MigrationUser VARCHAR(10);
  ThisEstablishmentID INTEGER;
  NewWorkerUID UUID;
  MigrationTimestamp timestamp without time zone;
  NewContract VARCHAR(50);
  NewMainJobFK INTEGER;
BEGIN
  NotMapped := 'Not Mapped';
  MappedEmpty := 'Was empty';
  MigrationUser := 'migration';
  MigrationTimestamp := clock_timestamp();

  OPEN AllWorkers FOR select
      w.id as id,
      "Establishment"."EstablishmentID" as establishmentid,
      w.localidentifier,
      w.employmentstatus,
      w.createddate,
      "Job"."JobID" as jobid,
      "Worker"."ID" as newworkerid,
      originalcountrycode,
      targetcountryid,
      originalnationalitycode,
      targetnationalityid,
      wp.contractedhours,
      wp.hourlyrate,
      worker_decrypted.dob_dcd as target_dob,
      worker_decrypted.ni_dcd as target_ni,
      w.*
    from worker w
      inner join cqc."Establishment" on w.establishment_id = "Establishment"."TribalID"
      inner join "worker_provision" wp
        inner join migration.jobs mj
          inner join cqc."Job" on "Job"."JobID" = mj.sfcid
          on mj.tribalid = wp.jobrole
        on w.id = wp.worker_id
      left join cqc."Worker" on "Worker"."TribalID" = w.id
      left join (SELECT country.numeric AS originalcountrycode, "ID" AS targetcountryid
                 FROM country
                  LEFT JOIN migration.country AS migrationcountry
                    INNER JOIN cqc."Country" ON migrationcountry.sfcid = "Country"."ID"
                    ON migrationcountry.tribalid = country.id
                ) AS MappedCountries ON MappedCountries.originalcountrycode = w.countryofbirth
	    left join (SELECT country.numeric AS originalnationalitycode, "ID" AS targetnationalityid
                 FROM country
                  LEFT JOIN migration.nationality as migrationnationality
                    INNER JOIN cqc."Nationality" on migrationnationality.sfcid = "Nationality"."ID"
                    ON migrationnationality.tribalid = country.id
                ) AS MappedNationalities ON MappedNationalities.originalnationalitycode = w.nationality
      left join worker_decrypted on worker_decrypted.id = w.id
    where (w.employmentstatus = 195 or w.localidentifier is not null);   -- employmenbt status of 195 is volunteer (we're not migrating volunteer workers)

  LOOP
    BEGIN
    FETCH AllWorkers INTO CurrentWorker;
    EXIT WHEN NOT FOUND;

    RAISE NOTICE 'Processing tribal worker: % (%)', CurrentWorker.id, CurrentWorker.newworkerid;
    IF CurrentWorker.newworkerid IS NOT NULL THEN
      -- we have already migrated this record - prepare to enrich/embellish the Worker
      PERFORM migration.worker_easy_properties(CurrentWorker.id, CurrentWorker.newworkerid, CurrentWorker);
      PERFORM migration.worker_other_jobs(CurrentWorker.id, CurrentWorker.newworkerid);

    ELSE
      -- we have already migrated this record - prepare to insert new Worker
      -- target Worker needs a UID; unlike User, there is no UID in tribal dataset
      SELECT CAST(substr(CAST(v1uuid."UID" AS TEXT), 0, 15) || '4' || substr(CAST(v1uuid."UID" AS TEXT), 16, 3) || '-89' || substr(CAST(v1uuid."UID" AS TEXT), 22, 36) AS UUID)
        FROM (
          SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) "UID"
        ) v1uuid
      INTO NewWorkerUID;

      IF (CurrentWorker.employmentstatus IS NULL) THEN
            NewContract = 'Permanent';
      ELSE
        CASE CurrentWorker.employmentstatus
          WHEN 190 THEN
            NewContract = 'Permanent';
          WHEN 191 THEN
            NewContract = 'Temporary';
          WHEN 192 THEN
            NewContract = 'Pool/Bank';
          WHEN 193 THEN
            NewContract = 'Agency';
          ELSE
            NewContract = 'Other';
        END CASE;
      END IF;

    -- Worker does not have a sequence number; it's a serial
      INSERT INTO cqc."Worker" (
        "TribalID",
        "WorkerUID",
        "EstablishmentFK",
        "NameOrIdValue",
        "ContractValue",
        "MainJobFKValue",
        "created",
        "updated",
        "updatedby"
      ) VALUES (
        CurrentWorker.id,
        NewWorkerUID,
        CurrentWorker.establishmentid,
        CurrentWorker.localidentifier,
        NewContract::cqc."WorkerContract",
        CurrentWorker.jobid,
        CurrentWorker.createddate,
        MigrationTimestamp,
        MigrationUser
      );

      -- having inserted the new worker, adorn with additional properties
      PERFORM migration.worker_easy_properties(CurrentWorker.id, CurrentWorker.newworkerid, CurrentWorker);
      PERFORM migration.worker_other_jobs(CurrentWorker.id, CurrentWorker.newworkerid);
    END IF;

    EXCEPTION WHEN OTHERS THEN RAISE WARNING 'Skipping worker with id: %', CurrentWorker.id;
  END;
  END LOOP;
END;
$BODY$;

-- from services to services
drop table if exists migration.services;
create table migration.services (
	tribalid INTEGER NOT NULL,
	sfcid INTEGER NOT NULL
);
insert into migration.services (tribalid, sfcid) values
  (1, 24),
  (2, 25),
  (3, 12),
  (4, 13),
  (5, 12),
  (6, 9),
  (7, 10),
  (8, 20),
  (9, 15),
  (10, 11),
  (11, 15),
  (12, 15),
  (13, 1),
  (14, 7),
  (15, 2),
  (16, 8),
  (17, 19),
  (18, 3),
  (19, 5),
  (20, 4),
  (21, 6),
  (22, 15),
  (23, 15),
  (24, 14),
  (25, 14),
  (26, 14),
  (27, 14),
  (28, 14),
  (29, 14),
  (30, 14),
  (31, 14),
  (32, 14),
  (33, 14),
  (34, 14),
  (35, 14),
  (36, 14),
  (37, 14),
  (38, 14),
  (39, 14),
  (40, 28),
  (41, 14),
  (42, 17),
  (43, 17),
  (44, 17),
  (45, 17),
  (46, 17),
  (47, 17),
  (48, 28),
  (49, 30),
  (50, 15),
  (51, 17),
  (52, 15),
  (53, 13),
  (54, 21),
  (55, 23),
  (56, 14),
  (57, 15),
  (58, 14),
  (59, 14),
  (60, 36),
  (61, 27),
  (62, 28),
  (63, 26),
  (64, 29),
  (65, 15),
  (66, 30),
  (67, 32),
  (68, 31),
  (69, 33),
  (70, 34),
  (71, 17),
  (72, 16),
  (73, 35);


-- from jobs to jobs
drop table if exists migration.jobs;
create table migration.jobs (
	tribalid INTEGER NOT NULL,
	sfcid INTEGER NOT NULL
);
insert into migration.jobs (tribalid, sfcid) values 
  (80, 26),
  (81, 15),
  (82, 13),
  (83, 22),
  (84, 28),
  (85, 27),
  (86, 25),
  (87, 10),
  (88, 11),
  (89, 12),
  (90, 3),
  (91, 6),
  (92, 6),
  (93, 3),
  (94, 18),
  (95, 23),
  (96, 4),
  (97, 16),
  (98, 6),
  (99, 6,
  (100, 6),
  (101, 29),
  (102, 20),
  (103, 14),
  (104, 2),
  (105, 5),
  (106, 21),
  (107, 21),
  (108, 1),
  (109, 24),
  (140, 19),
  (141, 17),
  (142, 16),
  (143, 7),
  (144, 8),
  (145, 9);

-- from usertype to serviceusers
drop table if exists migration.serviceusers;
create table migration.serviceusers (
	tribalid INTEGER NOT NULL,
	sfcid INTEGER NOT NULL
);
insert into migration.serviceusers (tribalid, sfcid) values 
  (1, 1),
  (2, 2),
  (3, 9),
  (4, 14),
  (5, 13),
  (6, 11),
  (7, 15),
  (8, 16),
  (9, 18),
  (10, 19),
  (11, 19),
  (12, 19),
  (13, 19),
  (14, 19),
  (15, 19),
  (16, 19),
  (17, 19),
  (18, 20),
  (19, 21),
  (20, 22),
  (21, 23),
  (22, 3),
  (23, 4),
  (24, 4),
  (25, 5),
  (26, 6),
  (27, 7),
  (28, 10),
  (29, 12),
  (30, 13),
  (31, 17),
  (33, 19),
  (34, 19),
  (35, 19),
  (36, 9),
  (37, 9),
  (38, 9),
  (39, 18),
  (40, 18),
  (41, 18),
  (42, 19),
  (43, 19),
  (44, 19);

-- from lookupitem(training) to cqc.TrainingCategories
drop table if exists migration.trainingcategories;
create table migration.trainingcategories (
	tribalid INTEGER NOT NULL,
	sfcid INTEGER NOT NULL
);
insert into migration.trainingcategories (tribalid, sfcid) values 
  (640, 8),
  (641, 10),
  (642, 12),
  (643, 2),
  (644, 14),
  (645, 17),
  (646, 18),
  (647, 19),
  (648, 20),
  (649, 21),
  (650, 22),
  (651, 23),
  (652, 24),
  (653, 25),
  (654, 27),
  (655, 28),
  (656, 29),
  (657, 31),
  (658, 32),
  (659, 33),
  (660, 37),
  (800, 12),
  (801, 16),
  (850, 2);

-- from lookupitem(leaving reasons and leaver destination to cqc.WorkerLeaveReasons
--  source reasons and destinations are mapped to a single target leave reason
drop table if exists migration.workerleavingreasons;
create table migration.workerleavingreasons (
	tribalid INTEGER NOT NULL,
  tribalidd INTEGER NULL,
	sfcid INTEGER NOT NULL
);
insert into migration.workerleavingreasons(tribalid, tribalidd, sfcid) values
  (60, NULL, 1),
  (61, NULL, 1),
  (62, NULL, 8),
  (63, NULL, 8),
  (64, NULL, 2),
  (65, NULL, 3),
  (66, NULL, 3),
  (67, NULL, 4),
  (68, NULL, 8),
  (69, NULL, 9),
  (70, 40, 5),
  (70, 41, 5),
  (70, 42, 5),
  (70, 43, 5),
  (70, 44, 5),
  (70, 45, 5),
  (70, 46, 5),
  (70, 47, 5),
  (70, 48, 6),
  (70, 49, 8),
  (70, 50, 7),
  (70, 52, 8),
  (70, 53, 8),
  (70, 54, 8),
  (70, 55, 9),
  (71, 40, 5),
  (71, 41, 5),
  (71, 42, 5),
  (71, 43, 5),
  (71, 44, 5),
  (71, 45, 5),
  (71, 46, 5),
  (71, 47, 5),
  (71, 48, 6),
  (71, 49, 8),
  (71, 50, 7),
  (71, 52, 8),
  (71, 53, 8),
  (71, 54, 8),
  (71, 55, 9);

-- from country to cqc.Country
drop table if exists migration.country;
create table migration.country (
	tribalid INTEGER NOT NULL,
	sfcid INTEGER NOT NULL
);
insert into migration.country(tribalid, sfcid) values 
  (1, 1),
  (2, 2),
  (3, 3),
  (4, 4),
  (5, 5),
  (6, 6),
  (7, 7),
  (8, 8),
  (9, 9),
  (10, 10),
  (11, 11),
  (12, 12),
  (13, 13),
  (14, 14),
  (15, 15),
  (16, 16),
  (17, 17),
  (18, 18),
  (19, 19),
  (20, 20),
  (21, 21),
  (22, 22),
  (23, 23),
  (24, 24),
  (25, 25),
  (26, 26),
  (27, 27),
  (28, 28),
  (29, 29),
  (30, 30),
  (31, 31),
  (32, 32),
  (33, 33),
  (34, 34),
  (35, 35),
  (36, 36),
  (37, 37),
  (38, 38),
  (39, 39),
  (40, 40),
  (41, 41),
  (42, 42),
  (43, 43),
  (44, 44),
  (45, 45),
  (46, 46),
  (47, 47),
  (48, 48),
  (49, 49),
  (50, 50),
  (51, 51),
  (52, 52),
  (53, 53),
  (54, 54),
  (55, 55),
  (56, 56),
  (57, 57),
  (58, 58),
  (59, 59),
  (60, 60),
  (61, 61),
  (62, 62),
  (63, 63),
  (64, 64),
  (65, 65),
  (66, 66),
  (67, 67),
  (68, 68),
  (69, 69),
  (70, 70),
  (71, 71),
  (72, 72),
  (73, 73),
  (74, 74),
  (75, 75),
  (76, 76),
  (77, 77),
  (78, 78),
  (79, 79),
  (80, 80),
  (81, 81),
  (82, 82),
  (83, 83),
  (84, 84),
  (85, 85),
  (86, 86),
  (87, 87),
  (88, 88),
  (89, 89),
  (90, 90),
  (91, 91),
  (92, 92),
  (93, 93),
  (94, 94),
  (95, 107),
  (96, 108),
  (97, 109),
  (98, 110),
  (99, 111),
  (100, 112),
  (101, 113),
  (102, 114),
  (103, 115),
  (104, 116),
  (105, 117),
  (106, 260),
  (107, 118),
  (108, 119),
  (109, 120),
  (110, 121),
  (111, 122),
  (112, 123),
  (113, 124),
  (114, 125),
  (115, 126),
  (116, 127),
  (117, 128),
  (118, 129),
  (119, 130),
  (120, 261),
  (121, 131),
  (122, 132),
  (123, 133),
  (124, 134),
  (125, 135),
  (126, 136),
  (127, 137),
  (128, 138),
  (129, 139),
  (130, 140),
  (131, 141),
  (132, 142),
  (133, 143),
  (134, 144),
  (135, 145),
  (136, 146),
  (137, 147),
  (138, 148),
  (139, 149),
  (140, 150),
  (141, 151),
  (142, 152),
  (143, 153),
  (144, 154),
  (145, 155),
  (146, 156),
  (147, 157),
  (148, 158),
  (149, 159),
  (150, 160),
  (151, 161),
  (152, 162),
  (153, 163),
  (154, 164),
  (155, 165),
  (156, 166),
  (157, 167),
  (158, 168),
  (159, 169),
  (160, 170),
  (161, 171),
  (162, 172),
  (163, 173),
  (164, 174),
  (165, 175),
  (166, 176),
  (167, 177),
  (168, 178),
  (169, 179),
  (170, 180),
  (171, 181),
  (172, 182),
  (173, 183),
  (174, 184),
  (175, 185),
  (176, 186),
  (177, 187),
  (178, 188),
  (179, 189),
  (180, 190),
  (181, 191),
  (182, 192),
  (183, 193),
  (184, 194),
  (185, 195),
  (186, 196),
  (187, 197),
  (188, 198),
  (189, 199),
  (190, 200),
  (191, 201),
  (192, 202),
  (193, 203),
  (194, 204),
  (195, 205),
  (196, 206),
  (197, 207),
  (198, 208),
  (199, 209),
  (200, 210),
  (201, 211),
  (202, 212),
  (203, 213),
  (204, 214),
  (205, 215),
  (250, 216),
  (206, 217),
  (207, 218),
  (208, 219),
  (209, 220),
  (210, 221),
  (211, 222),
  (212, 223),
  (213, 224),
  (214, 225),
  (215, 226),
  (216, 227),
  (217, 228),
  (218, 229),
  (219, 230),
  (220, 231),
  (221, 232),
  (222, 233),
  (223, 234),
  (224, 235),
  (225, 236),
  (226, 237),
  (227, 238),
  (228, 239),
  (229, 240),
  (230, 241),
  (231, 242),
  (233, 244),
  (234, 245),
  (235, 246),
  (236, 247),
  (237, 248),
  (238, 249),
  (239, 250),
  (240, 251),
  (241, 252),
  (242, 253),
  (243, 254),
  (244, 255),
  (245, 256),
  (246, 257);

-- from country to cqc.Country
drop table if exists migration.recruitedfrom;
create table migration.recruitedfrom (
	tribalid INTEGER NOT NULL,
	sfcid INTEGER NOT NULL
);
insert into migration.recruitedfrom(tribalid, sfcid) values 
  (210, 1), 
  (211, 2), 
  (212, 4), 
  (213, 4), 
  (214, 3), 
  (215, 5), 
  (216, 5), 
  (217, 6), 
  (218, 10), 
  (219, 7), 
  (220, 10), 
  (221, 8), 
  (222, 10), 
  (223, 10), 
  (224, 10);


-- from ethinicity to cqc.Ethnicity
drop table if exists migration.ethnicity;
create table migration.ethnicity (
	tribalid INTEGER NOT NULL,
	sfcid INTEGER NOT NULL
);
insert into migration.ethnicity(tribalid, sfcid) values
  (31, 1),
  (99, 2),
  (32, 3),
  (33, 4),
  (34, 5),
  (35, 6),
  (36, 7),
  (37, 8),
  (38, 9),
  (39, 10),
  (40, 11),
  (41, 12),
  (42, 13),
  (43, 14),
  (44, 15),
  (45, 16),
  (46, 17),
  (47, 18),
  (48, 19);


-- from country to cqc.Nationality
-- note - source "nationality" references the source 'country' table
drop table if exists migration.nationality;
create table migration.nationality (
	tribalid INTEGER NOT NULL,
	sfcid INTEGER NOT NULL
);
insert into migration.nationality(tribalid, sfcid) values 
  (1, 1),
  (2, 73),
  (3, 2),
  (4, 3),
  (5, 4),
  (6, 5),
  (7, 6),
  (8, 7),
  (10, 8),
  (11, 9),
  (12, 10),
  (13, 60),
  (14, 11),
  (15, 12),
  (16, 13),
  (17, 14),
  (18, 15),
  (19, 16),
  (20, 17),
  (21, 18),
  (22, 19),
  (23, 20),
  (24, 21),
  (25, 22),
  (26, 23),
  (27, 24),
  (28, 25),
  (29, 26),
  (31, 27),
  (33, 30),
  (34, 31),
  (35, 32),
  (36, 34),
  (37, 35),
  (38, 36),
  (39, 37),
  (40, 38),
  (41, 39),
  (42, 40),
  (43, 41),
  (44, 42),
  (45, 43),
  (46, 11),
  (47, 11),
  (48, 44),
  (49, 45),
  (50, 46),
  (51, 47),
  (52, 48),
  (53, 49),
  (54, 101),
  (55, 50),
  (56, 51),
  (57, 54),
  (58, 55),
  (59, 56),
  (60, 57),
  (61, 58),
  (62, 59),
  (63, 62),
  (64, 63),
  (65, 170),
  (66, 66),
  (67, 67),
  (68, 68),
  (69, 69),
  (71, 70),
  (72, 71),
  (73, 73),
  (74, 74),
  (75, 74),
  (76, 74),
  (77, 74),
  (78, 75),
  (79, 76),
  (80, 77),
  (81, 78),
  (82, 79),
  (83, 80),
  (84, 81),
  (85, 82),
  (86, 83),
  (87, 74),
  (88, 84),
  (89, 85),
  (91, 87),
  (92, 86),
  (93, 88),
  (94, 89),
  (95, 11),
  (96, 100),
  (97, 90),
  (98, 91),
  (99, 92),
  (100, 93),
  (101, 94),
  (102, 95),
  (103, 96),
  (104, 97),
  (105, 98),
  (107, 99),
  (108, 100),
  (109, 102),
  (110, 103),
  (112, 104),
  (113, 105),
  (114, 106),
  (115, 108),
  (116, 150),
  (117, 186),
  (118, 110),
  (119, 111),
  (120, 112),
  (121, 113),
  (122, 114),
  (123, 140),
  (124, 115),
  (125, 116),
  (126, 117),
  (127, 118),
  (128, 119),
  (129, 120),
  (130, 121),
  (131, 122),
  (132, 123),
  (133, 124),
  (134, 125),
  (135, 126),
  (136, 127),
  (137, 128),
  (138, 129),
  (139, 130),
  (140, 131),
  (141, 74),
  (142, 132),
  (143, 133),
  (144, 134),
  (145, 135),
  (146, 136),
  (147, 137),
  (148, 138),
  (149, 139),
  (150, 141),
  (151, 33),
  (152, 142),
  (153, 143),
  (154, 144),
  (155, 60),
  (156, 60),
  (157, 74),
  (158, 145),
  (159, 146),
  (160, 148),
  (161, 147),
  (162, 149),
  (163, 11),
  (164, 4),
  (165, 152),
  (166, 153),
  (167, 154),
  (168, 155),
  (169, 156),
  (170, 157),
  (171, 158),
  (172, 159),
  (173, 160),
  (174, 72),
  (176, 162),
  (177, 163),
  (178, 165),
  (179, 166),
  (180, 74),
  (181, 167),
  (182, 168),
  (183, 169),
  (184, 74),
  (185, 190),
  (187, 191),
  (188, 74),
  (189, 74),
  (190, 220),
  (191, 172),
  (192, 171),
  (194, 174),
  (195, 176),
  (196, 177),
  (197, 178),
  (198, 179),
  (199, 180),
  (200, 181),
  (201, 182),
  (202, 183),
  (203, 184),
  (204, 185),
  (250, 187),
  (206, 188),
  (207, 189),
  (208, 193),
  (209, 194),
  (210, 152),
  (211, 195),
  (212, 196),
  (213, 197),
  (214, 198),
  (215, 199),
  (216, 200),
  (217, 201),
  (218, 202),
  (220, 203),
  (222, 204),
  (223, 205),
  (224, 207),
  (225, 208),
  (226, 209),
  (227, 210),
  (228, 211),
  (229, 212),
  (230, 213),
  (231, 64),
  (233, 4),
  (234, 4),
  (235, 214),
  (236, 215),
  (237, 217),
  (238, 218),
  (239, 219),
  (241, 4),
  (242, 221),
  (243, 139),
  (244, 223),
  (245, 224),
  (246, 225);

-- from qualification to cqc.Qualifications
drop table if exists migration.qualificationCategories;
create table migration.qualificationCategories (
	tribalid INTEGER NOT NULL,
	sfcid INTEGER NOT NULL
);
insert into migration.qualificationCategories(tribalid, sfcid) values 
  (1, 97),
  (2, 98),
  (3, 96),
  (4, 93),
  (5, 94),
  (6, 95),
  (7, 112),
  (8, 24),
  (9, 99),
  (10, 100),
  (11, 112),
  (12, 25),
  (13, 102),
  (14, 107),
  (15, 106),
  (16, 72),
  (17, 89),
  (18, 71),
  (19, 16),
  (20, 1),
  (21, 112),
  (22, 14),
  (23, 112),
  (24, 112),
  (25, 15),
  (26, 26),
  (27, 114),
  (28, 116),
  (29, 112),
  (30, 112),
  (31, 112),
  (32, 115),
  (33, 113),
  (34, 111),
  (35, 109),
  (36, 110),
  (37, 117),
  (38, 118),
  (39, 119),

  (41, 20),
  (42, 30),
  (43, 28),
  (44, 91),
  (45, 91),
  (46, 91),
  (47, 91),
  (48, 4),
  (49, 5),
  (50, 60),
  (51, 61),
  (52, 10),
  (53, 80),
  (54, 81),
  (55, 82),
  (56, 83),
  (57, 84),
  (58, 85),
  (59, 112),
  (60, 112),
  (61, 112),
  (62, 86),
  (63, 87),
  (64, 88),
  (65, 134),
  (66, 134),
  (67, 21),
  (68, 22),
  (69, 91),
  (70, 91),
  (71, 91),
  (72, 23),
  (73, 32),
  (74, 19),
  (76, 64),
  (77, 65),
  (78, 112),
  (79, 112),
  (80, 112),
  (81, 112),
  (82, 103),
  (83, 104),
  (84, 105),
  (85, 17),
  (86, 2),
  (87, 45),
  (88, 9),
  (89, 69),
  (90, 12),
  (91, 18),
  (92, 130),
  (93, 62),
  (94, 66),
  (95, 67),
  (96, 11),
  (97, 27),
  (98, 59),
  (99, 6),
  (100, 7),
  (101, 101),
  (102, 63),
  (103, 8),
  (104, 75),
  (105, 76),
  (106, 27),
  (107, 3),
  (108, 47),
  (109, 74),
  (110, 31),
  (111, 27),
  (112, 28),
  (113, 134),
  (114, 135),
  (115, 90),
  (116, 91);

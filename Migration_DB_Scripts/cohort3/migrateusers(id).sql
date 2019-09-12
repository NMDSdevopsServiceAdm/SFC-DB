-- FUNCTION: migration.migrateusers(integer)

-- DROP FUNCTION migration.migrateusers(integer);

CREATE OR REPLACE FUNCTION migration.migrateusers(
	estb_id integer)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
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

  OPEN AllUsers FOR select 
cqc."Establishment"."EstablishmentID" AS establishmentid, U."TribalID" AS newuserid, 
  w."CustomDecrypt" AS customdecrypt,
  users.*, establishment_user.*, establishment.telephone as users_telephone
    from
      users
        inner join establishment_user on establishment_user.user_id = users.id
          inner join cqc."Establishment"
            inner join establishment on "Establishment"."TribalID" = establishment.id
            on "Establishment"."TribalID" = establishment_user.establishment_id
                    left join cqc."User" U on U."TribalID" = users.id
					
					left join migration.userwriter w on w."UID"=users.uniqueid and w."Username"=users.lowerusername

    where users.status <> 4
      and establishment_user.establishment_id=estb_id;
/* in (156182, 59, 248, 669, 187078, 215842, 162286, 2533, 295
2, 200560, 225586, 3278, 60682, 5228, 12937, 232842, 10121, 10757, 216264, 12041, 17047, 177958, 136485,
15000, 20876, 233642, 17661, 168369, 40762, 205162, 154806, 42683, 45882, 196119, 85603, 181062, 218926,
196840, 144133, 215263, 170258, 217893, 231842);
*/
  LOOP
  BEGIN
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
       -- "AdminUser",
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
         -- false,
          FullName,
          COALESCE(CurrentUser.jobtitle, 'Empty'),
          CurrentUser.loweremail,
          CurrentUser.users_telephone,
          CurrentUser.passwordquestion,
          CurrentUser.customdecrypt,
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
      -- IF (NewUserRole = 'Read') THEN
      --   SELECT floor(random() * 100 + 1)::int into NewUserRandomNumber;
      --   NewUsername = CONCAT('migration_', NewUserRandomNumber, '_', CurrentUser.lowerusername);
      -- END IF;

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

    EXCEPTION WHEN OTHERS THEN RAISE WARNING 'Skipping user with id: %', CurrentUser.id;
    INSERT INTO "migration"."errorlog"(message,type,value)values(concat(SQLSTATE,'-',SQLERRM),'user', CurrentUser.id);
    raise notice E'Got exception:
	
        SQLSTATE: % 
        SQLERRM: %', SQLSTATE, SQLERRM;     
  END;
  END LOOP;

END;
$BODY$;

ALTER FUNCTION migration.migrateusers(integer)
    OWNER TO postgres;

-- Fixes for Cohort 3
-- Constants moved to top of file in TargetX
-- Constant Targets set from current oraclpg database

CREATE OR REPLACE FUNCTION migration.validate()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  NumberOfUsers INTEGER;
  TargetNumberOfUsers INTEGER := 5582;
  NumberOfReadOnlyLogins INTEGER;
  TargetNumberOfReadOnlyLogins INTEGER :=523;
  NumberOfEditLogins INTEGER;
  TagetNumberOfEditLogins INTEGER := 6176;
  NumberOfEstablishments INTEGER;
  TargetNumberOfEstablishments INTEGER :=5957;
  NumberOfEstablishmentServices INTEGER;
  TargetNumberOfEstablishmentServices INTEGER := 5197;
  NumberOfEstablishmentCapacities INTEGER;
  TargetNumberOfEstablishmentCapacities INTEGER := 12640;
  NumberOfEstablishmentServiceUsers INTEGER;
  TargetNumberOfEstablishmentServiceUsers INTEGER :=28522;
  NumberOfEstablishmentLocalAuthorities INTEGER;
  TagetNumberOfEstablishmentLocalAuthorities INTEGER :=5982;
  NumberOfEstablishmentJobs INTEGER;
  TargetNumberOfEstablishmentJobs INTEGER := 30769;
  NumberOfWorkers INTEGER;
  TargetNumberOfWorkers INTEGER :=270484;
  NumberOfWorkersQualifications INTEGER;
  TargetNumberOfWorkersQualifications INTEGER :=166122;
  NumberOfWorkersTraining INTEGER;
  TagetNumberOfWorkersTraining INTEGER :=1988191;
  NumberOfServiceCapacities INTEGER;
  NumberOfQualifications INTEGER;
  NumberOfQualificationsWithNullLevel INTEGER;
  NumberOfCountries INTEGER;
BEGIN
  select count(0)
  from cqc."Establishment"
--  where "Establishment"."TribalID" in (1,2)
    into NumberOfEstablishments;

  select count(0)
  from cqc."EstablishmentServices"
    inner join cqc."Establishment" on "EstablishmentServices"."EstablishmentID" = "Establishment"."EstablishmentID"
  where "Establishment"."TribalID" in (1,2)
    into NumberOfEstablishmentServices;

  select count(0)
  from cqc."EstablishmentCapacity"
    inner join cqc."Establishment" on "EstablishmentCapacity"."EstablishmentID" = "Establishment"."EstablishmentID"
  where "Establishment"."TribalID" in (1,2)
    into NumberOfEstablishmentCapacities;

  select count(0)
  from cqc."EstablishmentServiceUsers"
    inner join cqc."Establishment" on "EstablishmentServiceUsers"."EstablishmentID" = "Establishment"."EstablishmentID"
  where "Establishment"."TribalID" in (1,2)
    into NumberOfEstablishmentServiceUsers;

  select count(0)
  from cqc."EstablishmentLocalAuthority"
    inner join cqc."Establishment" on "EstablishmentLocalAuthority"."EstablishmentID" = "Establishment"."EstablishmentID"
  where "Establishment"."TribalID" in (1,2)
    into NumberOfEstablishmentLocalAuthorities;

  select count(0)
  from cqc."EstablishmentJobs"
    inner join cqc."Establishment" on "EstablishmentJobs"."EstablishmentID" = "Establishment"."EstablishmentID"
  where "Establishment"."TribalID" in (1,2)
    into NumberOfEstablishmentJobs;

  select count(0)
  from cqc."User"
    inner join cqc."Establishment" on "Establishment"."EstablishmentID" = "User"."EstablishmentID"
  where "Establishment"."TribalID" in (1,2)
    and "User"."TribalPasswordAnswer" IS NOT NULL
    into NumberOfUsers;

  select count(0)
  from cqc."Login"
    inner join cqc."User"
      inner join cqc."Establishment" on "Establishment"."EstablishmentID" = "User"."EstablishmentID"
      on "User"."RegistrationID" = "Login"."RegistrationID"
  where "Establishment"."TribalID" in (1,2)
    and "Login"."TribalHash" is not null
    and "User"."UserRoleValue" = 'Read'
    into NumberOfReadOnlyLogins;

  select count(0)
  from cqc."Login"
    inner join cqc."User"
      inner join cqc."Establishment" on "Establishment"."EstablishmentID" = "User"."EstablishmentID"
      on "User"."RegistrationID" = "Login"."RegistrationID"
  where "Establishment"."TribalID" in (1,2)
    and "Login"."TribalHash" is not null
    and "User"."UserRoleValue" = 'Edit'
    into NumberOfEditLogins;

  select count(0)
  from cqc."Worker"
    inner join cqc."Establishment" on "Worker"."EstablishmentFK" = "Establishment"."EstablishmentID"
  where "Establishment"."TribalID" in (1,2)
    into NumberOfWorkers;

  select count(0)
  from cqc."WorkerTraining"
    inner join cqc."Worker"
      inner join cqc."Establishment" on "Establishment"."EstablishmentID" = "Worker"."EstablishmentFK"
      on "Worker"."ID" = "WorkerTraining"."WorkerFK"
  where "Establishment"."TribalID" in (1,2)
    and "WorkerTraining"."TribalID" IS NOT NULL
    into NumberOfWorkersTraining;

  select count(0)
  from cqc."WorkerQualifications"
    inner join cqc."Worker"
      inner join cqc."Establishment" on "Establishment"."EstablishmentID" = "Worker"."EstablishmentFK"
      on "Worker"."ID" = "WorkerQualifications"."WorkerFK"
  where "Establishment"."TribalID" in (1,2)
    and "WorkerQualifications"."TribalID" IS NOT NULL
    into NumberOfWorkersQualifications;

  IF (NumberOfEstablishments = TargetNumberOfEstablishments) THEN
    RAISE INFO 'Establishment count matches %',TargetNumberOfEstablishments;
  ELSE
    RAISE WARNING 'Establishment count fails match: % target: %', NumberOfEstablishments, TargetNumberOfEstablishments;
  END IF;
  IF (NumberOfEstablishmentServices = TargetNumberOfEstablishmentServices) THEN
    RAISE INFO 'Establishment Services count matches %',TargetNumberOfEstablishmentServices;
  ELSE
    RAISE WARNING 'Establishment Services count fails match: % target: %', NumberOfEstablishmentServices, TargetNumberOfEstablishmentServices;
  END IF;
  IF (NumberOfEstablishmentCapacities = TargetNumberOfEstablishmentCapacities) THEN
    RAISE INFO 'Establishment Capacities count matches %',TargetNumberOfEstablishmentCapacities;
  ELSE
    RAISE WARNING 'Establishment Capacities count fails match: % target: %', NumberOfEstablishmentCapacities, TargetNumberOfEstablishmentCapacities;
  END IF;
  IF (NumberOfEstablishmentServiceUsers = TargetNumberOfEstablishmentServiceUsers) THEN
    RAISE INFO 'Establishment Service Users count matches %',TargetNumberOfEstablishmentServiceUsers;
  ELSE
    RAISE WARNING 'Establishment Service Users count fails match: % target: %', NumberOfEstablishmentServiceUsers, TargetNumberOfEstablishmentServiceUsers;
  END IF;
  IF (NumberOfEstablishmentLocalAuthorities = TargetNumberOfEstablishmentLocalAuthorities) THEN
    RAISE INFO 'Establishment Local Authorities count matches %',TargetNumberOfEstablishmentLocalAuthorities;
  ELSE
    RAISE WARNING 'Establishment Local Authorities count fails match: % target: %', NumberOfEstablishmentLocalAuthorities, TargetNumberOfEstablishmentLocalAuthorities;
  END IF;
  IF (NumberOfEstablishmentJobs = TargetNumberOfEstablishmentJobs) THEN
    RAISE INFO 'Establishment Jobs count matches %',TargetNumberOfEstablishmentJobs;
  ELSE
    RAISE WARNING 'Establishment Jobs count fails match: % target: %', NumberOfEstablishmentJobs, TargetNumberOfEstablishmentJobs;
  END IF;
  IF (NumberOfUsers = TargetNumberOfUsers) THEN
    RAISE INFO 'User count matches %',TargetNumberOfUsers;
  ELSE
    RAISE WARNING 'User count fails match: % target: %', NumberOfUsers, TargetNumberOfUsers;
  END IF;
  IF (NumberOfReadOnlyLogins = TargetNumberOfReadOnlyLogins) THEN
    RAISE INFO 'Read Only Logins count matches %',TargetNumberOfReadOnlyLogins;
  ELSE
    RAISE WARNING 'Read Only Logins count fails match: % target: %', NumberOfReadOnlyLogins, TargetNumberOfReadOnlyLogins;
  END IF;
  IF (NumberOfEditLogins = TargetNumberOfEditLogins) THEN
    RAISE INFO 'Edit Logins count matches %',TargetNumberOfEditLogins;
  ELSE
    RAISE WARNING 'Edit Logins count fails match: % target: %', NumberOfEditLogins, TargetNumberOfEditLogins;
  END IF;
  IF (NumberOfWorkers = TargetNumberOfWorkers) THEN
    RAISE INFO 'Worker count matches %',TargetNumberOfWorkers;
  ELSE
    RAISE WARNING 'Worker count fails match: % target: %', NumberOfWorkers, TargetNumberOfWorkers;
  END IF;
  IF (NumberOfWorkersTraining = TargetNumberOfWorkersTraining) THEN
    RAISE INFO 'Worker Training count matches %',TargetNumberOfWorkersTraining;
  ELSE
    RAISE WARNING 'Worker Training count fails match: % target: %', NumberOfWorkersTraining, TargetNumberOfWorkersTraining;
  END IF;
  IF (NumberOfWorkersQualifications = TargetNumberOfWorkersQualifications) THEN
    RAISE INFO 'Worker Qualifications count matches %',TargetNumberOfEditLogins;
  ELSE
    RAISE WARNING 'Worker Qualifications count fails match: % target: %', NumberOfWorkersQualifications, TargetNumberOfWorkersQualifications;
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
$function$

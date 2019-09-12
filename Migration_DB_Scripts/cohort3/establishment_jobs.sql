-- FUNCTION: migration.establishment_jobs(integer, integer)

-- DROP FUNCTION migration.establishment_jobs(integer, integer);

CREATE OR REPLACE FUNCTION migration.establishment_jobs(
	_tribalid integer,
	_sfcid integer)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
DECLARE
  MyJobs REFCURSOR;
  CurrrentJob RECORD;
  TotalVacancies INTEGER;
  TotalStarters INTEGER;
  TotalLeavers INTEGER;
  TotalStaff INTEGER;
BEGIN
  RAISE NOTICE '... mapping jobs (vacancies, starters and leavers)';

  OPEN MyJobs FOR SELECT
        provision.totalvacancies,
        provision.totalstarters,
        provision.totalleavers,
        "Job"."JobID" AS jobid,
		sum(pjr.permanentstaffcount) AS permanentstaffcount,
		sum(pjr.temporarystaffcount) AS temporarystaffcount,
        sum(pjr.poolstaffcount) AS poolstaffcount,
        sum(pjr.agencystaffcount) AS agencystaffcount,
        sum(pjr.studentstaffcount) AS studentstaffcount,
        sum(pjr.voluntarystaffcount) AS voluntarystaffcount,
        sum(pjr.otherstaffcount) AS otherstaffcount,
        sum(pjr.startedcount) AS startedcount,
        sum(pjr.stoppedcount) AS stoppedcount,
        sum(pjr.vacanciescount) AS vacanciescount,
        sum(pjr.startedcount) AS starters,
        sum(pjr.stoppedcount) AS leavers,
        sum(pjr.vacanciescount) AS vacancies
      FROM establishment
        INNER JOIN provision ON provision.establishment_id = establishment.id
          LEFT JOIN provision_jobrole pjr
            INNER JOIN migration.jobs ms
              INNER JOIN cqc."Job" ON ms.sfcid = "Job"."JobID"
              ON pjr.jobrole = ms.tribalid
            ON pjr.provision_id = provision.id
      WHERE establishment.id =_tribalId
      GROUP BY establishment.id, provision.totalvacancies, provision.totalstarters, provision.totalleavers, "Job"."JobID";

  -- first delete any existing "jobs"
  DELETE FROM cqc."EstablishmentJobs" WHERE "EstablishmentID" = _sfcid;

  -- reset the establishment's sum of total staff
  TotalStaff = 0;

  -- the totals will be the same for every job type record
  TotalVacancies = 0;
  TotalStarters = 0;
  TotalLeavers = 0;
  
  LOOP
    BEGIN
      FETCH MyJobs INTO CurrrentJob;
      EXIT WHEN NOT FOUND;
	
      TotalStaff = TotalStaff +
        CurrrentJob.permanentstaffcount +
        CurrrentJob.temporarystaffcount +
        CurrrentJob.poolstaffcount +
        CurrrentJob.agencystaffcount +
        CurrrentJob.studentstaffcount +
        CurrrentJob.voluntarystaffcount +
        CurrrentJob.otherstaffcount;

      -- note - CurrrentJob.vacanciescount, CurrrentJob.startedcount and CurrrentJob.stoppedcount are never null
      --        and the same CurrentJob could have none, one, two or all three of vacancies, started and stopped counts
      IF (CurrrentJob.vacancies > 0) THEN
        INSERT INTO cqc."EstablishmentJobs" ("EstablishmentID", "JobID", "JobType", "Total")
          VALUES (_sfcid, CurrrentJob.jobid, 'Vacancies', CurrrentJob.vacancies)
          ON CONFLICT DO NOTHING;

        TotalVacancies := TotalVacancies + CurrrentJob.vacancies;
      END IF;

      IF (CurrrentJob.starters > 0) THEN
        INSERT INTO cqc."EstablishmentJobs" ("EstablishmentID", "JobID", "JobType", "Total")
          VALUES (_sfcid, CurrrentJob.jobid, 'Starters', CurrrentJob.starters)
          ON CONFLICT DO NOTHING;

        TotalStarters := TotalStarters + CurrrentJob.starters;
      END IF;
         
      IF (CurrrentJob.leavers > 0) THEN
        INSERT INTO cqc."EstablishmentJobs" ("EstablishmentID", "JobID", "JobType", "Total")
          VALUES (_sfcid, CurrrentJob.jobid, 'Leavers', CurrrentJob.leavers)
          ON CONFLICT DO NOTHING;

        TotalLeavers := TotalLeavers + CurrrentJob.leavers;
      END IF;

      --EXCEPTION WHEN OTHERS THEN RAISE WARNING 'Failed to process Job with target role: % (%) - %', _tribalId, _sfcid, CurrrentJob.jobid;
    END;
  END LOOP;

  -- update the Establishment's Vacancies, Starters and Leavers change properties
  -- if there are no records, then all Vacancies, Starters and Leavers are "Don't know"

  IF (TotalLeavers = 0 AND TotalStarters = 0 AND TotalVacancies = 0) THEN
    RAISE NOTICE '...... don''t know vacancies, starters and leavers';
    UPDATE
      cqc."Establishment"
    SET
      "VacanciesSavedAt" = now(),
      "VacanciesSavedBy" = 'migration',
      "VacanciesValue" = NULL,
      "StartersSavedAt" = now(),
      "StartersSavedBy" = 'migration',
      "StartersValue" = NULL,
      "LeaversSavedAt" = now(),
      "LeaversSavedBy" = 'migration',
      "LeaversValue" = NULL
    WHERE
      "EstablishmentID" = _sfcid;

  ELSE
  
    IF (TotalVacancies = 0) THEN
      RAISE NOTICE '...... have no vacancies';
      UPDATE
        cqc."Establishment"
      SET
        "VacanciesSavedAt" = now(),
        "VacanciesSavedBy" = 'migration',
        "VacanciesValue" = 'None'
      WHERE
        "EstablishmentID" = _sfcid;
    ELSE
      RAISE NOTICE '...... have vacancies';
      UPDATE
        cqc."Establishment"
      SET
        "VacanciesSavedAt" = now(),
        "VacanciesSavedBy" = 'migration',
        "VacanciesValue" = 'With Jobs'
      WHERE
        "EstablishmentID" = _sfcid;
    END IF;

    IF (TotalStarters = 0) THEN
      RAISE NOTICE '...... have no starters';
      UPDATE
        cqc."Establishment"
      SET
        "StartersSavedAt" = now(),
        "StartersSavedBy" = 'migration',
        "StartersValue" = 'None'
      WHERE
        "EstablishmentID" = _sfcid;
    ELSE
      RAISE NOTICE '...... have starters';
      UPDATE
        cqc."Establishment"
      SET
        "StartersSavedAt" = now(),
        "StartersSavedBy" = 'migration',
        "StartersValue" = 'With Jobs'
      WHERE
        "EstablishmentID" = _sfcid;
    END IF;

    IF (TotalLeavers = 0) THEN
      RAISE NOTICE '...... have no leavers';
      UPDATE
        cqc."Establishment"
      SET
        "LeaversSavedAt" = now(),
        "LeaversSavedBy" = 'migration',
        "LeaversValue" = 'None'
      WHERE
        "EstablishmentID" = _sfcid;
    ELSE
      RAISE NOTICE '...... have leavers';
      UPDATE
        cqc."Establishment"
      SET
        "LeaversSavedAt" = now(),
        "LeaversSavedBy" = 'migration',
        "LeaversValue" = 'With Jobs'
      WHERE
        "EstablishmentID" = _sfcid;
    END IF;
  END IF;

  -- update the establishments total number of staff
  UPDATE
    cqc."Establishment"
  SET
    "NumberOfStaffSavedAt" = now(),
    "NumberOfStaffSavedBy" = 'migration',
    "NumberOfStaffValue" = TotalStaff
  WHERE
    "EstablishmentID" = _sfcid;

END;
$BODY$;

ALTER FUNCTION migration.establishment_jobs(integer, integer)
    OWNER TO postgres;

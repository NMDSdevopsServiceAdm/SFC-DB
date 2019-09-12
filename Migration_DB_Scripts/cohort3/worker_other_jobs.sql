-- FUNCTION: migration.worker_other_jobs(integer, integer)

-- DROP FUNCTION migration.worker_other_jobs(integer, integer);

CREATE OR REPLACE FUNCTION migration.worker_other_jobs(
	_tribalid integer,
	_sfcid integer)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
DECLARE
  MyOtherJobs REFCURSOR;
  CurrrentOtherJob RECORD;
  TotalOtherJobs INTEGER;
BEGIN
  RAISE NOTICE '... mapping other jobs';
  
  OPEN MyOtherJobs FOR SELECT jobs.sfcid AS sfcid, worker_otherjobrole.otherdescription AS other
  FROM worker_provision
    inner join worker_otherjobrole
      INNER JOIN migration.jobs ON jobs.tribalid=worker_otherjobrole.jobrole
      on worker_otherjobrole.worker_id=worker_provision.worker_id
  WHERE worker_provision.worker_id = _tribalId;

  -- first delete any existing "other jobs"
  RAISE NOTICE '.... deleting existing other jobs: WorkerFK - %', _sfcid;
  DELETE FROM cqc."WorkerJobs" WHERE "WorkerFK" = _sfcid;

  LOOP
    BEGIN
      FETCH MyOtherJobs INTO CurrrentOtherJob;
      EXIT WHEN NOT FOUND;
	  
	  RAISE NOTICE '... mapping other jobs: %', CurrrentOtherJob.sfcid;

      INSERT INTO cqc."WorkerJobs" ("WorkerFK", "JobFK","Other")
        VALUES (_sfcid, CurrrentOtherJob.sfcid,CurrrentOtherJob.other)
        ON CONFLICT DO NOTHING;

      EXCEPTION WHEN OTHERS THEN RAISE WARNING 'Failed to process other jobs: % (%)', _tribalId, _sfcid;
    END;
  END LOOP;

  -- update the Worker's OtherServices change property
  SELECT count(0) FROM cqc."WorkerJobs" WHERE "WorkerFK" = _sfcid INTO TotalOtherJobs;

  IF (TotalOtherJobs > 0) THEN
    UPDATE
      cqc."Worker"
    SET
      "OtherJobsValue" = 'Yes'::cqc."WorkerOtherJobs",
      "OtherJobsSavedAt" = now(),
      "OtherJobsSavedBy" = 'migration'
    WHERE
      "ID" = _sfcid;
  ELSE
    UPDATE
      cqc."Worker"
    SET
      "OtherJobsValue" = 'No'::cqc."WorkerOtherJobs",
      "OtherJobsSavedAt" = now(),
      "OtherJobsSavedBy" = 'migration'
    WHERE
      "ID" = _sfcid;
  END IF;
  
  END;
$BODY$;

ALTER FUNCTION migration.worker_other_jobs(integer, integer)
    OWNER TO postgres;

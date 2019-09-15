-- https://trello.com/c/ahBZTUMC
DROP FUNCTION IF EXISTS cqc.maxQualifications;
CREATE OR REPLACE FUNCTION cqc.maxQualifications(primaryEstablishmentId INTEGER)
RETURNS BIGINT
AS $$
DECLARE
  MAX_QUALS BIGINT := 0;
BEGIN
  SELECT max("NumberOfQuals") AS "MaximumNumberOfQualifications"
  FROM (
    SELECT
      "WorkerFK", count("WorkerQualifications"."ID") AS "NumberOfQuals"
    FROM
      cqc."Establishment"
        INNER JOIN cqc."Worker"
          INNER JOIN cqc."WorkerQualifications" ON "WorkerQualifications"."WorkerFK" = "Worker"."ID"
          ON "Worker"."EstablishmentFK" = "Establishment"."EstablishmentID"
    WHERE
        "Establishment"."EstablishmentID" = primaryEstablishmentId OR ("Establishment"."ParentID" = primaryEstablishmentId AND "Establishment"."DataOwner"='Parent' AND "Establishment"."Archived" = false)
      AND "Worker"."Archived"=false
    GROUP BY
      "WorkerFK"
  ) AllQuals INTO MAX_QUALS;

  -- a minimum always of 3
  IF MAX_QUALS IS NULL OR MAX_QUALS < 3 THEN
    MAX_QUALS := 3;
  END IF;

  return MAX_QUALS;

END; $$
LANGUAGE 'plpgsql';

-- for sfcdevdb, sfctstdb
--ALTER FUNCTION cqc.maxQualifications(INTEGER) OWNER TO sfcadmin;

--select cqc.maxQualifications(30::INTEGER);

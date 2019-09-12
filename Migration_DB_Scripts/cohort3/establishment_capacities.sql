-- FUNCTION: migration.establishment_capacities(integer, integer)

-- DROP FUNCTION migration.establishment_capacities(integer, integer);

CREATE OR REPLACE FUNCTION migration.establishment_capacities(
	_tribalid integer,
	_sfcid integer)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
DECLARE
  MyCapacities REFCURSOR;
  CurrrentCapacityService RECORD;
  TargetCapacities REFCURSOR;
  TargetTotalCapacityRecord RECORD;
  TargetUtilisationRecord RECORD;
  TotalCapacities INTEGER;
BEGIN
  RAISE NOTICE '... mapping capacities';

  -- first delete any existing "capacities"
  DELETE FROM cqc."EstablishmentCapacity" WHERE "EstablishmentID" = _sfcid;

  RAISE NOTICE 'CurrrentCapacityService: %', CurrrentCapacityService;

  INSERT INTO cqc."EstablishmentCapacity" ("EstablishmentID", "ServiceCapacityID","Answer") (
	select DISTINCT _sfcid,servicecapacityid,answer from (
		SELECT e.id,ms.sfcid, pst.totalcapacity, pst.currentutilisation,cap.capacityType,cap.questionsequence,cap.servicecapacityid,
		case WHEN capacitytype = 'Capacity' THEN pst.totalcapacity ELSE pst.currentutilisation END as answer
			FROM establishment e
			  INNER JOIN provision p
				INNER JOIN provision_servicetype pst
				  INNER JOIN migration.services ms ON pst.servicetype_id = ms.tribalid
				  ON pst.provision_id = p.id
				ON p.establishment_id = e.id
			
			JOIN (
			SELECT
				  "ServiceCapacityID" servicecapacityid,
				  "ServiceID" AS serviceid,
				  "Question" as question,
				  "Sequence" as questionsequence,
				  "Type" as capacityType
				FROM cqc."ServicesCapacity"
				ORDER BY questionsequence) as cap on cap.serviceid = ms.sfcid
		order by 1,2,6
	) as changes
	where answer is not null
	  AND id NOT in (select "TribalID" from migration.excludecapability)
	  AND id=_tribalId
  );
--  ON CONFLICT DO NOTHING;

  -- update the Establishment's OtherServices change property
  SELECT count(0) FROM cqc."EstablishmentCapacity" WHERE "EstablishmentID" = _sfcid INTO TotalCapacities;
  IF (TotalCapacities > 0) THEN
    UPDATE
      cqc."Establishment"
    SET
      "CapacityServicesSavedAt" = now(),
      "CapacityServicesSavedBy" = 'migration'
    WHERE
      "EstablishmentID" = _sfcid;
  END IF;
END;
$BODY$;

ALTER FUNCTION migration.establishment_capacities(integer, integer)
    OWNER TO postgres;
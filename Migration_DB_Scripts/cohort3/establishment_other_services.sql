-- FUNCTION: migration.establishment_other_services(integer, integer)

-- DROP FUNCTION migration.establishment_other_services(integer, integer);

CREATE OR REPLACE FUNCTION migration.establishment_other_services(
	_tribalid integer,
	_sfcid integer)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
DECLARE
  MyOtherServices REFCURSOR;
  CurrrentOtherService RECORD;
  TotalOtherServices INTEGER;
BEGIN
  RAISE NOTICE '... mapping other services';

  -- now add any "other services"
  OPEN MyOtherServices FOR SELECT ms.sfcid
    FROM establishment e
      INNER JOIN provision p
        INNER JOIN provision_servicetype pst INNER JOIN migration.services ms ON pst.servicetype_id = ms.tribalid
          ON pst.provision_id = p.id and pst.ismainservice = 0
        ON p.establishment_id = e.id
    WHERE e.id=_tribalId;

  -- first delete any existing "other services"
  DELETE FROM cqc."EstablishmentServices" WHERE "EstablishmentID" = _sfcid;

  LOOP
    BEGIN
      FETCH MyOtherServices INTO CurrrentOtherService;
      EXIT WHEN NOT FOUND;

      INSERT INTO cqc."EstablishmentServices" ("EstablishmentID", "ServiceID")
        VALUES (_sfcid, CurrrentOtherService.sfcid)
        ON CONFLICT DO NOTHING;

      --EXCEPTION WHEN OTHERS THEN RAISE WARNING 'Failed to process other services: % (%)', _tribalId, _sfcid;
    END;
  END LOOP;

  -- update the Establishment's OtherServices change property
  SELECT count(0) FROM cqc."EstablishmentServices" WHERE "EstablishmentID" = _sfcid INTO TotalOtherServices;
  IF (TotalOtherServices > 0) THEN
    UPDATE
      cqc."Establishment"
    SET
      "OtherServicesSavedAt" = now(),
      "OtherServicesSavedBy" = 'migration'
    WHERE
      "EstablishmentID" = _sfcid;
  END IF;
END;
$BODY$;

ALTER FUNCTION migration.establishment_other_services(integer, integer)
    OWNER TO postgres;

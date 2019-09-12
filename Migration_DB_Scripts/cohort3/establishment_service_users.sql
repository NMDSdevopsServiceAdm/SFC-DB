-- FUNCTION: migration.establishment_service_users(integer, integer)

-- DROP FUNCTION migration.establishment_service_users(integer, integer);

CREATE OR REPLACE FUNCTION migration.establishment_service_users(
	_tribalid integer,
	_sfcid integer)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
DECLARE
  MyServiceUsers REFCURSOR;
  CurrrentServiceUser RECORD;
  TotalServiceUsers INTEGER;
BEGIN
  RAISE NOTICE '... mapping service users';

  -- now add any "other services"
  OPEN MyServiceUsers FOR SELECT distinct(ms.sfcid)
    FROM establishment e
      INNER JOIN provision p
        inner join provision_usertype
          inner join usertype
            inner join migration.serviceusers ms on ms.tribalid = usertype.id
            on usertype.id = provision_usertype.usertype_id
          on provision_usertype.provision_id = p.id
        ON p.establishment_id = e.id
    WHERE e.id=_tribalId;

  -- first delete any existing "service users"
  DELETE FROM cqc."EstablishmentServiceUsers" WHERE "EstablishmentID" = _sfcid;

  LOOP
    BEGIN
      FETCH MyServiceUsers INTO CurrrentServiceUser;
      EXIT WHEN NOT FOUND;

      INSERT INTO cqc."EstablishmentServiceUsers" ("EstablishmentID", "ServiceUserID")
        VALUES (_sfcid, CurrrentServiceUser.sfcid)
        ON CONFLICT DO NOTHING;

      --EXCEPTION WHEN OTHERS THEN RAISE WARNING 'Failed to process service users: % (%)', _tribalId, _sfcid;
    END;
  END LOOP;

  -- update the Establishment's ServiceUsers change property
  SELECT count(0) FROM cqc."EstablishmentServiceUsers" WHERE "EstablishmentID" = _sfcid INTO TotalServiceUsers;
  IF (TotalServiceUsers > 0) THEN
    UPDATE
      cqc."Establishment"
    SET
      "ServiceUsersSavedAt" = now(),
      "ServiceUsersSavedBy" = 'migration'
    WHERE
      "EstablishmentID" = _sfcid;
  END IF;
END;
$BODY$;

ALTER FUNCTION migration.establishment_service_users(integer, integer)
    OWNER TO postgres;

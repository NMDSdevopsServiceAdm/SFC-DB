-- FUNCTION: migration.generate_uuid()

-- DROP FUNCTION migration.generate_uuid();

CREATE OR REPLACE FUNCTION migration.generate_uuid(
	)
    RETURNS uuid
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
DECLARE
  new_uid UUID;
BEGIN
  new_uid := (SELECT CAST(substr(CAST(MyUUID."UID" AS TEXT), 0, 15) || '4' || substr(CAST(MyUUID."UID" AS TEXT), 16, 3) || '-89' || substr(CAST(MyUUID."UID" AS TEXT), 22, 36) AS UUID) "UIDv4"
    FROM (SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) AS "UID") AS MyUUID);
  return new_uid;
END;
$BODY$;

ALTER FUNCTION migration.generate_uuid()
    OWNER TO postgres;

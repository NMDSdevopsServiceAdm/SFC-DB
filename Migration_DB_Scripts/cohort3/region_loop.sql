CREATE OR REPLACE PROCEDURE migration.region_loop (
	migrationregion character,
	n integer DEFAULT 30
)
    LANGUAGE 'plpgsql'

AS $BODY$
DECLARE
	counter integer := 0;
BEGIN
	RAISE NOTICE 'Region % (% times)', migrationregion, n;

	FOR counter IN 1..n LOOP
   		RAISE NOTICE 'Counter: %', counter;
		CALL migration.migrate_by_region(migrationregion);
		COMMIT;
	END LOOP;
END;
$BODY$;

ALTER PROCEDURE migration.region_loop(character, integer) OWNER TO postgres;
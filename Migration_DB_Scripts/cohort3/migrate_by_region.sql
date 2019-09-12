-- PROCEDURE: migration.migrate_by_region(character)

-- DROP PROCEDURE migration.migrate_by_region(character);

CREATE OR REPLACE PROCEDURE migration.migrate_by_region(
	migrateregion character)
LANGUAGE 'plpgsql'

AS $BODY$
DECLARE
	RegionTribalIds  REFCURSOR;
	currentestbid record;
	counter integer := 0;

BEGIN
OPEN RegionTribalIds for 
	select tribalid
	from migration.migration_dataset
	where region = migrateregion
	  and completed IS NULL
	limit 100;
LOOP
	BEGIN
	FETCH RegionTribalIds INTO currentestbid;
		EXIT WHEN NOT FOUND;
		RAISE NOTICE 'Processing tribal establishment: %(%)', migrateregion, currentestbid.tribalid;
		
		PERFORM  migration.MigrateEstablishments(currentestbid.tribalid);
		PERFORM  migration.MigrateUsers(currentestbid.tribalid);
		PERFORM  migration.MigrateWorkers(currentestbid.tribalid);
		PERFORM  migration.worker_bulk_training(currentestbid.tribalid);
		PERFORM  migration.worker_bulk_qualifications(currentestbid.tribalid);
		
		update migration.migration_dataset set completed=now() where tribalid=currentestbid.tribalid;
	END;
END LOOP;

END;
$BODY$;

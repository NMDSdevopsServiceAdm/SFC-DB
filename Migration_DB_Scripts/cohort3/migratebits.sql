-- PROCEDURE: migration.migratebits()

-- DROP FUNCTION migration.migratebits();

-- Top level function to trigger migration of Establishments and all sub-elements.
-- RUN with call migration.migratebits();

CREATE OR REPLACE PROCEDURE migration.migratebits(
	)
 LANGUAGE plpgsql
AS $BODY$
DECLARE
increment INTEGER := 500;
BEGIN

truncate migration.errorlog;
truncate migration.runlog;

FOR loop_counter IN 0..20000 by increment LOOP
    raise NOTICE 'Establishments %',loop_counter;
    PERFORM migration.loop_estbid(increment,loop_counter);
	COMMIT;
END LOOP;

FOR loop_counter IN 0..20000 by increment LOOP
    raise NOTICE 'Users %',loop_counter;
    PERFORM migration.loop_estbid_users(increment,loop_counter);
	COMMIT;
END LOOP;

FOR loop_counter IN 0..20000 by increment LOOP
    raise NOTICE 'Workers %',loop_counter;
    PERFORM migration.loop_estbid_migrateworkers(increment,loop_counter);
	COMMIT;
END LOOP;

FOR loop_counter IN 0..20000 by increment LOOP
    raise NOTICE 'Training %',loop_counter;
    PERFORM migration.loop_estbid_worker_bulk_training(increment,loop_counter);
	COMMIT;
END LOOP;

FOR loop_counter IN 0..20000 by increment LOOP
    raise NOTICE 'Qualifications %',loop_counter;
    PERFORM migration.loop_estbid_worker_bulk_qualifications(increment,loop_counter);
	COMMIT;
END LOOP;

	PERFORM migration.setparents();
	COMMIT;

END;
$BODY$;

ALTER PROCEDURE migration.migratebits()
    OWNER TO postgres;

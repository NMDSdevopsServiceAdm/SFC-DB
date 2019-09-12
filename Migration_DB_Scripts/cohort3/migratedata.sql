-- PROCEDURE: migration.migratedata()

-- DROP FUNCTION migration.migratedata();

-- Top level function to trigger migration of Establishments and all sub-elements.
-- RUN with call migration.migratedata();

CREATE OR REPLACE PROCEDURE migration.migratedata(
 offsetValue integer DEFAULT 0,
 limitValue integer DEFAULT 20000,
 increment INTEGER DEFAULT  500,
 resetLogs boolean DEFAULT true,
-- doFixDuplicates boolean DEFAULT true,
 doEstablishments boolean DEFAULT true,
 doUsers boolean DEFAULT true,
 doWorkers boolean DEFAULT true,
 doTraining boolean DEFAULT true,
 doQualifications boolean DEFAULT true,
 doParents boolean DEFAULT true)
 LANGUAGE plpgsql
AS $BODY$
DECLARE
BEGIN

	IF resetLogs THEN
		truncate migration.errorlog;
		truncate migration.runlog;
	END IF;

--    IF doFixDuplicates THEN
--		PERFORM migration.fix_duplicates();
--		COMMIT;
--	END IF;
	
	IF doEstablishments THEN
		FOR loop_counter IN offsetValue..limitValue by increment LOOP
			raise NOTICE 'Establishments %',loop_counter;
			PERFORM migration.loop_estbid(increment,loop_counter);
			COMMIT;
		END LOOP;
	END IF;

	IF doUsers THEN
		FOR loop_counter IN offsetValue..limitValue by increment LOOP
			raise NOTICE 'Users %',loop_counter;
			PERFORM migration.loop_estbid_users(increment,loop_counter);
			COMMIT;
		END LOOP;
	END IF;

	IF doWorkers THEN
		FOR loop_counter IN offsetValue..limitValue by increment LOOP
			raise NOTICE 'Workers %',loop_counter;
			PERFORM migration.loop_estbid_migrateworkers(increment,loop_counter);
			COMMIT;
		END LOOP;
	END IF;

	IF doTraining THEN
		FOR loop_counter IN offsetValue..limitValue by increment LOOP
			raise NOTICE 'Training %',loop_counter;
			PERFORM migration.loop_estbid_worker_bulk_training(increment,loop_counter);
			COMMIT;
		END LOOP;
	END IF;

	IF doQualifications THEN
		FOR loop_counter IN offsetValue..limitValue by increment LOOP
			raise NOTICE 'Qualifications %',loop_counter;
			PERFORM migration.loop_estbid_worker_bulk_qualifications(increment,loop_counter);
			COMMIT;
		END LOOP;
	END IF;

	IF doParents THEN
		PERFORM migration.setparents();
		COMMIT;
	END IF;

END;
$BODY$;

ALTER PROCEDURE migration.migratedata(integer,integer,integer,boolean,boolean,boolean,boolean,boolean,boolean,boolean,boolean)
    OWNER TO postgres;

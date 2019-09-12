-- FUNCTION: migration.loop_estbid(integer)

-- DROP FUNCTION migration.loop_estbid(integer);

CREATE OR REPLACE FUNCTION migration.loop_estbid_migrateworkers(
	n integer DEFAULT 100,
	o integer DEFAULT 0)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
DECLARE
        Allestbid  REFCURSOR;
        currentestbid record;
Begin 

INSERT INTO "migration"."runlog"(item,limitvalue,offsetvalue,created)values('loop_estbid_migrateworkers', n,o,now());

OPEN Allestbid  for 
        select id from establishment where nmdsid NOT in ('I149087','I338116','I275445','C307782','E302906','E70709','F325118','F90206','F326717','B105527','B10061','B244811','B10266','H14159','J226329','G260465','J109433','J323989','D129187','D131148','H301826','H174268','F134367','D270265','G332039','I336693','F90545','G258595','J106120','C30134','E252431','G11736','H14334','I234058','H337555','D324655','I285465','C313126','J17467','J100098','H327419','C30725')
		order by isparent desc, 1 asc limit n offset o
;
Loop
Begin
FETCH Allestbid INTO currentestbid;
 EXIT WHEN NOT FOUND;

PERFORM  migration.MigrateWorkers(currentestbid.id);            
    --UPDATE loop_test SET looped = TRUE WHERE id = _id;
--  RAISE NOTICE ' %', currentestbid.id;
--commit;
END;
        END LOOP;
END;
$BODY$;

ALTER FUNCTION migration.loop_estbid_migrateworkers(integer,integer)
    OWNER TO postgres;

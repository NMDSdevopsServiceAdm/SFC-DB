-- FUNCTION: migration.loop_estbid_users(integer)

-- DROP FUNCTION migration.loop_estbid_users(integer);

CREATE OR REPLACE FUNCTION migration.loop_estbid_users(
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

INSERT INTO "migration"."runlog"(item,limitvalue,offsetvalue,created)values('loop_estbid_users', n,o,now());

OPEN Allestbid  for 
select id 
from establishment e
--from establishment_user u
--join establishment e on e.id=u.establishment_id
  where id not in  (156182, 59, 248, 669, 187078, 215842, 162286, 2533, 2952, 200560, 225586, 3278, 60682, 5228, 12937, 232842, 10121, 10757, 216264, 12041, 17047, 177958, 136485,
    15000, 20876, 233642, 17661, 168369, 40762, 205162, 154806, 42683, 45882, 196119, 85603, 181062, 218926, 196840, 144133, 215263, 170258, 217893, 231842)
  order by isparent desc, 1 asc limit n offset o;
Loop
Begin
FETCH Allestbid INTO currentestbid;
 EXIT WHEN NOT FOUND;

PERFORM  migration.MigrateUsers(currentestbid.id);            
--  RAISE NOTICE ' %', current_establishment_id.id;
END;
        END LOOP;
END;
$BODY$;

ALTER FUNCTION migration.loop_estbid_users(integer,integer)
    OWNER TO postgres;

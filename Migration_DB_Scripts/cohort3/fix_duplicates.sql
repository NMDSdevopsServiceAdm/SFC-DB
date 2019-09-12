-- FUNCTION: migration.fix_duplicates()

-- DROP FUNCTION migration.fix_duplicates();

CREATE OR REPLACE FUNCTION migration.fix_duplicates(
	)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
DECLARE
BEGIN

update establishment
set name=uniquename
from (
select id,name,concat(name,'-',row_number() over ()) uniquename,postcode
from establishment where (name,postcode) in (
select name,postcode from (
select e.name as name,postcode,count(*)
from establishment e
left join provision p
inner join provision_servicetype pst
inner join migration.services ms on pst.servicetype_id = ms.tribalid
on pst.provision_id = p.id and pst.ismainservice = 1
on p.establishment_id = e.id
where locationid is null
group by e.name,postcode
) as X
where count>1
)) Y
WHERE establishment.id = Y.id;

update establishment
set localidentifier=uniquelocalidentifier
from (
select id,localidentifier,concat(localidentifier,'-',row_number() over ()) as uniquelocalidentifier
from establishment where (localidentifier) in
(
select localidentifier from (
select localidentifier,count(*) from
(select localidentifier,length(localidentifier)
from establishment
where localidentifier is not null) as X
group by localidentifier) as Y
where count>1
)) Z
WHERE establishment.id=Z.id;

END;
$BODY$;

ALTER FUNCTION migration.fix_duplicates()
    OWNER TO postgres;

--\i ../create_db_ddl.sql`

-- Tst implementation for 


CREATE SCHEMA cqcref
    AUTHORIZATION sfcadmin;

alter table cqc.pcodedata set schema cqcref;
alter table cqc.location set schema cqcref;


DROP SCHEMA cqctst cascade;
DROP SCHEMA cqctsttst cascade;
DROP SCHEMA sfcfuldata cascade;


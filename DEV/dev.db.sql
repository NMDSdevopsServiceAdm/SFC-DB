--\i ../create_db_ddl.sql

--Creating cqcref schema and removing the unused schema's.
CREATE SCHEMA cqcref
    AUTHORIZATION sfcadmin;

alter table cqc.pcodedata set schema cqcref;
alter table cqc.location set schema cqcref;


DROP SCHEMA cqctst cascade;
DROP SCHEMA cqctsttst cascade;


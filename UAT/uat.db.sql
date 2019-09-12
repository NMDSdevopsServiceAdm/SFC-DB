--\i ../create_db_ddl.sql
-- creat cqcref schema and move the pcodedata and loction table into cqcref schema from cqc schema
CREATE SCHEMA cqcref
    AUTHORIZATION sfcadmin;

alter table cqc.pcodedata set schema cqcref;
alter table cqc.location set schema cqcref;



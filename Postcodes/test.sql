----------------
BEGIN TRANSACTION;

-------------------
-- Turn timing on so we can see how long it took
-------------------
\timing

-------------------
-- Create a temp table, "location-backup"
-------------------
DROP TABLE IF EXISTS cqcref."location-backup";
CREATE TABLE cqcref."location-backup"
(
    locationid text COLLATE pg_catalog."default" NOT NULL,
    locationname text COLLATE pg_catalog."default",
    addressline1 text COLLATE pg_catalog."default",
    addressline2 text COLLATE pg_catalog."default",
    towncity text COLLATE pg_catalog."default",
    county text COLLATE pg_catalog."default",
    postalcode text COLLATE pg_catalog."default",
    mainservice text COLLATE pg_catalog."default",
    createdat timestamp without time zone NOT NULL,
    updatedat timestamp without time zone,
    archived boolean NOT NULL DEFAULT false,
    provid text COLLATE pg_catalog."default",
    locationtype text COLLATE pg_catalog."default",
    CONSTRAINT locationid2_pk PRIMARY KEY (locationid),
    CONSTRAINT locationid2_unq UNIQUE (locationid),
    CONSTRAINT uniqlocationid2 UNIQUE (locationid)
)
TABLESPACE pg_default;
ALTER TABLE cqcref."location-backup"
    OWNER to sfcadmin;


-------------------
-- Restore backed-up postcode data into pcodedata_new
-- !! Edit the path to the dump file !!
-- !! In Windows Terminal you need to use forward slashes in your path, and surround in single quotes !!
-- !! This assumes you've edited your dump file to reference a table called "pcodedata_new" instead of pcodedata
-------------------
\i 'C:/skills-for-care/postcodes/location-preprod-backup.dmp';

END TRANSACTION;
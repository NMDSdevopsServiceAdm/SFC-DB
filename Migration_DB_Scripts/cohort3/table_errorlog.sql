-- Table: migration.errorlog

-- DROP TABLE migration.errorlog;

CREATE TABLE migration.errorlog
(
    message text COLLATE pg_catalog."default",
    type character varying(30) COLLATE pg_catalog."default",
    value integer
)
WITH (
    OIDS = FALSE
)
TABLESPACE oracle_data;

ALTER TABLE migration.errorlog
    OWNER to postgres;
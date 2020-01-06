BEGIN TRANSACTION;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "LocationIdSavedAt" timestamp with time zone;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "LocationIdChangedAt" timestamp with time zone;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "LocationIdSavedBy" character varying(120) COLLATE pg_catalog."default";

ALTER TABLE cqc."Establishment"
    ADD COLUMN "LocationIdChangedBy" character varying(120) COLLATE pg_catalog."default";

END TRANSACTION;
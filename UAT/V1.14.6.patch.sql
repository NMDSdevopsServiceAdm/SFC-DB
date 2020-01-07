BEGIN TRANSACTION;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "LocationIdSavedAt" timestamp with time zone;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "LocationIdChangedAt" timestamp with time zone;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "LocationIdSavedBy" character varying(120) COLLATE pg_catalog."default";

ALTER TABLE cqc."Establishment"
    ADD COLUMN "LocationIdChangedBy" character varying(120) COLLATE pg_catalog."default";

ALTER TABLE cqc."Establishment"
    ADD COLUMN "Address1SavedAt" timestamp with time zone;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "Address1ChangedAt" timestamp with time zone;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "Address1SavedBy" character varying(120) COLLATE pg_catalog."default";

ALTER TABLE cqc."Establishment"
    ADD COLUMN "Address1ChangedBy" character varying(120) COLLATE pg_catalog."default";

ALTER TABLE cqc."Establishment"
    ADD COLUMN "Address2SavedAt" timestamp with time zone;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "Address2ChangedAt" timestamp with time zone;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "Address2SavedBy" character varying(120) COLLATE pg_catalog."default";

ALTER TABLE cqc."Establishment"
    ADD COLUMN "Address2ChangedBy" character varying(120) COLLATE pg_catalog."default";

ALTER TABLE cqc."Establishment"
    ADD COLUMN "Address3SavedAt" timestamp with time zone;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "Address3ChangedAt" timestamp with time zone;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "Address3SavedBy" character varying(120) COLLATE pg_catalog."default";

ALTER TABLE cqc."Establishment"
    ADD COLUMN "Address3ChangedBy" character varying(120) COLLATE pg_catalog."default";

ALTER TABLE cqc."Establishment"
    ADD COLUMN "TownSavedAt" timestamp with time zone;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "TownChangedAt" timestamp with time zone;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "TownSavedBy" character varying(120) COLLATE pg_catalog."default";

ALTER TABLE cqc."Establishment"
    ADD COLUMN "TownChangedBy" character varying(120) COLLATE pg_catalog."default";

ALTER TABLE cqc."Establishment"
    ADD COLUMN "CountySavedAt" timestamp with time zone;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "CountyChangedAt" timestamp with time zone;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "CountySavedBy" character varying(120) COLLATE pg_catalog."default";

ALTER TABLE cqc."Establishment"
    ADD COLUMN "CountyChangedBy" character varying(120) COLLATE pg_catalog."default";

END TRANSACTION;
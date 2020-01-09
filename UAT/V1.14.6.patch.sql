SET SEARCH_PATH TO cqc;

BEGIN TRANSACTION;

ALTER TABLE "Establishment"
ADD COLUMN "LocationIdSavedAt"   timestamp with time zone,
ADD COLUMN "LocationIdChangedAt" timestamp with time zone,
ADD COLUMN "LocationIdSavedBy"   character varying(120) COLLATE pg_catalog."default",
ADD COLUMN "LocationIdChangedBy" character varying(120) COLLATE pg_catalog."default",
ADD COLUMN "Address1SavedAt"     timestamp with time zone,
ADD COLUMN "Address1ChangedAt"   timestamp with time zone,
ADD COLUMN "Address1SavedBy"     character varying(120) COLLATE pg_catalog."default",
ADD COLUMN "Address1ChangedBy"   character varying(120) COLLATE pg_catalog."default",
ADD COLUMN "Address2SavedAt"     timestamp with time zone,
ADD COLUMN "Address2ChangedAt"   timestamp with time zone,
ADD COLUMN "Address2SavedBy"     character varying(120) COLLATE pg_catalog."default",
ADD COLUMN "Address2ChangedBy"   character varying(120) COLLATE pg_catalog."default",
ADD COLUMN "Address3SavedAt"     timestamp with time zone,
ADD COLUMN "Address3ChangedAt"   timestamp with time zone,
ADD COLUMN "Address3SavedBy"     character varying(120) COLLATE pg_catalog."default",
ADD COLUMN "Address3ChangedBy"   character varying(120) COLLATE pg_catalog."default",
ADD COLUMN "TownSavedAt"         timestamp with time zone,
ADD COLUMN "TownChangedAt"       timestamp with time zone,
ADD COLUMN "TownSavedBy"         character varying(120) COLLATE pg_catalog."default",
ADD COLUMN "TownChangedBy"       character varying(120) COLLATE pg_catalog."default",
ADD COLUMN "CountySavedAt"       timestamp with time zone,
ADD COLUMN "CountyChangedAt"     timestamp with time zone,
ADD COLUMN "CountySavedBy"       character varying(120) COLLATE pg_catalog."default",
ADD COLUMN "CountyChangedBy"     character varying(120) COLLATE pg_catalog."default",
ADD COLUMN "PostcodeSavedAt"     timestamp with time zone,
ADD COLUMN "PostcodeChangedAt"   timestamp with time zone,
ADD COLUMN "PostcodeSavedBy"     character varying(120) COLLATE pg_catalog."default",
ADD COLUMN "PostcodeChangedBy"   character varying(120) COLLATE pg_catalog."default";

END TRANSACTION;

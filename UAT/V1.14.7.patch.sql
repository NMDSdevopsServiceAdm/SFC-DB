BEGIN TRANSACTION;

ALTER TABLE cqc."Worker"
ADD COLUMN "EstablishmentFkSavedAt" timestamp with time zone,
ADD COLUMN "EstablishmentFkChangedAt" timestamp with time zone,
ADD COLUMN "EstablishmentFkSavedBy" character varying(120) COLLATE pg_catalog."default",
ADD COLUMN "EstablishmentFkChangedBy" character varying(120) COLLATE pg_catalog."default";

END TRANSACTION;
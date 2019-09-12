-- Establishment auditing - https://trello.com/c/jaqBQdQg
ALTER TABLE cqc."Establishment" ADD COLUMN created timestamp without time zone NOT NULL DEFAULT now();
ALTER TABLE cqc."Establishment" ADD COLUMN updated timestamp without time zone NOT NULL DEFAULT now();
ALTER TABLE cqc."Establishment" ADD COLUMN updatedby character varying(120) COLLATE pg_catalog."default" NOT NULL DEFAULT 'admin';

CREATE TYPE cqc."EstablishmentAuditChangeType" AS ENUM (
    'created',
    'updated',
    'saved',
    'changed',
    'deleted'
);
CREATE TABLE IF NOT EXISTS cqc."EstablishmentAudit" (
    "ID" SERIAL NOT NULL PRIMARY KEY,
    "EstablishmentFK" INTEGER NOT NULL,
    "Username" VARCHAR(120) NOT NULL,
    "When" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    "EventType" cqc."EstablishmentAuditChangeType" NOT NULL,
    "PropertyName" VARCHAR(100) NULL,
    "ChangeEvents" JSONB NULL,
    CONSTRAINT "EstablishmentAudit_User_fk" FOREIGN KEY ("EstablishmentFK") REFERENCES cqc."Establishment" ("EstablishmentID") MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
);
CREATE INDEX "EstablshmentAudit_EstablishmentFK" on cqc."EstablishmentAudit" ("EstablishmentFK");

ALTER TABLE cqc."Establishment" ADD COLUMN "EstablishmentUID" UUID NULL;
-- unfortunately, without the postgres extension "uuid-ossp", need an alternative method to
--  update existing User records with UUID
UPDATE
    cqc."Establishment" 
SET
    "EstablishmentUID" = "ESTABLISHMENT_UUID"."UIDv4"
FROM (
    SELECT CAST(substr(CAST(myuuids."UID" AS TEXT), 0, 15) || '4' || substr(CAST(myuuids."UID" AS TEXT), 16, 3) || '-89' || substr(CAST(myuuids."UID" AS TEXT), 22, 36) AS UUID) "UIDv4", "RegID"
    FROM (
        SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) "UID",
                "Establishment"."EstablishmentID" "RegID"
        FROM cqc."Establishment"
    ) AS MyUUIDs
) AS "ESTABLISHMENT_UUID"
WHERE "ESTABLISHMENT_UUID"."RegID" = "Establishment"."EstablishmentID";
ALTER TABLE cqc."Establishment" ALTER COLUMN "EstablishmentUID" SET NOT NULL;

-- need to add "create" audit event for all existing Establishments
insert into
	cqc."EstablishmentAudit" ("EstablishmentFK", "Username", "When", "EventType")
select "EstablishmentID", 'admin', now(), 'created'
from cqc."Establishment"
where "EstablishmentID" not in (
	select distinct "EstablishmentFK" from cqc."EstablishmentAudit"
	where "EventType" = 'created'
	);

ALTER TABLE cqc."Establishment" RENAME COLUMN "EmployerType" TO "EmployerTypeValue";
ALTER TABLE cqc."Establishment"   ADD COLUMN "EmployerTypeSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "EmployerTypeChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "EmployerTypeSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "EmployerTypeChangedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."Establishment" RENAME COLUMN "NumberOfStaff" TO "NumberOfStaffValue";
ALTER TABLE cqc."Establishment"   ADD COLUMN "NumberOfStaffSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "NumberOfStaffChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "NumberOfStaffSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "NumberOfStaffChangedBy" VARCHAR(120) NULL;

ALTER TABLE cqc."Establishment"   ADD COLUMN "OtherServicesSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "OtherServicesChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "OtherServicesSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "OtherServicesChangedBy" VARCHAR(120) NULL;

ALTER TABLE cqc."Establishment"   ADD COLUMN "CapacityServicesSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "CapacityServicesChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "CapacityServicesSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "CapacityServicesChangedBy" VARCHAR(120) NULL;

ALTER TABLE cqc."Establishment" RENAME COLUMN "ShareData" TO "ShareDataValue";
ALTER TABLE cqc."Establishment"   ADD COLUMN "ShareDataSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "ShareDataChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "ShareDataSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "ShareDataChangedBy" VARCHAR(120) NULL;

ALTER TABLE cqc."Establishment"   ADD COLUMN "ShareWithLASavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "ShareWithLAChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "ShareWithLASavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "ShareWithLAChangedBy" VARCHAR(120) NULL;

ALTER TABLE cqc."Establishment" RENAME COLUMN "Vacancies" TO "VacanciesValue";
ALTER TABLE cqc."Establishment"   ADD COLUMN "VacanciesSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "VacanciesChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "VacanciesSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "VacanciesChangedBy" VARCHAR(120) NULL;

ALTER TABLE cqc."Establishment" RENAME COLUMN "Starters" TO "StartersValue";
ALTER TABLE cqc."Establishment"   ADD COLUMN "StartersSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "StartersChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "StartersSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "StartersChangedBy" VARCHAR(120) NULL;

ALTER TABLE cqc."Establishment" RENAME COLUMN "Leavers" TO "LeaversValue";
ALTER TABLE cqc."Establishment"   ADD COLUMN "LeaversSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "LeaversChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "LeaversSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "LeaversChangedBy" VARCHAR(120) NULL;

-- default values for all employer type properyy
update
    cqc."Establishment"
set
    "EmployerTypeSavedAt" = now(),
    "EmployerTypeChangedAt" = now(),
    "EmployerTypeSavedBy" = 'admin',
    "EmployerTypeChangedBy" = 'admin'
where
    "EmployerTypeValue" is not null;        -- namely, the employer type property has been given

-- default values for all staff property
update
    cqc."Establishment"
set
    "NumberOfStaffSavedAt" = now(),
    "NumberOfStaffChangedAt" = now(),
    "NumberOfStaffSavedBy" = 'admin',
    "NumberOfStaffChangedBy" = 'admin'
where
    "NumberOfStaffValue" is not null;        -- namely, the staff property has been given

-- default values for all Other Services property
update
    cqc."Establishment"
set
    "OtherServicesSavedAt" = now(),
    "OtherServicesChangedAt" = now(),
    "OtherServicesSavedBy" = 'admin',
    "OtherServicesChangedBy" = 'admin'
from
	(select distinct "EstablishmentID" from cqc."EstablishmentServices") as "KnownEstablishmentsWithOtherServices"
where
    "KnownEstablishmentsWithOtherServices"."EstablishmentID" = "Establishment"."EstablishmentID";        -- namely, there are known other services

-- default values for all Capacity Services property
update
    cqc."Establishment"
set
    "CapacityServicesSavedAt" = now(),
    "CapacityServicesChangedAt" = now(),
    "CapacityServicesSavedBy" = 'admin',
    "CapacityServicesChangedBy" = 'admin'
from
	(select distinct "EstablishmentID" from cqc."EstablishmentCapacity") as "KnownEstablishmentsWithCapacityServices"
where
    "KnownEstablishmentsWithCapacityServices"."EstablishmentID" = "Establishment"."EstablishmentID";        -- namely, there are known capacity services


-- default values for all "share data" property
update
    cqc."Establishment"
set
    "ShareDataSavedAt" = now(),
    "ShareDataChangedAt" = now(),
    "ShareDataSavedBy" = 'admin',
    "ShareDataChangedBy" = 'admin'
where
    "ShareDataValue" = true;        -- namely, share is any other than the default of false

-- default values for all Share with LA (local Authorities) property
update
    cqc."Establishment"
set
    "ShareWithLASavedAt" = now(),
    "ShareWithLAChangedAt" = now(),
    "ShareWithLASavedBy" = 'admin',
    "ShareWithLAChangedBy" = 'admin'
from
	(select distinct "EstablishmentID" from cqc."EstablishmentLocalAuthority") as "KnownEstablishmentsWithLAs"
where
    "KnownEstablishmentsWithLAs"."EstablishmentID" = "Establishment"."EstablishmentID";        -- namely, there are known capacity services

-- views are used to separate out Vacancies, Starters and Leavers upon the single EstablishmentJobs entity
CREATE VIEW cqc."VacanciesVW" AS
	SELECT
		"EstablishmentJobID",
		"EstablishmentID",
		"JobID",
		"JobType",
		"Total"
	FROM cqc."EstablishmentJobs"
	WHERE "JobType" = 'Vacancies';
CREATE VIEW cqc."StartersVW" AS
	SELECT
		"EstablishmentJobID",
		"EstablishmentID",
		"JobID",
		"JobType",
		"Total"
	FROM cqc."EstablishmentJobs"
	WHERE "JobType" = 'Starters';
CREATE VIEW cqc."LeaversVW" AS
	SELECT
		"EstablishmentJobID",
		"EstablishmentID",
		"JobID",
		"JobType",
		"Total"
	FROM cqc."EstablishmentJobs"
	WHERE "JobType" = 'Leavers';

-- default values for Vacancies property
update
    cqc."Establishment"
set
    "VacanciesSavedAt" = now(),
    "VacanciesChangedAt" = now(),
    "VacanciesSavedBy" = 'admin',
    "VacanciesChangedBy" = 'admin'
where
    "VacanciesValue" is not null;        -- namely, there are no known Vacancies

-- default values for Starters property
update
    cqc."Establishment"
set
    "StartersSavedAt" = now(),
    "StartersChangedAt" = now(),
    "StartersSavedBy" = 'admin',
    "StartersChangedBy" = 'admin'
where
    "StartersValue" is not null;        -- namely, there are no known Starters

-- default values for Leavers property
update
    cqc."Establishment"
set
    "LeaversSavedAt" = now(),
    "LeaversChangedAt" = now(),
    "LeaversSavedBy" = 'admin',
    "LeaversChangedBy" = 'admin'
where
    "LeaversValue" is not null;        -- namely, there are no known Leavers

-- patch SQL for "Service Users Question" - https://trello.com/c/6j4x0gui
-- Service Users Reference Data
CREATE TABLE IF NOT EXISTS cqc."ServiceUsers" (
	"ID" INTEGER NOT NULL PRIMARY KEY,
	"Seq" INTEGER NOT NULL, 	-- this is the order in which the Ethinicity will appear without impacting on primary key (existing foreign keys)
	"ServiceGroup" TEXT NOT NULL,
	"Service" TEXT NOT NULL
);
INSERT INTO cqc."ServiceUsers" ("ID", "Seq", "ServiceGroup", "Service") VALUES 
	(1, 1, 'Older people', 'Older people with dementia'),
	(2, 2, 'Older people', 'Older people with mental disorders or infirmities, excluding learning disability or dementia'),
	(3, 3, 'Older people', 'Older people detained under the Mental Health Act'),
	(4, 4, 'Older people', 'Older people with learning disabilities and/or autism'),
	(5, 5, 'Older people', 'Older people with physical disabilities'),
	(6, 6, 'Older people', 'Older people with sensory impairment(s)'),
	(7, 7, 'Older people', 'Older people who misuse alcohol/drugs'),
	(8, 8, 'Older people', 'Older people with an eating disorder'),
	(9, 9, 'Older people', 'Older people not in above categories'),
	(10, 101, 'Adults', 'Adults with dementia'),
	(11, 102, 'Adults', 'Adults with mental disorders or infirmities, excluding learning disability or dementia'),
	(12, 103, 'Adults', 'Adults detained under the Mental Health Act'),
	(13, 104, 'Adults', 'Adults with learning disabilities and/or autism'),
	(14, 105, 'Adults', 'Adults with physical disabilities'),
	(15, 106, 'Adults', 'Adults with sensory impairments'),
	(16, 107, 'Adults', 'Adults who misuse alcohol/drugs'),
	(17, 108, 'Adults', 'Adults with an eating disorder'),
	(18, 109, 'Adults', 'Adults not in above categories'),
	(19, 201, 'Children and young people', 'Any children and young people'),
    (20, 301, 'Carers', 'Carers of older people'),
    (21, 302, 'Carers', 'Carers of adults'),
    (22, 303, 'Carers', 'Carers of children and young people'),
    (23, 401, 'Other', 'Any others not in above categories');

CREATE TABLE IF NOT EXISTS cqc."EstablishmentServiceUsers" (
    "EstablishmentID" integer NOT NULL,
    "ServiceUserID" integer NOT NULL
);

-- Service Users property - https://trello.com/c/6j4x0gui
-- this is a new property, so no patching upon existing data
ALTER TABLE cqc."Establishment"   ADD COLUMN "ServiceUsersSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "ServiceUsersChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "ServiceUsersSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "ServiceUsersChangedBy" VARCHAR(120) NULL;

-- Change Name and Main Service to managed properties for edit and audit - https://trello.com/c/6y2OTQmB
-- these are previously fixed properties, so no patching upon existing data
ALTER TABLE cqc."Establishment" RENAME COLUMN "Name" TO "NameValue";
ALTER TABLE cqc."Establishment"   ADD COLUMN "NameSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "NameChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "NameSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "NameChangedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."Establishment" RENAME COLUMN "MainServiceId" TO "MainServiceFKValue";
ALTER TABLE cqc."Establishment"   ADD COLUMN "MainServiceFKSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "MainServiceFKChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "MainServiceFKSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."Establishment"   ADD COLUMN "MainServiceFKChangedBy" VARCHAR(120) NULL;
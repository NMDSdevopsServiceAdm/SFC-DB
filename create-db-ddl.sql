--
-- PostgreSQL database dump
--

-- Dumped from database version 11.0
-- Dumped by pg_dump version 11.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: cqc; Type: SCHEMA; Schema: -; Owner: sfcadmin
--

CREATE SCHEMA IF NOT EXISTS cqc;


ALTER SCHEMA cqc OWNER TO sfcadmin;

--
-- Name: est_employertype_enum; Type: TYPE; Schema: cqc; Owner: postgres
--

CREATE TYPE cqc.est_employertype_enum AS ENUM (
    'Private Sector',
    'Voluntary / Charity',
    'Other',
    'Local Authority (generic/other)',
    'Local Authority (adult services)'
);

ALTER TYPE cqc.est_employertype_enum OWNER TO sfcadmin;

--
-- Name: job_type; Type: TYPE; Schema: cqc; Owner: postgres
--

CREATE TYPE cqc.job_type AS ENUM (
    'Vacancies',
    'Starters',
    'Leavers'
);


ALTER TYPE cqc.job_type OWNER TO sfcadmin;

--SET default_tablespace = sfcdevtbs_logins;

SET default_with_oids = false;


CREATE SEQUENCE IF NOT EXISTS cqc."NmdsID_seq"
    AS integer
    START WITH 1001000
    INCREMENT BY 1
    MINVALUE 1001000
    MAXVALUE 9999999
    CACHE 1;
ALTER TABLE cqc."NmdsID_seq" OWNER TO sfcadmin;

CREATE TYPE cqc.job_declaration AS ENUM (
    'None',
    'Don''t know',
	'With Jobs'
);

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
	(15, 106, 'Adults', 'Adults with sensory impairment(s)'),
	(16, 107, 'Adults', 'Adults who misuse alcohol/drugs'),
	(17, 108, 'Adults', 'Adults with an eating disorder'),
	(18, 109, 'Adults', 'Adults not in above categories'),
	(19, 201, 'Children and young people', 'Any children and young people'),
    (20, 301, 'Carers', 'Carers of older people'),
    (21, 302, 'Carers', 'Carers of adults'),
    (22, 303, 'Carers', 'Carers of children and young people'),
    (23, 401, 'Other', 'Any others not in above categories');


-- establishment owner
CREATE TYPE cqc.establishment_owner AS ENUM (
    'Workplace',
    'Parent'
);
CREATE TYPE cqc.establishment_data_access_permission AS ENUM (
    'Workplace',
    'Workplace and Staff',
    'None'
);

DROP TYPE IF EXISTS cqc."DataSource";
CREATE TYPE cqc."DataSource" AS ENUM (
    'Online',
    'Bulk'
);


--
-- Name: Establishment; Type: TABLE; Schema: cqc; Owner: sfcadmin; Tablespace: sfcdevtbs_logins
--

CREATE TABLE IF NOT EXISTS cqc."Establishment" (
    "EstablishmentID" integer NOT NULL,
    "EstablishmentUID" UUID NOT NULL,
    "TribalID" INTEGER NULL,
    "NmdsID" character(8) NOT NULL,
    "Address1" text,
    "Address2" text,
    "Address3" text,
    "Town" text,
    "County" text,
    "LocationID" text,
    "ProvID" text,
    "PostCode" text,
    "IsRegulated" boolean NOT NULL,
    "OverallWdfEligibility" timestamp without time zone NULL,
    "StaffWdfEligibility" timestamp without time zone NULL,
    "EstablishmentWdfEligibility" timestamp without time zone NULL,
    "LastWdfEligibility" timestamp without time zone NULL,
    "IsParent" BOOLEAN DEFAULT FALSE,
    "ParentID" INTEGER NULL,
    "ParentUID" UUID NULL,
    "DataOwner" cqc.establishment_owner NOT NULL DEFAULT 'Workplace',
    "DataPermissions" cqc.establishment_data_access_permission DEFAULT 'None',
    "DataSource" cqc."DataSource" DEFAULT 'Online',
    "NameValue" text NOT NULL,
    "NameSavedAt" TIMESTAMP NULL,
    "NameChangedAt" TIMESTAMP NULL,
    "NameSavedBy" VARCHAR(120) NULL,
    "NameChangedBy" VARCHAR(120) NULL,
    "MainServiceFKValue" integer,
    "MainServiceFkOther" TEXT NULL,
    "MainServiceFKSavedAt" TIMESTAMP NULL,
    "MainServiceFKChangedAt" TIMESTAMP NULL,
    "MainServiceFKSavedBy" VARCHAR(120) NULL,
    "MainServiceFKChangedBy" VARCHAR(120) NULL,
    "EmployerTypeValue" cqc.est_employertype_enum,
    "EmployerTypeSavedAt" TIMESTAMP NULL,
    "EmployerTypeChangedAt" TIMESTAMP NULL,
    "EmployerTypeSavedBy" VARCHAR(120) NULL,
    "EmployerTypeChangedBy" VARCHAR(120) NULL,
    "NumberOfStaffValue" integer,
    "EmployerTypeOther" TEXT NULL,
    "NumberOfStaffSavedAt" TIMESTAMP NULL,
    "NumberOfStaffChangedAt" TIMESTAMP NULL,
    "NumberOfStaffSavedBy" VARCHAR(120) NULL,
    "NumberOfStaffChangedBy" VARCHAR(120) NULL,
    "OtherServicesSavedAt" TIMESTAMP NULL,
    "OtherServicesChangedAt" TIMESTAMP NULL,
    "OtherServicesSavedBy" VARCHAR(120) NULL,
    "OtherServicesChangedBy" VARCHAR(120) NULL,
    "ServiceUsersSavedAt" TIMESTAMP NULL,
    "ServiceUsersChangedAt" TIMESTAMP NULL,
    "ServiceUsersSavedBy" VARCHAR(120) NULL,
    "ServiceUsersChangedBy" VARCHAR(120) NULL,
    "CapacityServicesSavedAt" TIMESTAMP NULL,
    "CapacityServicesChangedAt" TIMESTAMP NULL,
    "CapacityServicesSavedBy" VARCHAR(120) NULL,
    "CapacityServicesChangedBy" VARCHAR(120) NULL,
    "ShareDataValue"  boolean DEFAULT false,
    "ShareDataSavedAt" TIMESTAMP NULL,
    "ShareDataChangedAt" TIMESTAMP NULL,
    "ShareDataSavedBy" VARCHAR(120) NULL,
    "ShareDataChangedBy" VARCHAR(120) NULL,
    "ShareDataWithCQC" boolean DEFAULT false,
    "ShareDataWithLA" boolean DEFAULT false,
    "ShareWithLASavedAt" TIMESTAMP NULL,
    "ShareWithLAChangedAt" TIMESTAMP NULL,
    "ShareWithLASavedBy" VARCHAR(120) NULL,
    "ShareWithLAChangedBy" VARCHAR(120) NULL,
    "VacanciesValue" cqc.job_declaration NULL,
    "StartersValue" cqc.job_declaration NULL,
    "LeaversValue" cqc.job_declaration NULL,
    "VacanciesSavedAt" TIMESTAMP NULL,
    "VacanciesChangedAt" TIMESTAMP NULL,
    "VacanciesSavedBy" VARCHAR(120) NULL,
    "VacanciesChangedBy" VARCHAR(120) NULL,
    "StartersSavedAt" TIMESTAMP NULL,
    "StartersChangedAt" TIMESTAMP NULL,
    "StartersSavedBy" VARCHAR(120) NULL,
    "StartersChangedBy" VARCHAR(120) NULL,
    "LeaversSavedAt" TIMESTAMP NULL,
    "LeaversChangedAt" TIMESTAMP NULL,
    "LeaversSavedBy" VARCHAR(120) NULL,
    "LeaversChangedBy" VARCHAR(120) NULL,
    "LocalIdentifierValue" TEXT,
    "LocalIdentifierSavedAt" TIMESTAMP NULL,
    "LocalIdentifierChangedAt" TIMESTAMP NULL,
    "LocalIdentifierSavedBy" VARCHAR(120) NULL,
    "LocalIdentifierChangedBy" VARCHAR(120) NULL,
    "Archived" BOOLEAN DEFAULT false,
    "LastBulkUploaded" TIMESTAMP NULL,
    "ReasonsForLeaving" TEXT NULL,
    created timestamp without time zone NOT NULL DEFAULT now(),
    updated timestamp without time zone NOT NULL DEFAULT now(),
    updatedby character varying(120) COLLATE pg_catalog."default" NOT NULL
);


ALTER TABLE cqc."Establishment" OWNER TO sfcadmin;
ALTER TABLE ONLY cqc."Establishment"
    ADD CONSTRAINT unqestbid UNIQUE ("EstablishmentID");
ALTER TABLE cqc."Establishment" ADD CONSTRAINT establishment_establishment_parent_fk FOREIGN KEY ("ParentID")
        REFERENCES cqc."Establishment" ("EstablishmentID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION;

--SET default_tablespace = '';

--
-- Name: EstablishmentCapacity; Type: TABLE; Schema: cqc; Owner: postgres
--

CREATE TABLE IF NOT EXISTS cqc."EstablishmentCapacity" (
    "EstablishmentCapacityID" integer NOT NULL,
    "EstablishmentID" integer,
    "ServiceCapacityID" integer NOT NULL,
    "Answer" integer
);


ALTER TABLE cqc."EstablishmentCapacity" OWNER TO sfcadmin;

--
-- Name: EstablishmentCapacity_EstablishmentCapacityID_seq; Type: SEQUENCE; Schema: cqc; Owner: postgres
--

CREATE SEQUENCE IF NOT EXISTS cqc."EstablishmentCapacity_EstablishmentCapacityID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cqc."EstablishmentCapacity_EstablishmentCapacityID_seq" OWNER TO sfcadmin;

--
-- Name: EstablishmentCapacity_EstablishmentCapacityID_seq; Type: SEQUENCE OWNED BY; Schema: cqc; Owner: postgres
--

ALTER SEQUENCE IF EXISTS cqc."EstablishmentCapacity_EstablishmentCapacityID_seq" OWNED BY cqc."EstablishmentCapacity"."EstablishmentCapacityID";


--
-- Name: EstablishmentJobs; Type: TABLE; Schema: cqc; Owner: sfcadmin
--

CREATE TABLE IF NOT EXISTS cqc."EstablishmentJobs" (
    "JobID" integer NOT NULL,
    "EstablishmentID" integer NOT NULL,
    "EstablishmentJobID" integer NOT NULL,
    "JobType" cqc.job_type NOT NULL,
	"Total" INTEGER NOT NULL
);


ALTER TABLE cqc."EstablishmentJobs" OWNER TO sfcadmin;

--
-- Name: EstablishmentJobs_EstablishmentJobID_seq; Type: SEQUENCE; Schema: cqc; Owner: sfcadmin
--

CREATE SEQUENCE IF NOT EXISTS cqc."EstablishmentJobs_EstablishmentJobID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cqc."EstablishmentJobs_EstablishmentJobID_seq" OWNER TO sfcadmin;

--
-- Name: EstablishmentJobs_EstablishmentJobID_seq; Type: SEQUENCE OWNED BY; Schema: cqc; Owner: sfcadmin
--

ALTER SEQUENCE IF EXISTS cqc."EstablishmentJobs_EstablishmentJobID_seq" OWNED BY cqc."EstablishmentJobs"."EstablishmentJobID";

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

---CSSR TABLE CREATION 
CREATE TABLE cqc."Cssr"
(
    "CssrID" INTEGER NOT NULL,
    "LocalCustodianCode" integer NOT NULL,
    "CssR" TEXT COLLATE pg_catalog."default" NOT NULL,
	"LocalAuthority" TEXT NOT NULL,
    "Region" TEXT COLLATE pg_catalog."default" NOT NULL,
    "RegionID" INTEGER NOT NULL,
    "NmdsIDLetter" CHARACTER(1) COLLATE pg_catalog."default" NOT NULL,
	PRIMARY KEY ("CssrID", "LocalCustodianCode")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;
ALTER TABLE cqc."Cssr" OWNER TO sfcadmin;

--
-- Name: EstablishmentLocalAuthority_EstablishmentLocalAuthorityID_seq; Type: SEQUENCE; Schema: cqc; Owner: postgres
--

CREATE SEQUENCE IF NOT EXISTS cqc."EstablishmentLocalAuthority_EstablishmentLocalAuthorityID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: EstablishmentLocalAuthority; Type: TABLE; Schema: cqc; Owner: postgres
--

CREATE TABLE IF NOT EXISTS cqc."EstablishmentLocalAuthority" (
    "EstablishmentLocalAuthorityID" integer NOT NULL DEFAULT nextval('cqc."EstablishmentLocalAuthority_EstablishmentLocalAuthorityID_seq"'::regclass),
    "EstablishmentID" integer NOT NULL,
    "CssrID" integer NOT NULL,
    "CssR" TEXT COLLATE pg_catalog."default" NOT NULL,
	CONSTRAINT establishmentlocalauthority_pk PRIMARY KEY ("EstablishmentLocalAuthorityID"),
    CONSTRAINT "EstablishmentLocalAuthorityID_Unq" UNIQUE ("EstablishmentLocalAuthorityID"),
    CONSTRAINT establishment_establishmentlocalauthority_fk FOREIGN KEY ("EstablishmentID")
        REFERENCES cqc."Establishment" ("EstablishmentID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);


ALTER TABLE cqc."EstablishmentLocalAuthority" OWNER TO sfcadmin;

ALTER TABLE cqc."EstablishmentLocalAuthority_EstablishmentLocalAuthorityID_seq" OWNER TO sfcadmin;
ALTER SEQUENCE IF EXISTS cqc."EstablishmentLocalAuthority_EstablishmentLocalAuthorityID_seq" OWNED BY cqc."EstablishmentLocalAuthority"."EstablishmentLocalAuthorityID";



--
-- Name: EstablishmentServices; Type: TABLE; Schema: cqc; Owner: sfcadmin
--

CREATE TABLE IF NOT EXISTS cqc."EstablishmentServices" (
    "EstablishmentID" integer NOT NULL,
    "ServiceID" integer NOT NULL,
    "Other" TEXT NULL
);


ALTER TABLE cqc."EstablishmentServices" OWNER TO sfcadmin;


CREATE TABLE IF NOT EXISTS cqc."EstablishmentServiceUsers" (
    "EstablishmentID" integer NOT NULL,
    "ServiceUserID" integer NOT NULL,
    "Other" TEXT NULL
    CONSTRAINT establishment_establishmentserviceusers_fk FOREIGN KEY ("EstablishmentID")
        REFERENCES cqc."Establishment" ("EstablishmentID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT serviceusers_establishmentserviceusers_fk FOREIGN KEY ("ServiceUserID")
        REFERENCES cqc."ServiceUSers" ("ID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

--
-- Name: Establishment_EstablishmentID_seq; Type: SEQUENCE; Schema: cqc; Owner: sfcadmin
--

CREATE SEQUENCE IF NOT EXISTS cqc."Establishment_EstablishmentID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cqc."Establishment_EstablishmentID_seq" OWNER TO sfcadmin;

--
-- Name: Establishment_EstablishmentID_seq; Type: SEQUENCE OWNED BY; Schema: cqc; Owner: sfcadmin
--

ALTER SEQUENCE IF EXISTS cqc."Establishment_EstablishmentID_seq" OWNED BY cqc."Establishment"."EstablishmentID";


--
-- Name: Job; Type: TABLE; Schema: cqc; Owner: sfcadmin
--

CREATE TABLE IF NOT EXISTS cqc."Job" (
    "JobID" integer NOT NULL,
    "JobName" text
);


ALTER TABLE cqc."Job" OWNER TO sfcadmin;


--SET default_tablespace = sfcdevtbs_logins;

--
-- Name: Login; Type: TABLE; Schema: cqc; Owner: sfcadmin; Tablespace: sfcdevtbs_logins
--

CREATE TABLE IF NOT EXISTS cqc."Login" (
    "ID" integer NOT NULL,
    "RegistrationID" integer NOT NULL,
    "Username" character varying(120) NOT NULL,
    "Active" boolean NOT NULL,
    "InvalidAttempt" integer NOT NULL,
    "Hash" character varying(255),
    "FirstLogin" timestamp(4) without time zone,
    "PasswdLastChanged" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW().
    "LastLoggedIn" TIMESTAMP WITHOUT TIME ZONE NULL,
    "TribalHash" VARCHAR(128) NULL,
    "TribalSalt" VARCHAR(50) NULL
);


ALTER TABLE cqc."Login" OWNER TO sfcadmin;

--
-- Name: Login_ID_seq; Type: SEQUENCE; Schema: cqc; Owner: sfcadmin
--

CREATE SEQUENCE IF NOT EXISTS cqc."Login_ID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cqc."Login_ID_seq" OWNER TO sfcadmin;

--
-- Name: Login_ID_seq; Type: SEQUENCE OWNED BY; Schema: cqc; Owner: sfcadmin
--

ALTER SEQUENCE IF EXISTS cqc."Login_ID_seq" OWNED BY cqc."Login"."ID";


SET default_tablespace = '';

--
-- Name: ServicesCapacity; Type: TABLE; Schema: cqc; Owner: sfcadmin
--

CREATE TYPE cqc."ServicesCapacityType" AS ENUM (
    'Capacity',
    'Utilisation'
);
ALTER TYPE cqc."ServicesCapacityType" OWNER TO sfcadmin;

CREATE TABLE IF NOT EXISTS cqc."ServicesCapacity" (
    "ServiceCapacityID" integer NOT NULL,
    "ServiceID" integer,
    "Question" text,
    "Sequence" integer,
    "Type" cqc."ServicesCapacityType" default 'Capacity'
);


ALTER TABLE cqc."ServicesCapacity" OWNER TO sfcadmin;

-- An Establishment's User can take one of two roles: Edit or Read Only
CREATE TYPE cqc.user_role AS ENUM (
    'Read',
    'Edit',
    'Admin'
);

--SET default_tablespace = sfcdevtbs_logins;

--
-- Name: User; Type: TABLE; Schema: cqc; Owner: sfcadmin; Tablespace: sfcdevtbs_logins
--

CREATE TABLE IF NOT EXISTS cqc."User" (
    "RegistrationID" integer NOT NULL,
    "UserUID" UUID NOT NULL,
    "IsPrimary" BOOLEAN NOT NULL DEFAULT true,
    "TribalID" INTEGER NULL,
    "UserRoleValue" cqc.user_role NOT NULL DEFAULT 'Edit',
    "UserRoleSavedAt" TIMESTAMP NULL,
    "UserRoleChangedAt" TIMESTAMP NULL,
    "UserRoleSavedBy" VARCHAR(120) NULL,
    "UserRoleChangedBy" VARCHAR(120) NULL,
    "EstablishmentID" integer NULL,
    "Archived" BOOLEAN DEFAULT false,
    "FullNameValue" character varying(120) NOT NULL,
    "FullNameSavedAt" TIMESTAMP NULL,
    "FullNameChangedAt" TIMESTAMP NULL,
    "FullNameSavedBy" VARCHAR(120) NULL,
    "FullNameChangedBy" VARCHAR(120) NULL,
    "JobTitleValue" character varying(255) NOT NULL,
    "JobTitleSavedAt" TIMESTAMP NULL,
    "JobTitleChangedAt" TIMESTAMP NULL,
    "JobTitleSavedBy" VARCHAR(120) NULL,
    "JobTitleChangedBy" VARCHAR(120) NULL,
    "EmailValue" character varying(255) NOT NULL,
    "EmailSavedAt" TIMESTAMP NULL,
    "EmailChangedAt" TIMESTAMP NULL,
    "EmailSavedBy" VARCHAR(120) NULL,
    "EmailChangedBy" VARCHAR(120) NULL,
    "PhoneValue" character varying(50) NOT NULL,
    "PhoneSavedAt" TIMESTAMP NULL,
    "PhoneChangedAt" TIMESTAMP NULL,
    "PhoneSavedBy" VARCHAR(120) NULL,
    "PhoneChangedBy" VARCHAR(120) NULL,
    "SecurityQuestionValue" character varying(255),
    "SecurityQuestionSavedAt" TIMESTAMP NULL,
    "SecurityQuestionChangedAt" TIMESTAMP NULL,
    "SecurityQuestionSavedBy" VARCHAR(120) NULL,
    "SecurityQuestionChangedBy" VARCHAR(120) NULL,
    "SecurityQuestionAnswerValue" character varying(255),
    "SecurityQuestionAnswerSavedAt" TIMESTAMP NULL,
    "SecurityQuestionAnswerChangedAt" TIMESTAMP NULL,
    "SecurityQuestionAnswerSavedBy" VARCHAR(120) NULL,
    "SecurityQuestionAnswerChangedBy" VARCHAR(120) NULL,
    created TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
	updated TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),	-- note, on creation of record, updated and created are equal
	updatedby VARCHAR(120) NOT NULL
);
ALTER TABLE cqc."User" OWNER TO sfcadmin;

--
-- Name: User_RegistrationID_seq; Type: SEQUENCE; Schema: cqc; Owner: sfcadmin
--

CREATE SEQUENCE IF NOT EXISTS cqc."User_RegistrationID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cqc."User_RegistrationID_seq" OWNER TO sfcadmin;

--
-- Name: User_RegistrationID_seq; Type: SEQUENCE OWNED BY; Schema: cqc; Owner: sfcadmin
--

ALTER SEQUENCE IF EXISTS cqc."User_RegistrationID_seq" OWNED BY cqc."User"."RegistrationID";


--
-- Name: services; Type: TABLE; Schema: cqc; Owner: sfcadmin; Tablespace: sfcdevtbs_logins
--

CREATE TABLE IF NOT EXISTS cqc.services (
    id integer NOT NULL,
    name text,
    category text,
    iscqcregistered boolean,
    ismain boolean DEFAULT true,
    "reportingID" integer
);


ALTER TABLE cqc.services OWNER TO sfcadmin;

--
-- Name: services_id_seq; Type: SEQUENCE; Schema: cqc; Owner: sfcadmin
--

CREATE SEQUENCE IF NOT EXISTS cqc.services_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cqc.services_id_seq OWNER TO sfcadmin;

--
-- Name: services_id_seq; Type: SEQUENCE OWNED BY; Schema: cqc; Owner: sfcadmin
--

ALTER SEQUENCE IF EXISTS cqc.services_id_seq OWNED BY cqc.services.id;



--
-- Name: Establishment EstablishmentID; Type: DEFAULT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."Establishment" ALTER COLUMN "EstablishmentID" SET DEFAULT nextval('cqc."Establishment_EstablishmentID_seq"'::regclass);


--
-- Name: EstablishmentCapacity EstablishmentCapacityID; Type: DEFAULT; Schema: cqc; Owner: postgres
--

ALTER TABLE ONLY cqc."EstablishmentCapacity" ALTER COLUMN "EstablishmentCapacityID" SET DEFAULT nextval('cqc."EstablishmentCapacity_EstablishmentCapacityID_seq"'::regclass);


--
-- Name: EstablishmentJobs EstablishmentJobID; Type: DEFAULT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."EstablishmentJobs" ALTER COLUMN "EstablishmentJobID" SET DEFAULT nextval('cqc."EstablishmentJobs_EstablishmentJobID_seq"'::regclass);



--
-- Name: Login ID; Type: DEFAULT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."Login" ALTER COLUMN "ID" SET DEFAULT nextval('cqc."Login_ID_seq"'::regclass);


--
-- Name: User RegistrationID; Type: DEFAULT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."User" ALTER COLUMN "RegistrationID" SET DEFAULT nextval('cqc."User_RegistrationID_seq"'::regclass);


--
-- Name: services id; Type: DEFAULT; Schema: cqc; Owner: sfcadmin
--
-- services is a lookup table; primary key must be fixed and known not auto increment
--ALTER TABLE ONLY cqc.services ALTER COLUMN id SET DEFAULT nextval('cqc.services_id_seq'::regclass);


SET default_tablespace = '';


--
-- Name: EstablishmentCapacity EstablishmentCapacity_pkey1; Type: CONSTRAINT; Schema: cqc; Owner: postgres
--

ALTER TABLE ONLY cqc."EstablishmentCapacity"
    ADD CONSTRAINT "EstablishmentCapacity_pkey1" PRIMARY KEY ("EstablishmentCapacityID");


--
-- Name: EstablishmentJobs EstablishmentJobs_pkey; Type: CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."EstablishmentJobs"
    ADD CONSTRAINT "EstablishmentJobs_pkey" PRIMARY KEY ("EstablishmentJobID");


--
-- Name: EstablishmentCapacity EstablishmentServiceCapacity_unq1; Type: CONSTRAINT; Schema: cqc; Owner: postgres
--

ALTER TABLE ONLY cqc."EstablishmentCapacity"
    ADD CONSTRAINT "EstablishmentServiceCapacity_unq1" UNIQUE ("EstablishmentID", "ServiceCapacityID");


--
-- Name: Establishment Establishment_pkey; Type: CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."Establishment"
    ADD CONSTRAINT "Establishment_pkey" PRIMARY KEY ("EstablishmentID");


--
-- Name: Job Job_pkey; Type: CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."Job"
    ADD CONSTRAINT "Job_pkey" PRIMARY KEY ("JobID");


--
-- Name: EstablishmentServices OtherServices_pkey; Type: CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."EstablishmentServices"
    ADD CONSTRAINT "OtherServices_pkey" PRIMARY KEY ("EstablishmentID", "ServiceID");


--
-- Name: ServicesCapacity ServicesCapacity_pkey; Type: CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."ServicesCapacity"
    ADD CONSTRAINT "ServicesCapacity_pkey" PRIMARY KEY ("ServiceCapacityID");



--
-- Name: Login pk_Login; Type: CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."Login"
    ADD CONSTRAINT "pk_Login" PRIMARY KEY ("ID");


--
-- Name: User pk_User; Type: CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."User"
    ADD CONSTRAINT "pk_User" PRIMARY KEY ("RegistrationID");


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: Login uc_Login_Username; Type: CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."Login"
    ADD CONSTRAINT "uc_Login_Username" UNIQUE ("Username");



--
-- Name: services unq_serviceid; Type: CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc.services
    ADD CONSTRAINT unq_serviceid UNIQUE (id);


--
-- Name: ServicesCapacity unq_servicescapacityid; Type: CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."ServicesCapacity"
    ADD CONSTRAINT unq_servicescapacityid UNIQUE ("ServiceCapacityID");


--
-- Name: User unq_userregistrationid; Type: CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."User"
    ADD CONSTRAINT unq_userregistrationid UNIQUE ("RegistrationID");




--
-- Name: ServicesCapacity unqsrvcid; Type: CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."ServicesCapacity"
    ADD CONSTRAINT unqsrvcid UNIQUE ("ServiceID", "Sequence");


--SET default_tablespace = sfcdevtbs_index;

--
-- Name: EstablishmentCapacity EstablishmentServiceCapacity_Establishment_fk1; Type: FK CONSTRAINT; Schema: cqc; Owner: postgres
--

ALTER TABLE ONLY cqc."EstablishmentCapacity"
    ADD CONSTRAINT "EstablishmentServiceCapacity_Establishment_fk1" FOREIGN KEY ("EstablishmentID") REFERENCES cqc."Establishment"("EstablishmentID");


--
-- Name: EstablishmentCapacity EstablishmentServiceCapacity_ServiceCapacity_fk1; Type: FK CONSTRAINT; Schema: cqc; Owner: postgres
--

ALTER TABLE ONLY cqc."EstablishmentCapacity"
    ADD CONSTRAINT "EstablishmentServiceCapacity_ServiceCapacity_fk1" FOREIGN KEY ("ServiceCapacityID") REFERENCES cqc."ServicesCapacity"("ServiceCapacityID");


--
-- Name: ServicesCapacity constr_srvcid_fk; Type: FK CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."ServicesCapacity"
    ADD CONSTRAINT constr_srvcid_fk FOREIGN KEY ("ServiceID") REFERENCES cqc.services(id);


--
-- Name: Login constraint_fk; Type: FK CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."Login"
    ADD CONSTRAINT constraint_fk FOREIGN KEY ("RegistrationID") REFERENCES cqc."User"("RegistrationID");


--
-- Name: EstablishmentJobs establishment_establishmentjobs_fk; Type: FK CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."EstablishmentJobs"
    ADD CONSTRAINT establishment_establishmentjobs_fk FOREIGN KEY ("EstablishmentID") REFERENCES cqc."Establishment"("EstablishmentID");


--
-- Name: EstablishmentServices estsrvc_estb_fk; Type: FK CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."EstablishmentServices"
    ADD CONSTRAINT estsrvc_estb_fk FOREIGN KEY ("EstablishmentID") REFERENCES cqc."Establishment"("EstablishmentID");


--
-- Name: EstablishmentServices estsrvc_services_fk; Type: FK CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."EstablishmentServices"
    ADD CONSTRAINT estsrvc_services_fk FOREIGN KEY ("ServiceID") REFERENCES cqc.services(id);


--
-- Name: EstablishmentJobs jobs_establishmentjobs_fk; Type: FK CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."EstablishmentJobs"
    ADD CONSTRAINT jobs_establishmentjobs_fk FOREIGN KEY ("JobID") REFERENCES cqc."Job"("JobID");



--
-- Name: Establishment mainserviceid_fk; Type: FK CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."Establishment"
    ADD CONSTRAINT mainserviceid_fk FOREIGN KEY ("MainServiceId") REFERENCES cqc.services(id) MATCH FULL;


--
-- Name: User user_establishment_fk; Type: FK CONSTRAINT; Schema: cqc; Owner: sfcadmin
--

ALTER TABLE ONLY cqc."User"
    ADD CONSTRAINT user_establishment_fk FOREIGN KEY ("EstablishmentID") REFERENCES cqc."Establishment"("EstablishmentID");



--
-- Name: Feedback
--
DROP SEQUENCE IF EXISTS cqc."Feedback_seq";
CREATE SEQUENCE cqc."Feedback_seq";
ALTER SEQUENCE cqc."Feedback_seq"
    OWNER TO sfcadmin;

    -- now table
DROP TABLE IF EXISTS cqc."Feedback";
CREATE TABLE cqc."Feedback"
(
    "FeedbackID" integer NOT NULL DEFAULT nextval('cqc."Feedback_seq"'::regclass),
    "Doing" Text NOT NULL,
    "Tellus" Text NOT NULL,
    "Name" Text,
    "Email" Text,
    created timestamp NOT NULL DEFAULT NOW(),
    CONSTRAINT feedback_pk PRIMARY KEY ("FeedbackID"),
    CONSTRAINT feedback_unq UNIQUE ("FeedbackID")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

ALTER TABLE cqc."Feedback"
    OWNER to sfcadmin;


--
-- PostgreSQL database dump complete
--

---- Services
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (1, 'Carers support', 'Adult community care', 'f', 't', 13);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (2, 'Community support and outreach', 'Adult community care', 'f', 't', 15);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (3, 'Disability adaptations / assistive technology services', 'Adult community care', 'f', 't', 18);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (4, 'Information and advice services', 'Adult community care', 'f', 't', 20);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (5, 'Occupational / employment-related services', 'Adult community care', 'f', 't', 19);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (6, 'Other adult community care service', 'Adult community care', 'f', 't', 21);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (7, 'Short breaks / respite care', 'Adult community care', 'f', 't', 14);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (8, 'Social work and care management', 'Adult community care', 'f', 't', 16);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (9, 'Day care and day services', 'Adult day', 'f', 't', 6);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (10, 'Other adult day care services', 'Adult day', 'f', 't', 7);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (11, 'Domestic services and home help', 'Adult domiciliary', 'f', 't', 10);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (12, 'Other adult residential care services', 'Adult residential', 'f', 't', 5);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (13, 'Sheltered housing', 'Adult residential', 'f', 't', 53);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (14, 'Any childrens / young peoples services', 'Other', 'f', 't', 76);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (15, 'Any other services', 'Other', 'f', 't', 52);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (16, 'Head office services', 'Other', 'f', 't', 72);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (17, 'Other healthcare service', 'Other', 'f', 't', 71);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (18, 'Other adult domiciliary care service', 'Adult domiciliary', 'f', 't', 12);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (19, 'Shared lives', 'Adult community care', 't', 't', 17);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (20, 'Domiciliary care services', 'Adult domiciliary', 't', 't', 8);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (21, 'Extra care housing services', 'Adult domiciliary', 't', 't', 54);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (22, 'Nurses agency', 'Adult domiciliary', 't', 't', 77);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (23, 'Supported living services', 'Adult domiciliary', 't', 't', 55);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (26, 'Community based services for people who misuse substances', 'Healthcare', 't', 't', 63);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (27, 'Community based services for people with a learning disability', 'Healthcare', 't', 't', 61);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (28, 'Community based services for people with mental health needs', 'Healthcare', 't', 't', 62);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (29, 'Community healthcare services', 'Healthcare', 't', 't', 64);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (30, 'Hospice services', 'Healthcare', 't', 't', 66);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (31, 'Hospital services for people with mental health needs, learning disabilities and/or problems with substance misuse', 'Healthcare', 't', 't', 68);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (32, 'Long term conditions services', 'Healthcare', 't', 't', 67);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (33, 'Rehabilitation services', 'Healthcare', 't', 't', 69);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (34, 'Residential substance misuse treatment/ rehabilitation services', 'Healthcare', 't', 't', 70);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (36, 'Specialist college services', 'Other', 't', 't', 60);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (24, 'Care home services with nursing', 'Adult residential', 't', 't', 1);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (25, 'Care home services without nursing', 'Adult residential', 't', 't', 2);
insert into cqc.services (id, name, category, iscqcregistered, ismain, reportingID) values (35, 'Live-in care', 'Other', 't', 'f', 73);

----Service Capacities
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question", "Type") values (1, 24, 1, 'How many beds do you currently have?', 'Capacity');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question", "Type") values (2, 24, 2, 'How many of those beds are currently used?', 'Utilisation');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question", "Type") values (3, 25, 1, 'How many beds do you currently have?', 'Capacity');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question", "Type") values (4, 25, 2, 'How many of those beds are currently used?', 'Utilisation');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question", "Type") values (5, 13, 1, 'Number of people receiving care on the completion date', 'Utilisation');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question", "Type") values (6, 12, 1, 'How many beds do you currently have?', 'Capacity');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question", "Type") values (7, 12, 2, 'How many of those beds are currently used?', 'Utilisation');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question", "Type") values (8, 9, 1, 'How many places do you currently have?', 'Capacity');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question", "Type") values (9, 9, 2, 'Number of people using the service on the completion date', 'Utilisation');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question", "Type") values (10, 10, 1, 'How many places do you currently have?', 'Capacity');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question", "Type") values (11, 10, 2, 'Number of people using the service on the completion date', 'Utilisation');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question", "Type") values (12, 20, 1, 'Number of people using the service on the completion date', 'Utilisation');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question", "Type") values (13, 22, 1, 'Number of people receiving care on the completion date', 'Utilisation');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question", "Type") values (14, 35, 1, 'Number of people receiving care on the completion date', 'Utilisation');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question", "Type") values (15, 11, 1, 'Number of people using the service on the completion date', 'Utilisation');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question", "Type") values (16, 18, 1, 'Number of people using the service on the completion date', 'Utilisation');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question", "Type") values (17, 21, 1, 'Number of people receiving care on the completion date', 'Utilisation');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question", "Type") values (18, 23, 1, 'Number of people using the service on the completion date', 'Utilisation');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Question", "Sequence", "Type") values (19, 19, 'Number of people using the service on the completion date', 2, 'Utilisation');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Question", "Sequence", "Type") values (20, 19, 'How many places do you currently have?', 1, 'Capacity');

----Jobs

insert into cqc."Job" ("JobID", "JobName") values (1, 'Activities worker or co-ordinator');
insert into cqc."Job" ("JobID", "JobName") values (2, 'Administrative / office staff not care-providing');
insert into cqc."Job" ("JobID", "JobName") values (3, 'Advice, Guidance and Advocacy');
insert into cqc."Job" ("JobID", "JobName") values (4, 'Allied Health Professional (not Occupational Therapist)');
insert into cqc."Job" ("JobID", "JobName") values (5, 'Ancillary staff not care-providing');
insert into cqc."Job" ("JobID", "JobName") values (6, 'Any childrens / young people''s job role');
insert into cqc."Job" ("JobID", "JobName") values (7, 'Assessment Officer');
insert into cqc."Job" ("JobID", "JobName") values (8, 'Care Coordinator');
insert into cqc."Job" ("JobID", "JobName") values (9, 'Care Navigator');
insert into cqc."Job" ("JobID", "JobName") values (10, 'Care Worker');
insert into cqc."Job" ("JobID", "JobName") values (11, 'Community, Support and Outreach Work');
insert into cqc."Job" ("JobID", "JobName") values (12, 'Employment Support');
insert into cqc."Job" ("JobID", "JobName") values (13, 'First Line Manager');
insert into cqc."Job" ("JobID", "JobName") values (14, 'Managers and staff care-related but not care-providing');
insert into cqc."Job" ("JobID", "JobName") values (15, 'Middle Management');
insert into cqc."Job" ("JobID", "JobName") values (16, 'Nursing Assistant');
insert into cqc."Job" ("JobID", "JobName") values (17, 'Nursing Associate');
insert into cqc."Job" ("JobID", "JobName") values (18, 'Occupational Therapist');
insert into cqc."Job" ("JobID", "JobName") values (19, 'Occupational Therapist Assistant');
insert into cqc."Job" ("JobID", "JobName") values (20, 'Other job roles directly involved in providing care');
insert into cqc."Job" ("JobID", "JobName") values (21, 'Other job roles not directly involved in providing care');
insert into cqc."Job" ("JobID", "JobName") values (22, 'Registered Manager');
insert into cqc."Job" ("JobID", "JobName") values (23, 'Registered Nurse');
insert into cqc."Job" ("JobID", "JobName") values (24, 'Safeguarding & Reviewing Officer');
insert into cqc."Job" ("JobID", "JobName") values (25, 'Senior Care Worker');
insert into cqc."Job" ("JobID", "JobName") values (26, 'Senior Management');
insert into cqc."Job" ("JobID", "JobName") values (27, 'Social Worker');
insert into cqc."Job" ("JobID", "JobName") values (28, 'Supervisor');
insert into cqc."Job" ("JobID", "JobName") values (29, 'Technician');


INSERT INTO cqc."Cssr" ("CssrID", "CssR", "LocalAuthority", "LocalCustodianCode", "Region", "RegionID", "NmdsIDLetter") VALUES 
(807, 'West Sussex', 'Adur', 3805, 'South East', 6, 'H'),
(102, 'Cumbria', 'Allerdale', 905, 'North West', 5, 'F'),
(506, 'Derbyshire', 'Amber Valley', 1005, 'East Midlands', 2, 'C'),
(807, 'West Sussex', 'Arun', 3810, 'South East', 6, 'H'),
(511, 'Nottinghamshire', 'Ashfield', 3005, 'East Midlands', 2, 'C'),
(820, 'Kent', 'Ashford', 2205, 'South East', 6, 'H'),
(612, 'Buckinghamshire', 'Aylesbury Vale', 405, 'South East', 6, 'H'),
(609, 'Suffolk', 'Babergh', 3505, 'Eastern', 1, 'I'),
(716, 'Barking & Dagenham', 'Barking and Dagenham', 5060, 'London', 3, 'G'),
(717, 'Barnet', 'Barnet', 5090, 'London', 3, 'G'),
(204, 'Barnsley', 'Barnsley', 4405, 'Yorkshire and the Humber', 9, 'J'),
(102, 'Cumbria', 'Barrow-in-Furness', 910, 'North West', 5, 'F'),
(620, 'Essex', 'Basildon', 1505, 'Eastern', 1, 'I'),
(812, 'Hampshire', 'Basingstoke and Deane', 1705, 'South East', 6, 'H'),
(511, 'Nottinghamshire', 'Bassetlaw', 3010, 'East Midlands', 2, 'C'),
(908, 'Bath and North East Somerset', 'Bath and North East Somerset', 114, 'South West', 7, 'D'),
(996, 'Bedford', 'Bedford', 235, 'Eastern', 1, 'I'),
(718, 'Bexley', 'Bexley', 5120, 'London', 3, 'G'),
(406, 'Birmingham', 'Birmingham', 4605, 'West Midlands', 8, 'E'),
(508, 'Leicestershire', 'Blaby', 2405, 'East Midlands', 2, 'C'),
(324, 'Blackburn with Darwen', 'Blackburn with Darwen', 2372, 'North West', 5, 'F'),
(325, 'Blackpool', 'Blackpool', 2373, 'North West', 5, 'F'),
(506, 'Derbyshire', 'Bolsover', 1010, 'East Midlands', 2, 'C'),
(304, 'Bolton', 'Bolton', 4205, 'North West', 5, 'F'),
(503, 'Lincolnshire', 'Boston', 2505, 'East Midlands', 2, 'C'),
(810, 'Bournemouth', 'Bournemouth', 1250, 'South West', 7, 'D'),
(614, 'Bracknell Forest', 'Bracknell Forest', 335, 'South East', 6, 'H'),
(209, 'Bradford', 'Bradford', 4705, 'Yorkshire and the Humber', 9, 'J'),
(620, 'Essex', 'Braintree', 1510, 'Eastern', 1, 'I'),
(607, 'Norfolk', 'Breckland', 2605, 'Eastern', 1, 'I'),
(719, 'Brent', 'Brent', 5150, 'London', 3, 'G'),
(620, 'Essex', 'Brentwood', 1515, 'Eastern', 1, 'I'),
(816, 'Brighton & Hove', 'Brighton and Hove', 1445, 'South East', 6, 'H'),
(607, 'Norfolk', 'Broadland', 2610, 'Eastern', 1, 'I'),
(720, 'Bromley', 'Bromley', 5180, 'London', 3, 'G'),
(416, 'Worcestershire', 'Bromsgrove', 1805, 'West Midlands', 8, 'E'),
(606, 'Hertfordshire', 'Broxbourne', 1905, 'Eastern', 1, 'I'),
(511, 'Nottinghamshire', 'Broxtowe', 3015, 'East Midlands', 2, 'C'),
(323, 'Lancashire', 'Burnley', 2315, 'North West', 5, 'F'),
(305, 'Bury', 'Bury', 4210, 'North West', 5, 'F'),
(210, 'Calderdale', 'Calderdale', 4710, 'Yorkshire and the Humber', 9, 'J'),
(623, 'Cambridgeshire', 'Cambridge', 505, 'Eastern', 1, 'I'),
(702, 'Camden', 'Camden', 5210, 'London', 3, 'G'),
(413, 'Staffordshire', 'Cannock Chase', 3405, 'West Midlands', 8, 'E'),
(820, 'Kent', 'Canterbury', 2210, 'South East', 6, 'H'),
(102, 'Cumbria', 'Carlisle', 915, 'North West', 5, 'F'),
(620, 'Essex', 'Castle Point', 1520, 'Eastern', 1, 'I'),
(997, 'Central Bedfordshire', 'Central Bedfordshire', 240, 'Eastern', 1, 'I'),
(508, 'Leicestershire', 'Charnwood', 2410, 'East Midlands', 2, 'C'),
(620, 'Essex', 'Chelmsford', 1525, 'Eastern', 1, 'I'),
(904, 'Gloucestershire', 'Cheltenham', 1605, 'South West', 7, 'D'),
(608, 'Oxfordshire', 'Cherwell', 3105, 'South East', 6, 'H'),
(998, 'Cheshire East', 'Cheshire East', 660, 'North West', 5, 'F'),
(999, 'Cheshire West & Chester', 'Cheshire West and Chester', 665, 'North West', 5, 'F'),
(506, 'Derbyshire', 'Chesterfield', 1015, 'East Midlands', 2, 'C'),
(807, 'West Sussex', 'Chichester', 3815, 'South East', 6, 'H'),
(612, 'Buckinghamshire', 'Chiltern', 415, 'South East', 6, 'H'),
(323, 'Lancashire', 'Chorley', 2320, 'North West', 5, 'F'),
(809, 'Dorset', 'Christchurch', 1210, 'South West', 7, 'D'),
(909, 'Bristol', 'City of Bristol', 116, 'South West', 7, 'D'),
(714, 'City of London', 'City of London', 5030, 'London', 3, 'G'),
(620, 'Essex', 'Colchester', 1530, 'Eastern', 1, 'I'),
(102, 'Cumbria', 'Copeland', 920, 'North West', 5, 'F'),
(504, 'Northamptonshire', 'Corby', 2805, 'East Midlands', 2, 'C'),
(902, 'Cornwall', 'Cornwall', 840, 'South West', 7, 'D'),
(904, 'Gloucestershire', 'Cotswold', 1610, 'South West', 7, 'D'),
(116, 'Durham', 'County Durham', 1355, 'North East', 4, 'B'),
(407, 'Coventry', 'Coventry', 4610, 'West Midlands', 8, 'E'),
(218, 'North Yorkshire', 'Craven', 2705, 'Yorkshire and the Humber', 9, 'J'),
(807, 'West Sussex', 'Crawley', 3820, 'South East', 6, 'H'),
(721, 'Croydon', 'Croydon', 5240, 'London', 3, 'G'),
(606, 'Hertfordshire', 'Dacorum', 1910, 'Eastern', 1, 'I'),
(117, 'Darlington', 'Darlington', 1350, 'North East', 4, 'B'),
(820, 'Kent', 'Dartford', 2215, 'South East', 6, 'H'),
(504, 'Northamptonshire', 'Daventry', 2810, 'East Midlands', 2, 'C'),
(507, 'Derby', 'Derby', 1055, 'East Midlands', 2, 'C'),
(506, 'Derbyshire', 'Derbyshire Dales', 1045, 'East Midlands', 2, 'C'),
(205, 'Doncaster', 'Doncaster', 4410, 'Yorkshire and the Humber', 9, 'J'),
(820, 'Kent', 'Dover', 2220, 'South East', 6, 'H'),
(408, 'Dudley', 'Dudley', 4615, 'West Midlands', 8, 'E'),
(722, 'Ealing', 'Ealing', 5270, 'London', 3, 'G'),
(623, 'Cambridgeshire', 'East Cambridgeshire', 510, 'Eastern', 1, 'I'),
(912, 'Devon', 'East Devon', 1105, 'South West', 7, 'D'),
(809, 'Dorset', 'East Dorset', 1240, 'South West', 7, 'D'),
(812, 'Hampshire', 'East Hampshire', 1710, 'South East', 6, 'H'),
(606, 'Hertfordshire', 'East Hertfordshire', 1915, 'Eastern', 1, 'I'),
(503, 'Lincolnshire', 'East Lindsey', 2510, 'East Midlands', 2, 'C'),
(504, 'Northamptonshire', 'East Northamptonshire', 2815, 'East Midlands', 2, 'C'),
(214, 'East Riding of Yorkshire', 'East Riding of Yorkshire', 2001, 'Yorkshire and the Humber', 9, 'J'),
(413, 'Staffordshire', 'East Staffordshire', 3410, 'West Midlands', 8, 'E'),
(815, 'East Sussex', 'Eastbourne', 1410, 'South East', 6, 'H'),
(812, 'Hampshire', 'Eastleigh', 1715, 'South East', 6, 'H'),
(102, 'Cumbria', 'Eden', 925, 'North West', 5, 'F'),
(805, 'Surrey', 'Elmbridge', 3605, 'South East', 6, 'H'),
(723, 'Enfield', 'Enfield', 5300, 'London', 3, 'G'),
(620, 'Essex', 'Epping Forest', 1535, 'Eastern', 1, 'I'),
(805, 'Surrey', 'Epsom and Ewell', 3610, 'South East', 6, 'H'),
(506, 'Derbyshire', 'Erewash', 1025, 'East Midlands', 2, 'C'),
(912, 'Devon', 'Exeter', 1110, 'South West', 7, 'D'),
(812, 'Hampshire', 'Fareham', 1720, 'South East', 6, 'H'),
(623, 'Cambridgeshire', 'Fenland', 515, 'Eastern', 1, 'I'),
(609, 'Suffolk', 'Forest Heath', 3510, 'Eastern', 1, 'I'),
(904, 'Gloucestershire', 'Forest of Dean', 1615, 'South West', 7, 'D'),
(323, 'Lancashire', 'Fylde', 2325, 'North West', 5, 'F'),
(106, 'Gateshead', 'Gateshead', 4505, 'North East', 4, 'B'),
(511, 'Nottinghamshire', 'Gedling', 3020, 'East Midlands', 2, 'C'),
(904, 'Gloucestershire', 'Gloucester', 1620, 'South West', 7, 'D'),
(812, 'Hampshire', 'Gosport', 1725, 'South East', 6, 'H'),
(820, 'Kent', 'Gravesham', 2230, 'South East', 6, 'H'),
(607, 'Norfolk', 'Great Yarmouth', 2615, 'Eastern', 1, 'I'),
(703, 'Greenwich', 'Greenwich', 5330, 'London', 3, 'G'),
(805, 'Surrey', 'Guildford', 3615, 'South East', 6, 'H'),
(704, 'Hackney', 'Hackney', 5360, 'London', 3, 'G'),
(321, 'Halton', 'Halton', 650, 'North West', 5, 'F'),
(218, 'North Yorkshire', 'Hambleton', 2710, 'Yorkshire and the Humber', 9, 'J'),
(705, 'Hammersmith & Fulham', 'Hammersmith and Fulham', 5390, 'London', 3, 'G'),
(508, 'Leicestershire', 'Harborough', 2415, 'East Midlands', 2, 'C'),
(724, 'Haringey', 'Haringey', 5420, 'London', 3, 'G'),
(620, 'Essex', 'Harlow', 1540, 'Eastern', 1, 'I'),
(218, 'North Yorkshire', 'Harrogate', 2715, 'Yorkshire and the Humber', 9, 'J'),
(725, 'Harrow', 'Harrow', 5450, 'London', 3, 'G'),
(812, 'Hampshire', 'Hart', 1730, 'South East', 6, 'H'),
(111, 'Hartlepool', 'Hartlepool', 724, 'North East', 4, 'B'),
(815, 'East Sussex', 'Hastings', 1415, 'South East', 6, 'H'),
(812, 'Hampshire', 'Havant', 1735, 'South East', 6, 'H'),
(726, 'Havering', 'Havering', 5480, 'London', 3, 'G'),
(415, 'Herefordshire', 'Herefordshire', 1850, 'West Midlands', 8, 'E'),
(606, 'Hertfordshire', 'Hertsmere', 1920, 'Eastern', 1, 'I'),
(506, 'Derbyshire', 'High Peak', 1030, 'East Midlands', 2, 'C'),
(727, 'Hillingdon', 'Hillingdon', 5510, 'London', 3, 'G'),
(508, 'Leicestershire', 'Hinckley and Bosworth', 2420, 'East Midlands', 2, 'C'),
(807, 'West Sussex', 'Horsham', 3825, 'South East', 6, 'H'),
(728, 'Hounslow', 'Hounslow', 5540, 'London', 3, 'G'),
(623, 'Cambridgeshire', 'Huntingdonshire', 520, 'Eastern', 1, 'I'),
(323, 'Lancashire', 'Hyndburn', 2330, 'North West', 5, 'F'),
(609, 'Suffolk', 'Ipswich', 3515, 'Eastern', 1, 'I'),
(803, 'Isle of Wight', 'Isle of Wight', 2114, 'South East', 6, 'H'),
(906, 'Isles of Scilly', 'Isles of Scilly', 835, 'South West', 7, 'D'),
(706, 'Islington', 'Islington', 5570, 'London', 3, 'G'),
(707, 'Kensington & Chelsea', 'Kensington and Chelsea', 5600, 'London', 3, 'G'),
(504, 'Northamptonshire', 'Kettering', 2820, 'East Midlands', 2, 'C'),
(607, 'Norfolk', 'King`s Lynn and West Norfolk', 2635, 'Eastern', 1, 'I'),
(215, 'Kingston upon Hull', 'Kingston upon Hull', 2004, 'Yorkshire and the Humber', 9, 'J'),
(729, 'Kingston upon Thames', 'Kingston upon Thames', 5630, 'London', 3, 'G'),
(211, 'Kirklees', 'Kirklees', 4715, 'Yorkshire and the Humber', 9, 'J'),
(315, 'Knowsley', 'Knowsley', 4305, 'North West', 5, 'F'),
(708, 'Lambeth', 'Lambeth', 5660, 'London', 3, 'G'),
(323, 'Lancashire', 'Lancaster', 2335, 'North West', 5, 'F'),
(212, 'Leeds', 'Leeds', 4720, 'Yorkshire and the Humber', 9, 'J'),
(509, 'Leicester', 'Leicester', 2465, 'East Midlands', 2, 'C'),
(815, 'East Sussex', 'Lewes', 1425, 'South East', 6, 'H'),
(709, 'Lewisham', 'Lewisham', 5690, 'London', 3, 'G'),
(413, 'Staffordshire', 'Lichfield', 3415, 'West Midlands', 8, 'E'),
(503, 'Lincolnshire', 'Lincoln', 2515, 'East Midlands', 2, 'C'),
(316, 'Liverpool', 'Liverpool', 4310, 'North West', 5, 'F'),
(611, 'Luton', 'Luton', 230, 'Eastern', 1, 'I'),
(820, 'Kent', 'Maidstone', 2235, 'South East', 6, 'H'),
(620, 'Essex', 'Maldon', 1545, 'Eastern', 1, 'I'),
(416, 'Worcestershire', 'Malvern Hills', 1820, 'West Midlands', 8, 'E'),
(306, 'Manchester', 'Manchester', 4215, 'North West', 5, 'F'),
(511, 'Nottinghamshire', 'Mansfield', 3025, 'East Midlands', 2, 'C'),
(821, 'Medway', 'Medway', 2280, 'South East', 6, 'H'),
(508, 'Leicestershire', 'Melton', 2430, 'East Midlands', 2, 'C'),
(905, 'Somerset', 'Mendip', 3305, 'South West', 7, 'D'),
(730, 'Merton', 'Merton', 5720, 'London', 3, 'G'),
(912, 'Devon', 'Mid Devon', 1135, 'South West', 7, 'D'),
(609, 'Suffolk', 'Mid Suffolk', 3520, 'Eastern', 1, 'I'),
(807, 'West Sussex', 'Mid Sussex', 3830, 'South East', 6, 'H'),
(112, 'Middlesbrough', 'Middlesbrough', 734, 'North East', 4, 'B'),
(613, 'Milton Keynes', 'Milton Keynes', 435, 'South East', 6, 'H'),
(805, 'Surrey', 'Mole Valley', 3620, 'South East', 6, 'H'),
(812, 'Hampshire', 'New Forest', 1740, 'South East', 6, 'H'),
(511, 'Nottinghamshire', 'Newark and Sherwood', 3030, 'East Midlands', 2, 'C'),
(107, 'Newcastle upon Tyne', 'Newcastle upon Tyne', 4510, 'North East', 4, 'B'),
(413, 'Staffordshire', 'Newcastle-under-Lyme', 3420, 'West Midlands', 8, 'E'),
(731, 'Newham', 'Newham', 5750, 'London', 3, 'G'),
(912, 'Devon', 'North Devon', 1115, 'South West', 7, 'D'),
(809, 'Dorset', 'North Dorset', 1215, 'South West', 7, 'D'),
(506, 'Derbyshire', 'North East Derbyshire', 1035, 'East Midlands', 2, 'C'),
(216, 'North East Lincolnshire', 'North East Lincolnshire', 2002, 'Yorkshire and the Humber', 9, 'J'),
(606, 'Hertfordshire', 'North Hertfordshire', 1925, 'Eastern', 1, 'I'),
(503, 'Lincolnshire', 'North Kesteven', 2520, 'East Midlands', 2, 'C'),
(217, 'North Lincolnshire', 'North Lincolnshire', 2003, 'Yorkshire and the Humber', 9, 'J'),
(607, 'Norfolk', 'North Norfolk', 2620, 'Eastern', 1, 'I'),
(910, 'North Somerset', 'North Somerset', 121, 'South West', 7, 'D'),
(108, 'North Tyneside', 'North Tyneside', 4515, 'North East', 4, 'B'),
(404, 'Warwickshire', 'North Warwickshire', 3705, 'West Midlands', 8, 'E'),
(508, 'Leicestershire', 'North West Leicestershire', 2435, 'East Midlands', 2, 'C'),
(504, 'Northamptonshire', 'Northampton', 2825, 'East Midlands', 2, 'C'),
(104, 'Northumberland', 'Northumberland', 2935, 'North East', 4, 'B'),
(607, 'Norfolk', 'Norwich', 2625, 'Eastern', 1, 'I'),
(512, 'Nottingham', 'Nottingham', 3060, 'East Midlands', 2, 'C'),
(404, 'Warwickshire', 'Nuneaton and Bedworth', 3710, 'West Midlands', 8, 'E'),
(508, 'Leicestershire', 'Oadby and Wigston', 2440, 'East Midlands', 2, 'C'),
(307, 'Oldham', 'Oldham', 4220, 'North West', 5, 'F'),
(608, 'Oxfordshire', 'Oxford', 3110, 'South East', 6, 'H'),
(323, 'Lancashire', 'Pendle', 2340, 'North West', 5, 'F'),
(624, 'Peterborough', 'Peterborough', 540, 'Eastern', 1, 'I'),
(913, 'Plymouth', 'Plymouth', 1160, 'South West', 7, 'D'),
(811, 'Poole', 'Poole', 1255, 'South West', 7, 'D'),
(813, 'Portsmouth', 'Portsmouth', 1775, 'South East', 6, 'H'),
(323, 'Lancashire', 'Preston', 2345, 'North West', 5, 'F'),
(809, 'Dorset', 'Purbeck', 1225, 'South West', 7, 'D'),
(616, 'Reading', 'Reading', 345, 'South East', 6, 'H'),
(732, 'Redbridge', 'Redbridge', 5780, 'London', 3, 'G'),
(113, 'Redcar & Cleveland', 'Redcar and Cleveland', 728, 'North East', 4, 'B'),
(416, 'Worcestershire', 'Redditch', 1825, 'West Midlands', 8, 'E'),
(805, 'Surrey', 'Reigate and Banstead', 3625, 'South East', 6, 'H'),
(323, 'Lancashire', 'Ribble Valley', 2350, 'North West', 5, 'F'),
(733, 'Richmond upon Thames', 'Richmond upon Thames', 5810, 'London', 3, 'G'),
(218, 'North Yorkshire', 'Richmondshire', 2720, 'Yorkshire and the Humber', 9, 'J'),
(308, 'Rochdale', 'Rochdale', 4225, 'North West', 5, 'F'),
(620, 'Essex', 'Rochford', 1550, 'Eastern', 1, 'I'),
(323, 'Lancashire', 'Rossendale', 2355, 'North West', 5, 'F'),
(815, 'East Sussex', 'Rother', 1430, 'South East', 6, 'H'),
(206, 'Rotherham', 'Rotherham', 4415, 'Yorkshire and the Humber', 9, 'J'),
(404, 'Warwickshire', 'Rugby', 3715, 'West Midlands', 8, 'E'),
(805, 'Surrey', 'Runnymede', 3630, 'South East', 6, 'H'),
(511, 'Nottinghamshire', 'Rushcliffe', 3040, 'East Midlands', 2, 'C'),
(812, 'Hampshire', 'Rushmoor', 1750, 'South East', 6, 'H'),
(510, 'Rutland', 'Rutland', 2470, 'East Midlands', 2, 'C'),
(218, 'North Yorkshire', 'Ryedale', 2725, 'Yorkshire and the Humber', 9, 'J'),
(309, 'Salford', 'Salford', 4230, 'North West', 5, 'F'),
(409, 'Sandwell', 'Sandwell', 4620, 'West Midlands', 8, 'E'),
(218, 'North Yorkshire', 'Scarborough', 2730, 'Yorkshire and the Humber', 9, 'J'),
(905, 'Somerset', 'Sedgemoor', 3310, 'South West', 7, 'D'),
(317, 'Sefton', 'Sefton', 4320, 'North West', 5, 'F'),
(218, 'North Yorkshire', 'Selby', 2735, 'Yorkshire and the Humber', 9, 'J'),
(820, 'Kent', 'Sevenoaks', 2245, 'South East', 6, 'H'),
(207, 'Sheffield', 'Sheffield', 4420, 'Yorkshire and the Humber', 9, 'J'),
(820, 'Kent', 'Shepway', 2250, 'South East', 6, 'H'),
(417, 'Shropshire', 'Shropshire', 3245, 'West Midlands', 8, 'E'),
(617, 'Slough', 'Slough', 350, 'South East', 6, 'H'),
(410, 'Solihull', 'Solihull', 4625, 'West Midlands', 8, 'E'),
(612, 'Buckinghamshire', 'South Bucks', 410, 'South East', 6, 'H'),
(623, 'Cambridgeshire', 'South Cambridgeshire', 530, 'Eastern', 1, 'I'),
(506, 'Derbyshire', 'South Derbyshire', 1040, 'East Midlands', 2, 'C'),
(911, 'South Gloucestershire', 'South Gloucestershire', 119, 'South West', 7, 'D'),
(912, 'Devon', 'South Hams', 1125, 'South West', 7, 'D'),
(503, 'Lincolnshire', 'South Holland', 2525, 'East Midlands', 2, 'C'),
(503, 'Lincolnshire', 'South Kesteven', 2530, 'East Midlands', 2, 'C'),
(102, 'Cumbria', 'South Lakeland', 930, 'North West', 5, 'F'),
(607, 'Norfolk', 'South Norfolk', 2630, 'Eastern', 1, 'I'),
(504, 'Northamptonshire', 'South Northamptonshire', 2830, 'East Midlands', 2, 'C'),
(608, 'Oxfordshire', 'South Oxfordshire', 3115, 'South East', 6, 'H'),
(323, 'Lancashire', 'South Ribble', 2360, 'North West', 5, 'F'),
(905, 'Somerset', 'South Somerset', 3325, 'South West', 7, 'D'),
(413, 'Staffordshire', 'South Staffordshire', 3430, 'West Midlands', 8, 'E'),
(109, 'South Tyneside', 'South Tyneside', 4520, 'North East', 4, 'B'),
(814, 'Southampton', 'Southampton', 1780, 'South East', 6, 'H'),
(621, 'Southend on Sea', 'Southend-on-Sea', 1590, 'Eastern', 1, 'I'),
(710, 'Southwark', 'Southwark', 5840, 'London', 3, 'G'),
(805, 'Surrey', 'Spelthorne', 3635, 'South East', 6, 'H'),
(606, 'Hertfordshire', 'St Albans', 1930, 'Eastern', 1, 'I'),
(609, 'Suffolk', 'St. Edmundsbury', 3525, 'Eastern', 1, 'I'),
(318, 'St Helens', 'St. Helens', 4315, 'North West', 5, 'F'),
(413, 'Staffordshire', 'Stafford', 3425, 'West Midlands', 8, 'E'),
(413, 'Staffordshire', 'Staffordshire Moorlands', 3435, 'West Midlands', 8, 'E'),
(606, 'Hertfordshire', 'Stevenage', 1935, 'Eastern', 1, 'I'),
(310, 'Stockport', 'Stockport', 4235, 'North West', 5, 'F'),
(114, 'Stockton on Tees', 'Stockton-on-Tees', 738, 'North East', 4, 'B'),
(414, 'Stoke on Trent', 'Stoke-on-Trent', 3455, 'West Midlands', 8, 'E'),
(404, 'Warwickshire', 'Stratford-on-Avon', 3720, 'West Midlands', 8, 'E'),
(904, 'Gloucestershire', 'Stroud', 1625, 'South West', 7, 'D'),
(609, 'Suffolk', 'Suffolk Coastal', 3530, 'Eastern', 1, 'I'),
(110, 'Sunderland', 'Sunderland', 4525, 'North East', 4, 'B'),
(805, 'Surrey', 'Surrey Heath', 3640, 'South East', 6, 'H'),
(734, 'Sutton', 'Sutton', 5870, 'London', 3, 'G'),
(820, 'Kent', 'Swale', 2255, 'South East', 6, 'H'),
(819, 'Swindon', 'Swindon', 3935, 'South West', 7, 'D'),
(311, 'Tameside', 'Tameside', 4240, 'North West', 5, 'F'),
(413, 'Staffordshire', 'Tamworth', 3445, 'West Midlands', 8, 'E'),
(805, 'Surrey', 'Tandridge', 3645, 'South East', 6, 'H'),
(905, 'Somerset', 'Taunton Deane', 3315, 'South West', 7, 'D'),
(912, 'Devon', 'Teignbridge', 1130, 'South West', 7, 'D'),
(418, 'Telford & Wrekin', 'Telford and Wrekin', 3240, 'West Midlands', 8, 'E'),
(620, 'Essex', 'Tendring', 1560, 'Eastern', 1, 'I'),
(812, 'Hampshire', 'Test Valley', 1760, 'South East', 6, 'H'),
(904, 'Gloucestershire', 'Tewkesbury', 1630, 'South West', 7, 'D'),
(820, 'Kent', 'Thanet', 2260, 'South East', 6, 'H'),
(606, 'Hertfordshire', 'Three Rivers', 1940, 'Eastern', 1, 'I'),
(622, 'Thurrock', 'Thurrock', 1595, 'Eastern', 1, 'I'),
(820, 'Kent', 'Tonbridge and Malling', 2265, 'South East', 6, 'H'),
(914, 'Torbay', 'Torbay', 1165, 'South West', 7, 'D'),
(912, 'Devon', 'Torridge', 1145, 'South West', 7, 'D'),
(711, 'Tower Hamlets', 'Tower Hamlets', 5900, 'London', 3, 'G'),
(312, 'Trafford', 'Trafford', 4245, 'North West', 5, 'F'),
(820, 'Kent', 'Tunbridge Wells', 2270, 'South East', 6, 'H'),
(620, 'Essex', 'Uttlesford', 1570, 'Eastern', 1, 'I'),
(608, 'Oxfordshire', 'Vale of White Horse', 3120, 'South East', 6, 'H'),
(213, 'Wakefield', 'Wakefield', 4725, 'Yorkshire and the Humber', 9, 'J'),
(411, 'Walsall', 'Walsall', 4630, 'West Midlands', 8, 'E'),
(735, 'Waltham Forest', 'Waltham Forest', 5930, 'London', 3, 'G'),
(712, 'Wandsworth', 'Wandsworth', 5960, 'London', 3, 'G'),
(322, 'Warrington', 'Warrington', 655, 'North West', 5, 'F'),
(404, 'Warwickshire', 'Warwick', 3725, 'West Midlands', 8, 'E'),
(606, 'Hertfordshire', 'Watford', 1945, 'Eastern', 1, 'I'),
(609, 'Suffolk', 'Waveney', 3535, 'Eastern', 1, 'I'),
(805, 'Surrey', 'Waverley', 3650, 'South East', 6, 'H'),
(815, 'East Sussex', 'Wealden', 1435, 'South East', 6, 'H'),
(504, 'Northamptonshire', 'Wellingborough', 2835, 'East Midlands', 2, 'C'),
(606, 'Hertfordshire', 'Welwyn Hatfield', 1950, 'Eastern', 1, 'I'),
(615, 'West Berkshire', 'West Berkshire', 340, 'South East', 6, 'H'),
(912, 'Devon', 'West Devon', 1150, 'South West', 7, 'D'),
(809, 'Dorset', 'West Dorset', 1230, 'South West', 7, 'D'),
(323, 'Lancashire', 'West Lancashire', 2365, 'North West', 5, 'F'),
(503, 'Lincolnshire', 'West Lindsey', 2535, 'East Midlands', 2, 'C'),
(608, 'Oxfordshire', 'West Oxfordshire', 3125, 'South East', 6, 'H'),
(905, 'Somerset', 'West Somerset', 3320, 'South West', 7, 'D'),
(713, 'Westminster', 'Westminster', 5990, 'London', 3, 'G'),
(809, 'Dorset', 'Weymouth and Portland', 1235, 'South West', 7, 'D'),
(313, 'Wigan', 'Wigan', 4250, 'North West', 5, 'F'),
(817, 'Wiltshire', 'Wiltshire', 3940, 'South West', 7, 'D'),
(812, 'Hampshire', 'Winchester', 1765, 'South East', 6, 'H'),
(618, 'Windsor & Maidenhead', 'Windsor and Maidenhead', 355, 'South East', 6, 'H'),
(319, 'Wirral', 'Wirral', 4325, 'North West', 5, 'F'),
(805, 'Surrey', 'Woking', 3655, 'South East', 6, 'H'),
(619, 'Wokingham', 'Wokingham', 360, 'South East', 6, 'H'),
(412, 'Wolverhampton', 'Wolverhampton', 4635, 'West Midlands', 8, 'E'),
(416, 'Worcestershire', 'Worcester', 1835, 'West Midlands', 8, 'E'),
(807, 'West Sussex', 'Worthing', 3835, 'South East', 6, 'H'),
(416, 'Worcestershire', 'Wychavon', 1840, 'West Midlands', 8, 'E'),
(612, 'Buckinghamshire', 'Wycombe', 425, 'South East', 6, 'H'),
(323, 'Lancashire', 'Wyre', 2370, 'North West', 5, 'F'),
(416, 'Worcestershire', 'Wyre Forest', 1845, 'West Midlands', 8, 'E'),
(219, 'York', 'York', 2741, 'Yorkshire and the Humber', 9, 'J');

-- password reset - https://trello.com/c/isgnA7X5
CREATE SEQUENCE IF NOT EXISTS cqc."PasswdResetTracking_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    
CREATE TABLE IF NOT EXISTS cqc."PasswdResetTracking" (
    "ID" INTEGER NOT NULL PRIMARY KEY,
	"UserFK" INTEGER NOT NULL,
    "Created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    "Expires" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW() + INTERVAL '24 hour',
    "ResetUuid"  UUID NOT NULL,
    "Completed" TIMESTAMP NULL,
	CONSTRAINT "PasswdResetTracking_User_fk" FOREIGN KEY ("UserFK") REFERENCES cqc."User" ("RegistrationID") MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
);
ALTER TABLE cqc."PasswdResetTracking" ALTER COLUMN "ID" SET DEFAULT nextval('cqc."PasswdResetTracking_seq"');
ALTER TABLE cqc."PasswdResetTracking" OWNER TO sfcadmin;

CREATE TYPE cqc."UserAuditChangeType" AS ENUM (
    'created',
    'updated',
    'saved',
    'changed',
    'passwdReset',
    'loginSuccess',
    'loginFailed',
    'loginWhileLocked',
    'delete'
);

CREATE TABLE IF NOT EXISTS cqc."UserAudit" (
	"ID" SERIAL NOT NULL PRIMARY KEY,
	"UserFK" INTEGER NOT NULL,
	"Username" VARCHAR(120) NOT NULL,
	"When" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
	"EventType" cqc."UserAuditChangeType" NOT NULL,
	"PropertyName" VARCHAR(100) NULL,
	"ChangeEvents" JSONB NULL,
	CONSTRAINT "WorkerAudit_User_fk" FOREIGN KEY ("UserFK") REFERENCES cqc."User" ("RegistrationID") MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
);
CREATE INDEX "UserAudit_UserFK" on cqc."UserAudit" ("UserFK");

CREATE SEQUENCE IF NOT EXISTS cqc."AddUserTracking_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    
CREATE TABLE IF NOT EXISTS cqc."AddUserTracking" (
    "ID" INTEGER NOT NULL PRIMARY KEY,
	"UserFK" INTEGER NOT NULL,
    "Created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    "Expires" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW() + INTERVAL '3 days',
    "AddUuid"  UUID NOT NULL,
    "RegisteredBy" VARCHAR(120) NOT NULL,
    "Completed" TIMESTAMP NULL,
	CONSTRAINT "AddUserTracking_User_fk" FOREIGN KEY ("UserFK") REFERENCES cqc."User" ("RegistrationID") MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
);
ALTER TABLE cqc."AddUserTracking" ALTER COLUMN "ID" SET DEFAULT nextval('cqc."AddUserTracking_seq"');

CREATE TYPE cqc."EstablishmentAuditChangeType" AS ENUM (
    'created',
    'updated',
    'saved',
    'changed',
    'deleted',
    'wdfEligible',
    'overalWdfEligible'
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

-- https://trello.com/c/QZzwclw6
DROP FUNCTION IF EXISTS cqc.wdfsummaryreport;
CREATE OR REPLACE FUNCTION cqc.wdfsummaryreport(effectiveDate DATE)
 RETURNS TABLE (
	"NmdsID" text,
    "EstablishmentID" integer,
    "EstablishmentName" text,
    "Address1" text,
    "Address2" text,
    "PostCode" text,
    "Region" text,
    "CSSR" text,
    "EstablishmentUpdated" timestamp without time zone,
		"NumberOfStaff" integer,
    "ParentID" integer,
    "OverallWdfEligibility" timestamp without time zone,
    "ParentNmdsID" text,
    "ParentEstablishmentID" integer,
    "ParentName" text,
    "WorkerCount" bigint,
    "WorkerCompletedCount" bigint
) 
AS $$
BEGIN
   RETURN QUERY select
	"Establishment"."NmdsID"::text,
	"Establishment"."EstablishmentID",
	"Establishment"."NameValue" AS "EstablishmentName",
	"Establishment"."Address1",
	"Establishment"."Address2",
	"Establishment"."PostCode",
	pcode.region as "Region",
	pcode.cssr as "CSSR",
	"Establishment".updated,
	"Establishment"."NumberOfStaffValue" AS "NumberOfStaff",
	"Establishment"."ParentID",
	"Establishment"."OverallWdfEligibility",
	parents."NmdsID"::text As "ParentNmdsID",
	parents."EstablishmentID" AS "ParentEstablishmentID",
	parents."NameValue" AS "ParentName",
	COUNT(workers."ID") filter (where workers."ID" is not null) as "WorkerCount",
    COUNT(workers."ID") filter (where workers."LastWdfEligibility" > effectiveDate) as "WorkerCompletedCount"
from cqc."Establishment"
	left join cqcref.pcode on pcode.postcode = "Establishment"."PostCode"
	left join cqc."Establishment" as parents on parents."EstablishmentID" = "Establishment"."ParentID"
	left join cqc."Worker" as workers on workers."EstablishmentFK" = "Establishment"."EstablishmentID" and workers."Archived"=false
where "Establishment"."Archived"=false
group by
	"Establishment"."NmdsID",
	"Establishment"."EstablishmentID",
	"Establishment"."NameValue",
	"Establishment"."Address1",
	"Establishment"."Address2",
	"Establishment"."PostCode",
	pcode.region,
	pcode.cssr,
	"Establishment".updated,
	"Establishment"."ParentID",
	"Establishment"."OverallWdfEligibility",
	parents."NmdsID",
	parents."EstablishmentID",
	parents."NameValue";
END; $$
LANGUAGE 'plpgsql';

-- select * from cqc.wdfsummaryreport('2019-04-01'::date)
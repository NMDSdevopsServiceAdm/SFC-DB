ALTER TABLE cqc."User" ADD COLUMN "IsPrimary" BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE cqc."User" ADD COLUMN "TribalID" INTEGER NULL;
ALTER TABLE cqc."Establishment" ADD COLUMN "TribalID" INTEGER NULL;
ALTER TABLE cqc."Worker" ADD COLUMN "TribalID" INTEGER NULL;

ALTER TABLE cqc."WorkerTraining" ADD COLUMN "TribalID" INTEGER NULL;
ALTER TABLE cqc."WorkerQualifications" ADD COLUMN "TribalID" INTEGER NULL;


ALTER TABLE cqc."EstablishmentServiceUsers" ADD CONSTRAINT establishment_establishmentserviceusers_fk FOREIGN KEY ("EstablishmentID")
        REFERENCES cqc."Establishment" ("EstablishmentID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION;
ALTER TABLE cqc."EstablishmentServiceUsers" ADD CONSTRAINT serviceusers_establishmentserviceusers_fk FOREIGN KEY ("ServiceUserID")
        REFERENCES cqc."ServiceUsers" ("ID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION;

-- https://trello.com/c/gVUD155s - forces lowercase on username and email - resets existing usernames and email.
update cqc."Login"
	set "Username" = lower("Username");

update cqc."User"
	set "EmailValue" = lower("EmailValue");

-- to migrate qualifications, it is necessary to remove the unique constraint on WorkerQualifications that ensures a given Worker can reference a given qualification only once (this logic breaks down on other qualifications)
ALTER TABLE cqc."WorkerQualifications" DROP CONSTRAINT "Workers_WorkerQualifications_unq";


/* alter table cqc."User" drop constraint "user_establishment_fk";
alter table cqc."User" add CONSTRAINT user_establishment_fk FOREIGN KEY ("EstablishmentID")
        REFERENCES cqc."Establishment" ("EstablishmentID");
		
alter table cqc."Worker" drop constraint "Worker_Establishment_fk";
alter table cqc."Worker" add CONSTRAINT "Worker_Establishment_fk" FOREIGN KEY ("EstablishmentFK")
        REFERENCES cqc."Establishment" ("EstablishmentID");
		
-- ---------------------------------------------
		
alter table cqc."EstablishmentAudit" drop constraint "EstablishmentAudit_User_fk";
alter table cqc."EstablishmentAudit" add CONSTRAINT "EstablishmentAudit_User_fk" FOREIGN KEY ("EstablishmentFK")
        REFERENCES cqc."Establishment" ("EstablishmentID");
		
alter table cqc."EstablishmentCapacity" drop constraint "EstablishmentServiceCapacity_Establishment_fk1";
alter table cqc."EstablishmentCapacity" add CONSTRAINT "EstablishmentServiceCapacity_Establishment_fk1" FOREIGN KEY ("EstablishmentID")
        REFERENCES cqc."Establishment" ("EstablishmentID");
		
alter table cqc."EstablishmentJobs" drop constraint "establishment_establishmentjobs_fk";
alter table cqc."EstablishmentJobs" add CONSTRAINT establishment_establishmentjobs_fk FOREIGN KEY ("EstablishmentID")
        REFERENCES cqc."Establishment" ("EstablishmentID");

alter table cqc."EstablishmentLocalAuthority" drop constraint "establishment_establishmentlocalauthority_fk";
alter table cqc."EstablishmentLocalAuthority" add CONSTRAINT establishment_establishmentlocalauthority_fk FOREIGN KEY ("EstablishmentID")
        REFERENCES cqc."Establishment" ("EstablishmentID");

alter table cqc."EstablishmentServiceUsers" drop constraint "establishment_establishmentserviceusers_fk";
alter table cqc."EstablishmentServiceUsers" add CONSTRAINT establishment_establishmentserviceusers_fk FOREIGN KEY ("EstablishmentID")
        REFERENCES cqc."Establishment" ("EstablishmentID");
		
alter table cqc."EstablishmentServices" drop constraint "estsrvc_estb_fk";
alter table cqc."EstablishmentServices" add CONSTRAINT estsrvc_estb_fk FOREIGN KEY ("EstablishmentID")
        REFERENCES cqc."Establishment" ("EstablishmentID"); */


-- temporarily suspend establishment location foreign key
ALTER TABLE cqc."Establishment" DROP CONSTRAINT estloc_fk_two;
ALTER TABLE cqc."Establishment" ADD CONSTRAINT estloc_fk FOREIGN KEY ("LocationID")
        REFERENCES cqcref.location (locationid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION;
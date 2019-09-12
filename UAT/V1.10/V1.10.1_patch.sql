-- https://trello.com/c/PgdL36yn - Change Request - Service Users "Other" Input field
ALTER TABLE cqc."EstablishmentServiceUsers" ADD COLUMN "Other" TEXT NULL;
ALTER TABLE cqc."ServiceUsers" ADD COLUMN "Other" BOOLEAN DEFAULT false;
UPDATE cqc."ServiceUsers" SET "Other" = true WHERE "ID" in (18, 9, 23);

-- https://trello.com/c/bnfFCPM1 - Change Request - Other Service "Other" Input field
ALTER TABLE cqc."EstablishmentServices" ADD COLUMN "Other" TEXT NULL;

-- https://trello.com/c/rh1Uucfk - Change Request -Type of Employer "Other" Input field
ALTER TABLE cqc."Establishment" ADD COLUMN "EmployerTypeOther" TEXT NULL;

-- https://trello.com/c/hiy5ZcqL - Change Request - Job Roles "Other" Input field
ALTER TABLE cqc."Worker" ADD COLUMN "MainJobFkOther" TEXT NULL;
ALTER TABLE cqc."WorkerJobs" ADD COLUMN "Other" TEXT NULL;
ALTER TABLE cqc."Job" ADD COLUMN "Other" BOOLEAN DEFAULT false;
UPDATE cqc."Job" SET "Other" = true WHERE "JobID" in (20,21);

-- https://trello.com/c/GkKQK1WE - Change Request - Main Service "Other" Input field
ALTER TABLE cqc."Establishment" ADD COLUMN "MainServiceFkOther" TEXT NULL;
ALTER TABLE cqc.services ADD COLUMN other BOOLEAN DEFAULT false;
UPDATE cqc.services SET other = true WHERE id in(15, 12, 17, 14, 6, 10, 18);

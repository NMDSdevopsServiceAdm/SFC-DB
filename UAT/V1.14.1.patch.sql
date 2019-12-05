SET SEARCH_PATH TO cqc;
BEGIN TRANSACTION;

ALTER TABLE "Establishment" ADD COLUMN "LinkToParentRequested" timestamp without time zone;

END TRANSACTION;

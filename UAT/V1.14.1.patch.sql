SET SEARCH_PATH TO cqc;
BEGIN TRANSACTION;

ALTER TABLE "Establishment" ADD COLUMN "LinkToParentRequested" character varying(20);

END TRANSACTION;

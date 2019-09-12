-- https://trello.com/c/AscBN35F/47-18-bulk-upload-local-identifiers-establishment

-- undo patch - run manually to fix sfcdevdb only
--ALTER TABLE cqc."Establishment" DROP COLUMN "LocalIdentifier";
--ALTER TABLE ONLY cqc."Establishment" DROP CONSTRAINT "establishment_LocalIdentifier_unq";

-- new patch
ALTER TABLE cqc."Establishment" ADD COLUMN "LocalIdentifierValue" TEXT NULL;
ALTER TABLE cqc."Establishment" ADD COLUMN "LocalIdentifierSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment" ADD COLUMN "LocalIdentifierSavedBy" TEXT NULL;
ALTER TABLE cqc."Establishment" ADD COLUMN "LocalIdentifierChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Establishment" ADD COLUMN "LocalIdentifierChangedBy" TEXT NULL;

ALTER TABLE ONLY cqc."Establishment" ADD CONSTRAINT "establishment_LocalIdentifier_unq" UNIQUE ("LocalIdentifierValue");

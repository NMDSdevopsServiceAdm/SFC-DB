-- https://trello.com/c/QAzbzesV
DROP INDEX IF EXISTS cqc."Establishment_unique_registration";
DROP INDEX IF EXISTS cqc."Establishment_unique_registration_with_locationid";
CREATE UNIQUE INDEX IF NOT EXISTS "Establishment_unique_registration" ON cqc."Establishment" ("NameValue", "PostCode", "LocationID") WHERE "Archived" = false;
CREATE UNIQUE INDEX IF NOT EXISTS "Establishment_unique_registration_with_locationid" ON cqc."Establishment" ("NameValue", "PostCode") WHERE "Archived" = false AND "LocationID" IS NULL;

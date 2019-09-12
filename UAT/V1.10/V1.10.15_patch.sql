-- https://trello.com/c/zDZxPEnO
ALTER TABLE cqc."Establishment" DROP CONSTRAINT "establishment_LocalIdentifier_unq";

DROP INDEX cqc."Establishment_unique_registration";
DROP INDEX cqc."Establishment_unique_registration_with_locationid";

ALTER TABLE cqc."Establishment" DROP CONSTRAINT "estloc_fk";
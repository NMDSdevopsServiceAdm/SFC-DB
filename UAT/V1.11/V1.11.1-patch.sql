-- https://trello.com/c/ouUV10ZZ
ALTER TABLE cqc."Establishment" ADD COLUMN "StaffWdfEligibility" timestamp without time zone NULL;
ALTER TABLE cqc."Establishment" ADD COLUMN "EstablishmentWdfEligibility" timestamp without time zone NULL;

-- uncomment these to run one by one
--ALTER TYPE cqc."EstablishmentAuditChangeType" ADD VALUE 'staffWdfEligible';
--ALTER TYPE cqc."EstablishmentAuditChangeType" ADD VALUE 'establishmentWdfEligible';
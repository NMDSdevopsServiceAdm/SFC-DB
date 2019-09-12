-- patch for WDF Report - https://trello.com/c/yBCo8FV7
ALTER TABLE cqc."Establishment" ADD COLUMN "OverallWdfEligibility" timestamp without time zone NULL;
ALTER TABLE cqc."Establishment" ADD COLUMN "LastWdfEligibility" timestamp without time zone NULL;
ALTER TABLE cqc."Worker" ADD COLUMN "LastWdfEligibility" timestamp without time zone NULL;

ALTER TYPE cqc."WorkerAuditChangeType" ADD VALUE 'wdfEligible';
ALTER TYPE cqc."EstablishmentAuditChangeType" ADD VALUE 'wdfEligible';
ALTER TYPE cqc."EstablishmentAuditChangeType" ADD VALUE 'overalWdfEligible';

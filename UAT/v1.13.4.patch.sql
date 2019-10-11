--https://trello.com/c/V7Y7vxLZ

DROP TYPE IF EXISTS cqc.OwnerChangeStatus;
CREATE TYPE cqc.OwnerChangeStatus AS ENUM (
  'REQUESTED',
  'APPROVED',
  'DENIED',
  'CANCELLED'
);

ALTER TABLE cqc."Login"
    ADD COLUMN "Status" character varying(20);

ALTER TABLE cqc."Establishment"
    ADD COLUMN "Status" character varying(20);
--https://trello.com/c/V7Y7vxLZ

DROP TYPE IF EXISTS cqc.OwnerChangeStatus;
CREATE TYPE cqc.OwnerChangeStatus AS ENUM (
  'REQUESTED',
  'APPROVED',
  'DENIED',
  'CANCELLED'
);


BEGIN;

INSERT INTO cqc."LocalAuthorities" ("EstablishmentFK", "LocalAuthorityName", "LastYear", "Status", "Notes") VALUES
  (1686, 'Bluebird Care Camden & Hampstead', 300, 'Not Updated', 'This is a comment'),
  (479, 'WOZiTech, with even more care', 540, 'Not Updated', null),
  (2274,'Skills for Care 2', 1234, 'Not Updated', null);

COMMIT;

-- to run this sql script: psql -U <username> -h <host> -d <database name> -f ad-hoc-scripts/local-authorities-dev.sql
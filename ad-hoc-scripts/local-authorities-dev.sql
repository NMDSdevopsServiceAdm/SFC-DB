BEGIN;

INSERT INTO cqc."LocalAuthorities" ("EstablishmentFK", "LocalAuthorityName", "LastYear", "Status", "Notes") VALUES  
  (1602, 'Hallgarth Care Home', 42, 'Not updated', 'Some comment'),
  (1582, 'Elizabeth Fleming Care Home', 54, 'Update, complete', null),
  (1611, 'Kilburn Care Home', 54, 'Not updated', null),
  (1567, 'The Cedars and Larches Care Home', 64, 'Update, not complete', 'This has not been completed' ),
  (1493, 'Kingswood Court Care Home', 73, 'Confirmed, complete', null),
  (2275, 'Grace Street', 2, 'Confirmed, not complete', 'Confirmation not complete'),
  (1585, 'Evedale Care Home', 74, 'Not updated', null),
  (1548, 'The Beaufort Care Home', 40, 'Update, not complete', null),
  (1503, 'Springfield Care Home', 243, 'Not updated', 'Comment about something'),
  (1598, 'Highfield Hall Care Home', 105, 'Confirmed, not complete', null),
  (479, 'WOZiTech, with even more care', 69, 'Update, complete', null),
  (1556,'Bon Accord Care Home', 42, 'Confirmed, complete', 'Confirmation completed'),
  (1623, 'Lydfords Care Home', 66, 'Not updated', null),
  (1686, 'Bluebird Care Camden & Hampstead', 532, 'Not updated', 'This is a comment'),
  (1547, 'Alexandra Care Home', 71, 'Not updated', null),
  (1653, 'Flaxpits House', 999, 'Update, complete', null);
  
COMMIT;

-- to run this sql script: psql -U <username> -h <host> -d <database name> -f ad-hoc-scripts/local-authorities-dev.sql

-- ((SELECT "EstablishmentID" FROM cqc."Establishment" WHERE "NmdsID"='B1002266'), 'Hallgarth Care Home', 42, 'Not updated', 'Some comment'),
-- ((SELECT "EstablishmentID" FROM cqc."Establishment" WHERE "NmdsID"='B1002246'), 'Elizabeth Fleming Care Home', 54, 'Update, complete', null),
-- ((SELECT "EstablishmentID" FROM cqc."Establishment" WHERE "NmdsID"='C1002275'), 'Kilburn Care Home', 54, 'Not updated', null),
-- ((SELECT "EstablishmentID" FROM cqc."Establishment" WHERE "NmdsID"='C1002231'), 'The Cedars and Larches Care Home', 64, 'Update, not complete', 'This has not been completed' );
-- ((SELECT "EstablishmentID" FROM cqc."Establishment" WHERE "NmdsID"='D1002157'), 'Kingswood Court Care Home', 73, 'Confirmed, complete', null),
-- ((SELECT "EstablishmentID" FROM cqc."Establishment" WHERE "NmdsID"='E1002939'), 'Grace Street', 2, 'Confirmed, Not complete', 'Confirmation not complete'),
-- ((SELECT "EstablishmentID" FROM cqc."Establishment" WHERE "NmdsID"='E1002249'), 'Evedale Care Home', 74, 'Not updated', null),
-- ((SELECT "EstablishmentID" FROM cqc."Establishment" WHERE "NmdsID"='E1002212'), 'The Beaufort Care Home', 40, 'Update, not complete', null);
-- ((SELECT "EstablishmentID" FROM cqc."Establishment" WHERE "NmdsID"='F1002167'), 'Springfield Care Home', 105, 'Not updated', 'Comment about something'),
-- ((SELECT "EstablishmentID" FROM cqc."Establishment" WHERE "NmdsID"='F1002262'), 'Highfield Hall Care Home', 69, 'Confirmed, not complete', null),
-- ((SELECT "EstablishmentID" FROM cqc."Establishment" WHERE "NmdsID"='G1001114'), 'WOZiTech, with even more care', 540, 'Update, complete', null),
-- ((SELECT "EstablishmentID" FROM cqc."Establishment" WHERE "NmdsID"='H1002220'), 'Bon Accord Care Home', 42, 'Confirmed, complete', 'Confirmation completed');
-- ((SELECT "EstablishmentID" FROM cqc."Establishment" WHERE "NmdsID"='H1002287'), 'Lydfords Care Home', 66, 'Not updated', null),
-- ((SELECT "EstablishmentID" FROM cqc."Establishment" WHERE "NmdsID"='H1002350'), 'Bluebird Care Camden & Hampstead', 532, 'Not updated', 'This is a comment'),
-- ((SELECT "EstablishmentID" FROM cqc."Establishment" WHERE "NmdsID"='I1002211'), 'Alexandra Care Home', 71, 'Not updated', null),
-- ((SELECT "EstablishmentID" FROM cqc."Establishment" WHERE "NmdsID"='J1002317'), 'Flaxpits House', 999, 'Update, complete' null);

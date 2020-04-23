BEGIN;

UPDATE cqc."Establishment" SET "NmdsID" = 'J1001310' WHERE  "NmdsID" = 'W1001310';
UPDATE cqc."Establishment" SET "NmdsID" = 'J1001346' WHERE  "NmdsID" = 'W1001346';
UPDATE cqc."Establishment" SET "NmdsID" = 'C1001448' WHERE  "NmdsID" = 'W1001448';
UPDATE cqc."Establishment" SET "NmdsID" = 'C1001449' WHERE  "NmdsID" = 'W1001449';
UPDATE cqc."Establishment" SET "NmdsID" = 'C1001459' WHERE  "NmdsID" = 'W1001459';

COMMIT;
BEGIN;

UPDATE cqc."Establishment" SET "NmdsID" = 'W1001417' WHERE  "NmdsID" = 'I1001417';
UPDATE cqc."Establishment" SET "NmdsID" = 'W1001419' WHERE  "NmdsID" = 'I1001419';
UPDATE cqc."Establishment" SET "NmdsID" = 'W1001494' WHERE  "NmdsID" = 'J1001494';

COMMIT;
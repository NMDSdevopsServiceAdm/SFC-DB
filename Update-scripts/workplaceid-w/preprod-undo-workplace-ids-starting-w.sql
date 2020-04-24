BEGIN;

UPDATE cqc."Establishment" SET "NmdsID" = 'W1006170' WHERE  "NmdsID" = 'E1006170';
UPDATE cqc."Establishment" SET "NmdsID" = 'W1006174' WHERE  "NmdsID" = 'C1006174';
UPDATE cqc."Establishment" SET "NmdsID" = 'W1006175' WHERE  "NmdsID" = 'C1006175';
UPDATE cqc."Establishment" SET "NmdsID" = 'W1006176' WHERE  "NmdsID" = 'C1006176';
UPDATE cqc."Establishment" SET "NmdsID" = 'W1006177' WHERE  "NmdsID" = 'C1006177';

COMMIT;

-- cf conduit sfcuatdb02 -- psql < Update-scripts/workplaceid-w/preprod-undo-workplace-ids-starting-w.sql
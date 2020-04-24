BEGIN;

UPDATE cqc."Establishment" SET "NmdsID" = 'E1006170' WHERE  "NmdsID" = 'W1006170';
UPDATE cqc."Establishment" SET "NmdsID" = 'C1006174' WHERE  "NmdsID" = 'W1006174';
UPDATE cqc."Establishment" SET "NmdsID" = 'C1006175' WHERE  "NmdsID" = 'W1006175';
UPDATE cqc."Establishment" SET "NmdsID" = 'C1006176' WHERE  "NmdsID" = 'W1006176';
UPDATE cqc."Establishment" SET "NmdsID" = 'C1006177' WHERE  "NmdsID" = 'W1006177';

COMMIT;

-- select estab."NmdsID", estab."NameValue" from cqc."Establishment" estab where estab."NmdsID" 
-- IN ('W1006170','W1006174','W1006175','W1006176','W1006177')
-- ORDER BY estab."NmdsID";
--
-- select estab."NameValue" from cqc."Establishment" estab where estab."NmdsID" = 'W1006177';

-- cf conduit sfcuatdb02 -- psql < Update-scripts/workplaceid-w/preprod-update-workplace-ids-starting-w.sql

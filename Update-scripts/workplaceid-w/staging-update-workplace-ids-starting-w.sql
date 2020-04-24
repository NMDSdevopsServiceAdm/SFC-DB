BEGIN;

UPDATE cqc."Establishment" SET "NmdsID" = 'I1001417' WHERE  "NmdsID" = 'W1001417';
UPDATE cqc."Establishment" SET "NmdsID" = 'I1001419' WHERE  "NmdsID" = 'W1001419';
UPDATE cqc."Establishment" SET "NmdsID" = 'J1001494' WHERE  "NmdsID" = 'W1001494';

COMMIT;

-- select estab."NmdsID", estab."NameValue" from cqc."Establishment" estab where estab."NmdsID" 
-- IN ('W1001417','W1001419','W1001494');
-- select estab."NameValue" from cqc."Establishment" estab where estab."NmdsID" = 'W1001494';


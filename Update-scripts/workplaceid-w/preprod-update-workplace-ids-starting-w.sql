BEGIN;

UPDATE cqc."Establishment" SET "NmdsID" = "C1001925" WHERE  "NmdsID" = "W1001925";
UPDATE cqc."Establishment" SET "NmdsID" = "C1002046" WHERE  "NmdsID" = "W1002046";
UPDATE cqc."Establishment" SET "NmdsID" = "C1002053" WHERE  "NmdsID" = "W1002053";
UPDATE cqc."Establishment" SET "NmdsID" = "I1002055" WHERE  "NmdsID" = "W1002055";
UPDATE cqc."Establishment" SET "NmdsID" = "C1002056" WHERE  "NmdsID" = "W1002056";
UPDATE cqc."Establishment" SET "NmdsID" = "C1002057" WHERE  "NmdsID" = "W1002057";
UPDATE cqc."Establishment" SET "NmdsID" = "C1002059" WHERE  "NmdsID" = "W1002059";
UPDATE cqc."Establishment" SET "NmdsID" = "C1002061" WHERE  "NmdsID" = "W1002061";
UPDATE cqc."Establishment" SET "NmdsID" = "C1002062" WHERE  "NmdsID" = "W1002062";
UPDATE cqc."Establishment" SET "NmdsID" = "C1002063" WHERE  "NmdsID" = "W1002063";
UPDATE cqc."Establishment" SET "NmdsID" = "C1002064" WHERE  "NmdsID" = "W1002064";
UPDATE cqc."Establishment" SET "NmdsID" = "B1002065" WHERE  "NmdsID" = "W1002065";
UPDATE cqc."Establishment" SET "NmdsID" = "C1002066" WHERE  "NmdsID" = "W1002066";
UPDATE cqc."Establishment" SET "NmdsID" = "C1002067" WHERE  "NmdsID" = "W1002067";
UPDATE cqc."Establishment" SET "NmdsID" = "C1002068" WHERE  "NmdsID" = "W1002068";
UPDATE cqc."Establishment" SET "NmdsID" = "C1002069" WHERE  "NmdsID" = "W1002069";
UPDATE cqc."Establishment" SET "NmdsID" = "C1002077" WHERE  "NmdsID" = "W1002077";
UPDATE cqc."Establishment" SET "NmdsID" = "C1002079" WHERE  "NmdsID" = "W1002079";
UPDATE cqc."Establishment" SET "NmdsID" = "C1002082" WHERE  "NmdsID" = "W1002082";
UPDATE cqc."Establishment" SET "NmdsID" = "C1002093" WHERE  "NmdsID" = "W1002093";
UPDATE cqc."Establishment" SET "NmdsID" = "C1002102" WHERE  "NmdsID" = "W1002102";
UPDATE cqc."Establishment" SET "NmdsID" = "C1002103" WHERE  "NmdsID" = "W1002103";
UPDATE cqc."Establishment" SET "NmdsID" = "I1002133" WHERE  "NmdsID" = "W1002133";
UPDATE cqc."Establishment" SET "NmdsID" = "I1002137" WHERE  "NmdsID" = "W1002137";
UPDATE cqc."Establishment" SET "NmdsID" = "I1002138" WHERE  "NmdsID" = "W1002138";
UPDATE cqc."Establishment" SET "NmdsID" = "I1002144" WHERE  "NmdsID" = "W1002144";
UPDATE cqc."Establishment" SET "NmdsID" = "I1002145" WHERE  "NmdsID" = "W1002145";
UPDATE cqc."Establishment" SET "NmdsID" = "I1002146" WHERE  "NmdsID" = "W1002146";
UPDATE cqc."Establishment" SET "NmdsID" = "B1002210" WHERE  "NmdsID" = "W1002210";
UPDATE cqc."Establishment" SET "NmdsID" = "G1002298" WHERE  "NmdsID" = "W1002298";
UPDATE cqc."Establishment" SET "NmdsID" = "F1002938" WHERE  "NmdsID" = "W1002938";
UPDATE cqc."Establishment" SET "NmdsID" = "I1013455" WHERE  "NmdsID" = "W1013455";

COMMIT;

-- select estab."NmdsID", estab."NameValue" from cqc."Establishment" estab where estab."NmdsID" 
-- IN ('W1006170','W1006174','W1006175','W1006176','W1006177')
-- ORDER BY estab."NmdsID";
--
-- select estab."NameValue" from cqc."Establishment" estab where estab."NmdsID" = 'W1006177';

-- cf conduit sfcuatdb02 -- psql < Update-scripts/workplaceid-w/preprod-update-workplace-ids-starting-w.sql

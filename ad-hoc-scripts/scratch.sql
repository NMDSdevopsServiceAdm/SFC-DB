select estab."NameValue" from cqc."Establishment" estab where estab."NmdsID" = 'W1006177';

cf conduit sfcuatdb02 -- psql < ad-hoc-scripts/scratch.sql


SELECT "postcode", "local_custodian_code" from cqcref."pcode" where UPPER("postcode") = 'NP13 1NE';
SELECT * from cqcref."pcode" where UPPER("postcode") = 'NP13 1NE';
SELECT "postcode", "local_custodian_code" from cqcref."pcode" where UPPER("postcode") LIKE 'NP13%';
select estab."NmdsID", estab."PostCode" from cqc."Establishment" estab where estab."NmdsID" LIKE 'W%' limit 5;
select estab."NmdsID", estab."PostCode" from cqc."Establishment" estab where estab."NmdsID" LIKE 'W%' and UPPER(estab."PostCode") = 'NP13 1NE';
select estab."NmdsID", estab."PostCode" from cqc."Establishment" estab where estab."NmdsID" = 'W1013455';
select estab."Status" from cqc."Establishment" estab where estab."NmdsID" = 'W1013455';
INSERT INTO cqcref."pcodedata" VALUES('100100449541','','',111,'GLADSTONE STREET','ABERTILLERY','NP13 1NE',6910,'BLAENAU GWENT');
select * from cqc."User" where "FullNameValue" like 'Clare%';
select estab."IsActive", estab."Status", estab."NmdsID", estab."PostCode" from cqc."Establishment" estab where estab."Status" = 'PENDING' AND UPPER(estab."PostCode") LIKE 'NP13%';
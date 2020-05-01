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
select estab."Status", estab."NameValue", estab."NmdsID", estab."PostCode" from cqc."Establishment" estab where estab."NameValue" like 'Test WPrefix%';
select estab."NameValue", estab."Status", estab."NmdsID", estab."PostCode" from cqc."Establishment" estab where estab."Status" = 'PENDING' AND UPPER(estab."PostCode") LIKE 'NP13%';
select "Active", "Status", "RegistrationID" from cqc."Login" where "Username" = 'claretest005dev';
select "FullNameValue", "Archived" from cqc."User" where "RegistrationID" = 9524;
select distinct "Active" from cqc."Login";
select * from cqc."User" usr where usr."EstablishmentID" = 2299;
select * from cqc."Login" login where login."Username" = 'ozella53';
select "NmdsID" from cqc."Establishment" limit 1;
select "EstablishmentID", "NmdsID" from cqc."Establishment" where "NmdsID" = 'G1002299'
-- login username 'eryn23' username 'Korey Bashirian' workplace id 'I1002961'
----------
select 
	login."Username" as LoginName,
	usr."FullNameValue" as UserName,
	usr."RegistrationID",
	estab."NameValue" as EstabName,
	usr."EstablishmentID",
    estab."NmdsID" as WorkplaceId,
    login."Status" as loginStatus,
    login."Active" as loginIsActive,
    estab."Status" as estabStatus,
    usr."Archived" as UsrArchived
from 
	cqc."Login" login
inner join
	cqc."User" usr on usr."RegistrationID" = login."RegistrationID"
inner join
	cqc."Establishment" estab on usr."EstablishmentID" = estab."EstablishmentID"
where
	login."Username" = 'eryn23'
-----------
select 
	login."Username"
from 
	cqc."Login" login
inner join
	cqc."User" usr on usr."RegistrationID" = login."RegistrationID"
inner join
	cqc."Establishment" estab on usr."EstablishmentID" = estab."EstablishmentID"
where
	estab."IsParent" = true
-----------




--------------------------------
SELECT count (distinct "pcodedata"."local_custodian_code") FROM "cqcref"."pcodedata";
SELECT count (distinct "LocalCustodianCode") FROM "cqc"."Cssr";
SELECT * FROM "cqc"."Cssr" limit 10;
SELECT * FROM cqcref.pcode where "local_custodian_code" = 3805;
SELECT * FROM cqcref.pcode where "local_custodian_code" = 7655;
select * from cqc."Cssr" where "LocalCustodianCode" = 7655;
---------------
-- This query will list all the custodian codes from pcodedata that don't have matching records in the cssr table
SELECT distinct 
	"pcodedata"."local_custodian_code" as "pcode_LA_code",
	"pcodedata"."county",
	"theAuthority"."LocalCustodianCode"
FROM 
    "cqcref"."pcodedata"
left outer join 
	"cqc"."Cssr" AS "theAuthority" ON "pcodedata"."local_custodian_code" = "theAuthority"."LocalCustodianCode" 
where
	"theAuthority"."LocalCustodianCode" is null
order by 
	"theAuthority"."LocalCustodianCode" desc;
-- There are 325 populated rows from cssr, then rows 326 to 386 are nulls - 61 rows
-- On staging there are 381 distinct custodian codes in the postcode table
-- On staging there are 325 distinct custodian codes in the in cssr table
-- On dev it's the same
-- On prod there are 325 distinct custodian codes in the in cssr table
------------------
-- Failing to populate LA authority in LA user report:
SELECT 
    "pcodedata"."uprn", "pcodedata"."sub_building_name", "pcodedata"."building_name", 
    "pcodedata"."building_number", "pcodedata"."street_description", "pcodedata"."post_town", 
    "pcodedata"."postcode", "pcodedata"."local_custodian_code", "pcodedata"."county", 
    "pcodedata"."rm_organisation_name", 
    "theAuthority"."CssrID" AS "theAuthority.id", 
    "theAuthority"."CssR" AS "theAuthority.name", 
    "theAuthority"."NmdsIDLetter" AS "theAuthority.nmdsIdLetter" 
FROM 
    "cqcref"."pcodedata" AS "pcodedata" 
LEFT OUTER JOIN 
    "cqc"."Cssr" AS "theAuthority" ON "pcodedata"."local_custodian_code" = "theAuthority"."LocalCustodianCode" 
WHERE "pcodedata"."postcode" = 'NW9 4EW' LIMIT 1;
--[api:server ] info: Executing (default): 
select 
    "Cssr"."CssrID", "Cssr"."CssR" 
from 
    cqcref.pcodedata, cqc."Cssr" 
where 
    postcode like 'NW9%' 
    and pcodedata.local_custodian_code = "Cssr"."LocalCustodianCode" 
group by 
    "Cssr"."CssrID", "Cssr"."CssR"
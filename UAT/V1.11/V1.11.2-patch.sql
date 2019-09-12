-- https://trello.com/c/QZzwclw6
DROP FUNCTION IF EXISTS cqc.wdfsummaryreport;
CREATE OR REPLACE FUNCTION cqc.wdfsummaryreport(effectiveDate DATE)
 RETURNS TABLE (
	"NmdsID" text,
    "EstablishmentID" integer,
    "EstablishmentName" text,
    "Address1" text,
    "Address2" text,
    "PostCode" text,
    "Region" text,
    "CSSR" text,
    "EstablishmentUpdated" timestamp without time zone,
		"NumberOfStaff" integer,
    "ParentID" integer,
    "OverallWdfEligibility" timestamp without time zone,
    "ParentNmdsID" text,
    "ParentEstablishmentID" integer,
    "ParentName" text,
    "WorkerCount" bigint,
    "WorkerCompletedCount" bigint
) 
AS $$
BEGIN
   RETURN QUERY select
	"Establishment"."NmdsID"::text,
	"Establishment"."EstablishmentID",
	"Establishment"."NameValue" AS "EstablishmentName",
	"Establishment"."Address1",
	"Establishment"."Address2",
	"Establishment"."PostCode",
	pcode.region as "Region",
	pcode.cssr as "CSSR",
	"Establishment".updated,
	"Establishment"."NumberOfStaffValue" AS "NumberOfStaff",
	"Establishment"."ParentID",
	"Establishment"."OverallWdfEligibility",
	parents."NmdsID"::text As "ParentNmdsID",
	parents."EstablishmentID" AS "ParentEstablishmentID",
	parents."NameValue" AS "ParentName",
	COUNT(workers."ID") filter (where workers."ID" is not null) as "WorkerCount",
    COUNT(workers."ID") filter (where workers."LastWdfEligibility" > effectiveDate) as "WorkerCompletedCount"
from cqc."Establishment"
	left join cqcref.pcode on pcode.postcode = "Establishment"."PostCode"
	left join cqc."Establishment" as parents on parents."EstablishmentID" = "Establishment"."ParentID"
	left join cqc."Worker" as workers on workers."EstablishmentFK" = "Establishment"."EstablishmentID" and workers."Archived"=false
where "Establishment"."Archived"=false
group by
	"Establishment"."NmdsID",
	"Establishment"."EstablishmentID",
	"Establishment"."NameValue",
	"Establishment"."Address1",
	"Establishment"."Address2",
	"Establishment"."PostCode",
	pcode.region,
	pcode.cssr,
	"Establishment".updated,
	"Establishment"."ParentID",
	"Establishment"."OverallWdfEligibility",
	parents."NmdsID",
	parents."EstablishmentID",
	parents."NameValue";
END; $$
LANGUAGE 'plpgsql';

DROP FUNCTION IF EXISTS cqcref.create_pcode_data;
CREATE OR REPLACE FUNCTION cqcref.create_pcode_data()
  RETURNS void AS $$
DECLARE
BEGIN

  drop table if exists cqcref.pcode;

  CREATE TABLE cqcref.pcode AS
  select postcode, local_custodian_code
  from cqcref.pcodedata
  group by postcode, local_custodian_code;

	ALTER TABLE cqcref.pcode  OWNER to sfcadmin;
	GRANT SELECT ON TABLE cqcref.pcode TO "Read_Only_Role";
	GRANT SELECT ON TABLE cqcref.pcode TO "Read_Update_Role";
	GRANT SELECT ON TABLE cqcref.pcode TO "Sfc_Admin_Role";
	GRANT ALL ON TABLE cqcref.pcode TO sfcadmin;

  alter table cqcref.pcode add column postcode_part text;
  alter table cqcref.pcode add column region text;
  alter table cqcref.pcode add column cssr text;

  update cqcref.pcode
  set postcode_part = substring(postcode from 1 for position(' ' in postcode));

  update cqcref.pcode
  set region="Cssr"."Region", cssr="Cssr"."CssR"
  from cqc."Cssr" where "Cssr"."LocalCustodianCode" = pcode.local_custodian_code;

	CREATE INDEX "pcode_postcode" on cqcref.pcode (postcode);
  CREATE INDEX "pcode_postcode_PART" on cqcref.pcode (postcode_PART);

END;
$$ LANGUAGE plpgsql;

select cqcref.create_pcode_data();


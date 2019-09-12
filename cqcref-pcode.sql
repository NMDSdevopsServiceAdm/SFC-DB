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
  CREATE INDEX "pcode_postcode_part" on cqcref.pcode (postcode_part);

END;
$$ LANGUAGE plpgsql;

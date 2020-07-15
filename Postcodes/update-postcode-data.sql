----------------
-- This script will merge old and new postcode data
-- See confluence page with more info: https://skillsforcare.atlassian.net/wiki/spaces/ASCWDS/pages/89587775/Postcode+data+updates
-- To run the script: cf conduit sfcuatdb02 -- psql < /path/to/update-postcode-data.sql
----------------

----------------
BEGIN TRANSACTION;

-------------------
-- Turn timing on so we can see how long it took
-------------------
\timing

-------------------
-- Restore backed-up postcode data into pcodedata_new, so we can merge old and new postcode data
-- !! Edit the path to the dump file !!
-- !! This assumes you've edited your dump file to reference a table called "pcodedata_new" instead of pcodedata
-- !! In Windows Terminal you need to use forward slashes in your path, and surround in single quotes !!
-------------------
SELECT 'Creating pcodedata_new table (a backup of the existing pcodedata table) so we can merge old and new postcode data';
\i '/Users/claresudbery/OneDrive/temp/SFC-postcodes/pcodedata-prod-backup.dmp';

-------------------
-- Create a temp table, "pcodedata-source", to hold the new postcode data from the csv
-------------------
SELECT 'Creating temp source table';

DROP TABLE IF EXISTS cqcref."pcodedata-source";

CREATE TABLE cqcref."pcodedata-source" (
    uprn                    bigint primary key,
    filler_column_02        varchar,
    filler_column_03        varchar,
    filler_column_04        varchar,
    filler_column_05        varchar,
    filler_column_06        varchar,
    filler_column_07        varchar,
    filler_column_08        varchar,
    filler_column_09        varchar,
    filler_column_10        varchar,
    filler_column_11        varchar,
    filler_column_12        varchar,
    local_custodian_code    bigint, --: 13
    filler_column_14        varchar,
    filler_column_15        varchar,
    filler_column_16        varchar,
    filler_column_17        varchar,
    rm_organisation_name    character varying COLLATE pg_catalog."default", --: 18
    filler_column_19        varchar,
    filler_column_20        varchar,
    filler_column_21        varchar,
    sub_building_name       character varying COLLATE pg_catalog."default", --: 22
    building_name           character varying COLLATE pg_catalog."default", --: 23
    building_number         character varying COLLATE pg_catalog."default", --: 24
    filler_column_25        varchar,
    filler_column_26        varchar,
    filler_column_27        varchar,
    filler_column_28        varchar,
    filler_column_29        varchar,
    filler_column_30        varchar,
    filler_column_31        varchar,
    filler_column_32        varchar,
    filler_column_33        varchar,
    filler_column_34        varchar,
    filler_column_35        varchar,
    filler_column_36        varchar,
    filler_column_37        varchar,
    filler_column_38        varchar,
    filler_column_39        varchar,
    filler_column_40        varchar,
    filler_column_41       	varchar,
    filler_column_42       	varchar,
    filler_column_43       	varchar,
    filler_column_44        varchar,
    filler_column_45        varchar,
    filler_column_46        varchar,
    filler_column_47        varchar,
    filler_column_48        varchar,
    filler_column_49        varchar,
    street_description      character varying COLLATE pg_catalog."default", --: 50
    filler_column_51       	varchar,
    filler_column_52       	varchar,
    filler_column_53       	varchar,
    filler_column_54        varchar,
    filler_column_55        varchar,
    filler_column_56        varchar,
    filler_column_57        varchar,
    filler_column_58        varchar,
    filler_column_59        varchar,
    filler_column_60        varchar,
    post_town               character varying COLLATE pg_catalog."default", --: 61
    county                  character varying COLLATE pg_catalog."default", --: 62
    filler_column_63       	varchar,
    filler_column_64        varchar,
    filler_column_65        varchar,
    postcode                character varying COLLATE pg_catalog."default", --: 66
    filler_column_67        varchar,
    filler_column_68        varchar,
    filler_column_69        varchar,
    filler_column_70        varchar,
    filler_column_71       	varchar,
    filler_column_72       	varchar,
    filler_column_73       	varchar,
    filler_column_74        varchar,
    filler_column_75        varchar,
    filler_column_76        varchar,
    filler_column_77        varchar
);
ALTER TABLE cqcref."pcodedata-source"
    OWNER to rdsbroker_9a03ef70_950d_437d_8e69_530388b53994_manager; -- prod
    --OWNER to rdsbroker_ac54a3d5_cffd_4dea_a91c_af8c101d1e15_manager; -- preprod

-------------------
-- Import the new postcode data from the csvs into your temp table
-- !! Edit the path to the csvs !!
-------------------
SELECT 'Importing new postcode data from the csvs into temp source table';
TRUNCATE cqcref."pcodedata-source";
\copy cqcref."pcodedata-source" FROM '/Users/claresudbery/skills-for-care/postcodes/AddressBasePlus_COU_2020-03-19_001.csv' WITH (FORMAT csv);
\copy cqcref."pcodedata-source" FROM '/Users/claresudbery/skills-for-care/postcodes/AddressBasePlus_COU_2020-03-19_002.csv' WITH (FORMAT csv);

-------------------
-- Add a primary key to the new table, so it has some way of detecting duplicates
-------------------
SELECT 'Adding a primary key to the new table, so it has some way of detecting duplicates';
ALTER TABLE cqcref."pcodedata_new"
  ADD CONSTRAINT pcodedata_uprn_01_pk 
    PRIMARY KEY (uprn);

-------------------
-- Import the new source data from cqcref."pcodedata-source" into cqcref."pcodedata_new"
-------------------
SELECT 'Importing new postcode data from temp source table into cqcref."pcodedata_new"';
INSERT INTO cqcref."pcodedata_new" (
    "uprn",
    "sub_building_name",
    "building_name",
    "building_number",
    "street_description",
    "post_town",
    "postcode",
    "local_custodian_code",
    "county",
    "rm_organisation_name") 
  SELECT
    "uprn",
    "sub_building_name",
    "building_name",
    "building_number",
    "street_description",
    "post_town",
    "postcode",
    "local_custodian_code",
    "county",
    "rm_organisation_name"
  FROM cqcref."pcodedata-source" pcode_source
ON CONFLICT ("uprn") DO UPDATE SET
    "sub_building_name"    = excluded."sub_building_name",             
    "building_name"        = excluded."building_name",                
    "building_number"      = excluded."building_number",                
    "street_description"   = excluded."street_description",              
    "post_town"            = excluded."post_town",                    
    "postcode"             = excluded."postcode",                    
    "local_custodian_code" = excluded."local_custodian_code",           
    "county"               = excluded."county",                    
    "rm_organisation_name" = excluded."rm_organisation_name" 
 ;

-------------------
-- Check new data successfully updated
-- This should return BRISTOL AVE, NW9 4EW, BARNET
-------------------
SELECT 'You should now see BRISTOL AVE, NW9 4EW, BARNET';
SELECT 
  "street_description", 
  "postcode", 
  "county" 
FROM 
  cqcref."pcodedata_new" 
WHERE 
  "postcode" = 'NW9 4EW';

----------------
END TRANSACTION;
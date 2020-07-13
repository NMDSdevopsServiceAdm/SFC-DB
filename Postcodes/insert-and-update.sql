-------------------
-- using small data set of 2000 records:
-- INSERT 0 2002
-- Query returned successfully in 1 secs 226 msec.
-------------------
-- using full data set of 1,258,152 records:
-- (based on the above, should take approx 770 seconds, which is 12.83 minutes)
-- INSERT 0 1258152
-- Query returned successfully in 6 min 28 secs.
-------------------
BEGIN TRANSACTION;
----------------
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
 END TRANSACTION;
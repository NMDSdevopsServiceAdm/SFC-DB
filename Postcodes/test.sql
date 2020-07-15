----------------
BEGIN TRANSACTION;

-------------------
-- Restore backed-up postcode data into pcodedata_new
-- !! Edit the path to the dump file !!
-- !! In Windows Terminal you need to use forward slashes in your path, and surround in single quotes !!
-- !! This assumes you've edited your dump file to reference a table called "pcodedata_new" instead of pcodedata
-------------------
\i 'C:/skills-for-care/postcodes/location-preprod-backup.dmp';

-------------------
-- Create a temp table, "pcodedata-source", to hold the new postcode data from the csv
-------------------
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

END TRANSACTION;
BEGIN TRANSACTION;

DROP TABLE IF EXISTS cqcref."pcodedata_new";

CREATE TABLE cqcref."pcodedata_new"
(
    uprn bigint NOT NULL,
    sub_building_name character varying COLLATE pg_catalog."default",
    building_name character varying COLLATE pg_catalog."default",
    building_number character varying COLLATE pg_catalog."default",
    street_description character varying COLLATE pg_catalog."default",
    post_town character varying COLLATE pg_catalog."default",
    postcode character varying COLLATE pg_catalog."default",
    local_custodian_code bigint,
    county character varying COLLATE pg_catalog."default",
    rm_organisation_name character varying COLLATE pg_catalog."default",
    CONSTRAINT pcodedata_uprn_pk PRIMARY KEY (uprn)
)

TABLESPACE pg_default;

ALTER TABLE cqcref."pcodedata_new"
    --OWNER to rdsbroker_9a03ef70_950d_437d_8e69_530388b53994_manager; -- prod
    OWNER to rdsbroker_ac54a3d5_cffd_4dea_a91c_af8c101d1e15_manager; -- preprod

END TRANSACTION;
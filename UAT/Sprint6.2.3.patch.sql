BEGIN TRANSACTION;
------------------------------------------------
-- Add new cssr for Bournemouth & Poole combined
------------------------------------------------
INSERT INTO cqc."Cssr" ("CssrID", "CssR", "LocalAuthority", "LocalCustodianCode", "Region", "RegionID", "NmdsIDLetter")
VALUES (822, 'Bournemouth, Christchurch and Poole', 'Bournemouth, Christchurch and Poole', 1260, 'South West', 7, 'D')
ON CONFLICT DO NOTHING;
------------------------------------------------
-- Remove individual cssrs for Bournemouth, and Poole:
------------------------------------------------
DELETE
FROM cqc."Cssr"
WHERE "CssrID" = 810;
----------------
DELETE
FROM cqc."Cssr"
WHERE "CssrID" = 811;
------------------------------------------------
-- Update ELA to refer to new cssr instead of old cssrs
------------------------------------------------
UPDATE cqc."EstablishmentLocalAuthority"
SET "CssrID" = 822,
    "CssR"   = 'Bournemouth, Christchurch and Poole'
WHERE "CssrID" = 811
   OR "CssrID" = 810;
------------------------------------------------
-- Get rid of duplicates in ELA
------------------------------------------------
DELETE
FROM
    cqc."EstablishmentLocalAuthority" T1
        USING cqc."EstablishmentLocalAuthority" T2
WHERE
    T1."EstablishmentLocalAuthorityID" < T2."EstablishmentLocalAuthorityID"
    AND T1."CssrID" = T2."CssrID"
    AND T1."EstablishmentID" = T2."EstablishmentID";
------------------------------------------------
-- Update postcode data to refer to new cssr instead of old cssrs
------------------------------------------------
UPDATE cqcref."pcodedata" 
SET "local_custodian_code" = 1260 
WHERE 
    "local_custodian_code" = 1250 
    OR "local_custodian_code" = 1255;
----------------
END TRANSACTION;

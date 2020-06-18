BEGIN TRANSACTION;
INSERT INTO cqc."Cssr" ("CssrID", "CssR", "LocalAuthority", "LocalCustodianCode", "Region", "RegionID", "NmdsIDLetter")
VALUES (822, 'Bournemouth, Christchurch and Poole', 'Bournemouth, Christchurch and Poole', 1260, 'South West', 7, 'D')
ON CONFLICT DO NOTHING;
DELETE
FROM cqc."Cssr"
WHERE "CssrID" = 810;
DELETE
FROM cqc."Cssr"
WHERE "CssrID" = 811;
UPDATE cqc."EstablishmentLocalAuthority"
SET "CssrID" = 822,
    "CssR"   = 'Bournemouth, Christchurch and Poole'
WHERE "CssrID" = 811
   OR "CssrID" = 810;
END TRANSACTION;

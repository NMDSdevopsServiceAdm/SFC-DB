SELECT * FROM cqc."Cssr" c 
WHERE c."LocalCustodianCode" IN 
(SELECT p."local_custodian_code" FROM cqcref."pcode" p WHERE UPPER(substring(p."postcode" from '[^ ]+'::text)) 
    IN (
        SELECT UPPER(substring(e."PostCode" from '[^ ]+'::text)) FROM cqc."Establishment" e WHERE e."NmdsID" LIKE 'W%'
    ) 
    GROUP BY p."local_custodian_code"
);

SELECT 
    e."EstablishmentID", 
    e."NameValue", 
    e."NmdsID", 
    e."PostCode" 
FROM 
    cqc."Establishment" e 
WHERE 
    "NmdsID" LIKE 'W%';
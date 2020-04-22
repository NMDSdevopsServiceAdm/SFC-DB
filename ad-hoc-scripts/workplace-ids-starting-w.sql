SELECT 
	estab."NmdsID",
	CASE WHEN STRING_AGG(cssr."NmdsIDLetter", ',') IS NULL 
            THEN 'No postcode match' 
            ELSE STRING_AGG(DISTINCT concat(cssr."NmdsIDLetter", trim(leading 'W' from estab."NmdsID")), ',')
    END AS newWorkplaceId,
	estab."PostCode",
    UPPER(substring(estab."PostCode" from '[^ ]+'::text)) AS MatchedPcodePrefix,
	estab."NameValue",
    STRING_AGG(DISTINCT cssr."LocalCustodianCode"::text, ','),
    STRING_AGG(DISTINCT cssr."LocalAuthority", ',')
FROM 
	cqc."Establishment" estab 
LEFT OUTER JOIN
	cqcref."pcode" pcode 
		ON UPPER(substring(pcode."postcode" from '[^ ]+'::text))
			= UPPER(substring(estab."PostCode" from '[^ ]+'::text))
LEFT OUTER JOIN
	cqc."Cssr" cssr ON cssr."LocalCustodianCode" = pcode."local_custodian_code"
WHERE 
	estab."NmdsID" LIKE 'W%'
GROUP BY 
    estab."NmdsID", 
	estab."PostCode",
	estab."NameValue"
ORDER BY 
    estab."NmdsID"


-- These have postcodes that cross LAs: 
-- ('W1007087', 'W1007374', 'W1007556', 'W1007558', 'W1008606')
-- W1007087 - 3
-- W1007374 - 2
-- W1007556 - 2
-- W1007558 - 2
-- W1008606 - 2


SELECT 
   DISTINCT pcode."local_custodian_code"
FROM 
	cqcref."pcode" pcode 
WHERE
		 UPPER(substring(pcode."postcode" from '[^ ]+'::text))
			LIKE 'DN20%'

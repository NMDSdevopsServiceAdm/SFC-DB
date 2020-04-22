SELECT 
	estab."NmdsID",
	CASE WHEN STRING_AGG(cssr."NmdsIDLetter", ',') IS NULL 
            THEN 'No postcode match' 
            ELSE STRING_AGG(DISTINCT concat(cssr."NmdsIDLetter", trim(leading 'W' from estab."NmdsID")), ',')
    END AS newWorkplaceId,
	estab."PostCode",
    REVERSE(substring(REVERSE(estab."PostCode") from 4)) AS MatchedPcodePrefix,
	estab."NameValue",
    STRING_AGG(DISTINCT cssr."LocalCustodianCode"::text, ',') AS CustodianCodes,
    STRING_AGG(DISTINCT cssr."LocalAuthority", ',') AS LAs
FROM 
	cqc."Establishment" estab 
LEFT OUTER JOIN
	cqcref."pcode" pcode 
		ON UPPER(pcode."postcode")
            /* Some postcodes in the establishment table don't have spaces.
             What we want is everything up to the last 3 chars.
             We're reversing, removing the first 3 chars, reversing again, 
             and then adding '%' to use LIKE to find postcodes that start with the result */
            LIKE concat(REVERSE(substring(REVERSE(UPPER(estab."PostCode")) from 4)),'%')
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

-- Test string manipulation for postcodes
-- SELECT 
-- 	pcode."postcode"
-- 	-- REVERSE(substring(REVERSE(pcode."postcode") from 4))
-- FROM
-- 	cqcref."pcode" AS pcode
-- WHERE
-- 	pcode."postcode" LIKE concat(REVERSE(substring(REVERSE('M125SH') from 4)),'%')
-- 	--pcode."postcode" LIKE 'M12%'
-- LIMIT 5


-- Check the anomalous postcode we spotted iwth no space
-- SELECT * from cqcref."pcode" pcode WHERE pcode."postcode" = 'EX22 7BN'


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

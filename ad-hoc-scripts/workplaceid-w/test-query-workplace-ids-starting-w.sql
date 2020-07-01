SELECT 
	estab."NmdsID",
	CASE WHEN STRING_AGG(cssr."NmdsIDLetter", ',') IS NULL 
            THEN 'No postcode match' 
            ELSE STRING_AGG(DISTINCT concat(cssr."NmdsIDLetter", trim(leading 'W' from estab."NmdsID")), ',')
    END AS newWorkplaceId,
	estab."PostCode",
    trim(trailing from REVERSE(substring(REVERSE(UPPER(estab."PostCode")) from 4))) AS MatchedPcodePrefix,
	estab."NameValue",
    STRING_AGG(DISTINCT cssr."LocalCustodianCode"::text, ',') AS CustodianCodes,
    STRING_AGG(DISTINCT cssr."LocalAuthority", ',') AS LAs
FROM 
	cqc."Establishment" estab 
LEFT OUTER JOIN
	cqcref."pcode" pcode 
		ON trim(trailing from 
                REVERSE(
                    substring(
                        REVERSE(
                            UPPER(pcode."postcode")
                        ) 
                    from 4)
                )
            )
            /* Some postcodes in the establishment table don't have spaces.
             What we want is everything up to the last 3 chars.
             We're reversing, removing the first 3 chars, reversing again, 
             and then adding '%' to use LIKE to find postcodes that start with the result */
            = trim(trailing from 
                REVERSE(
                    substring(
                        REVERSE(
                            UPPER(estab."PostCode")
                        ) 
                    from 4)
                )
            )
LEFT OUTER JOIN
	cqc."Cssr" cssr ON cssr."LocalCustodianCode" = pcode."local_custodian_code"
WHERE 
	estab."NmdsID" LIKE 'W%'
    AND estab."Archived" = false
    AND cssr."NmdsIDLetter" IS NOT NULL
GROUP BY 
    estab."NmdsID", 
	estab."PostCode",
	estab."NameValue"
ORDER BY 
    estab."NmdsID"
LIMIT 5;
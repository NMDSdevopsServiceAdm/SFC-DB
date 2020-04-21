SELECT 
	DISTINCT pcode."local_custodian_code",
    estab."NameValue" as EstabName,
	estab."NmdsID",
	cssr."NmdsIDLetter" as prefix,
	concat(cssr."NmdsIDLetter", trim(leading 'W' from estab."NmdsID")) as newWorkplaceId,
    UPPER(estab."PostCode") as EstabPostcode,
	cssr."LocalAuthority"
FROM 
	cqc."Establishment" estab 
LEFT OUTER JOIN
	cqcref."pcode" pcode 
		ON UPPER(substring(pcode."postcode" from '[^ ]+'::text))
			= UPPER(substring(estab."PostCode" from '[^ ]+'::text))
LEFT OUTER JOIN
	cqc."Cssr" cssr ON cssr."LocalCustodianCode" = pcode."local_custodian_code"
WHERE 
	estab."PostCode" LIKE 'W%'
ORDER BY
	estab."NameValue"	


--SELECT 
--    DISTINCT pcode."local_custodian_code"
--FROM 
--	cqcref."pcode" pcode 
--WHERE
--		 UPPER(substring(pcode."postcode" from '[^ ]+'::text))
--			LIKE 'DN20%'

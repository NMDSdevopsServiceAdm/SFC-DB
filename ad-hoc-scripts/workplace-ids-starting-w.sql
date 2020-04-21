SELECT 
	estab."NmdsID",
	cssr."NmdsIDLetter" as prefix,
	concat(cssr."NmdsIDLetter", trim(leading 'W' from estab."NmdsID")) as newWorkplaceId,
	UPPER(estab."PostCode") as postcode,
	pcode."local_custodian_code",
	cssr."LocalAuthority"
FROM 
	cqc."Establishment" estab 
LEFT OUTER JOIN
	cqcref."pcode" pcode 
		ON UPPER(pcode."postcode") 
			= UPPER(estab."PostCode")
LEFT OUTER JOIN
	cqc."Cssr" cssr ON cssr."LocalCustodianCode" = pcode."local_custodian_code"
WHERE 
	estab."NmdsID" LIKE 'W%'

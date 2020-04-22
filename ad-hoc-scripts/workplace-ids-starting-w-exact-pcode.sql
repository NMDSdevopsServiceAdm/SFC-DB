SELECT 
	estab."NmdsID",
	concat(cssr."NmdsIDLetter", trim(leading 'W' from estab."NmdsID")) AS newWorkplaceId,
	estab."PostCode",
	estab."NameValue",
    cssr."LocalCustodianCode",
    cssr."LocalAuthority"
FROM 
	cqc."Establishment" estab 
INNER JOIN
	cqcref."pcode" pcode ON pcode."postcode" = estab."PostCode"
INNER JOIN
	cqc."Cssr" cssr ON cssr."LocalCustodianCode" = pcode."local_custodian_code"
WHERE 
	estab."NmdsID" LIKE 'W%'
ORDER BY 
    estab."NmdsID"
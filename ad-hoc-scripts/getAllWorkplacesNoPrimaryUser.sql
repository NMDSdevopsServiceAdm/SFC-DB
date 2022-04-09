SELECT 
	DISTINCT est."EstablishmentID",
	est."NmdsID",
	est."NameValue", 
    est."DataOwner",
	(SELECT COUNT(0) FROM cqc."User" WHERE "IsPrimary" = true AND est."EstablishmentID" = "EstablishmentID") as prmyusr
FROM cqc."Establishment" as est
FULL OUTER JOIN cqc."User" as usr ON est."EstablishmentID" = usr."EstablishmentID"
LEFT JOIN cqc."Login" as login ON usr."RegistrationID" = login."RegistrationID"
WHERE 
    est."DataOwner" = 'Workplace'
AND
	est."Archived" = false
AND 
    0 = (SELECT COUNT(0) FROM cqc."User" WHERE "IsPrimary" = true AND est."EstablishmentID" = "EstablishmentID")
;
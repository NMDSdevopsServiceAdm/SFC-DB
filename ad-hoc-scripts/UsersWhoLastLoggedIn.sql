SELECT 
	est."EstablishmentID",
	est."NmdsID", 
	est."NameValue", 
	CASE
		WHEN est."IsParent" = true THEN 'Yes'
		ELSE 'No'
	END as IsParent,
	est."DataOwner",
	usr."FullNameValue",
	CASE
		WHEN usr."IsPrimary" = true THEN 'Yes'
		ELSE 'No'
	END as primaryuser,
	usr."EmailValue",
	to_char(login."LastLoggedIn", 'DD/MM/YYYY') as lastloggedin
FROM cqc."Establishment" as est
FULL OUTER JOIN cqc."User" as usr ON est."EstablishmentID" = usr."EstablishmentID"
LEFT JOIN cqc."Login" as login ON usr."RegistrationID" = login."RegistrationID"
WHERE
	login."LastLoggedIn" > DATE('2020-09-22')
AND
    est."MainServiceFKValue" IN ('24', '25', '20')
AND
	est."Archived" = false
AND
	usr."Archived" = false
;
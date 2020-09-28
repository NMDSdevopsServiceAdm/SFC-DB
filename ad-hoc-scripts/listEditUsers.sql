SELECT 
	est."NmdsID", 
	est."NameValue", 
	usr."FullNameValue",
    CASE
		WHEN usr."IsPrimary" = true THEN 'Yes'
		ELSE 'No'
	END as primaryuser,
    usr."EmailValue",
    srv."name" mainservice
FROM cqc."Establishment" as est
FULL OUTER JOIN cqc."User" as usr ON est."EstablishmentID" = usr."EstablishmentID"
LEFT JOIN cqc."services" as srv ON est."MainServiceFKValue" = srv."id"
WHERE
    est."DataOwner" = 'Workplace'
AND
	est."IsParent" = false
AND
	est."Archived" = false
AND
	usr."Archived" = false
AND
	usr."UserRoleValue" = 'Edit'
;
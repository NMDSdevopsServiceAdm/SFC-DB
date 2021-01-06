SELECT 
	est."EstablishmentID",
	est."NmdsID", 
	est."NameValue", 
    srv."name",
	CASE
		WHEN est."IsParent" = true THEN 'Yes'
		ELSE 'No'
	END as IsParent,
	est."DataOwner",
	(
		SELECT
	 		"NmdsID" 
	 	FROM 
	 		cqc."Establishment" as parent 
	 	WHERE est."ParentID" = parent."ParentID" 
		LIMIT 1
	) as parentid,
	usr."FullNameValue",
	CASE
		WHEN usr."IsPrimary" = true THEN 'Yes'
		ELSE 'No'
	END as primaryuser,
	usr."EmailValue"
FROM cqc."Establishment" as est
LEFT JOIN cqc."services" as srv ON est."MainServiceFKValue" = srv."id"
FULL OUTER JOIN cqc."User" as usr ON est."EstablishmentID" = usr."EstablishmentID"
WHERE
	est."MainServiceFKValue" IN (24, 25, 20)
AND
	est."Archived" = false
AND
	usr."Archived" = false
AND
	usr."UserRoleValue" = 'Edit';
SELECT 
	est."NmdsID", 
	est."NameValue", 
	usr."FullNameValue",
    CASE
		WHEN usr."IsPrimary" = true THEN 'Yes'
		ELSE 'No'
	END as primaryuser,
    usr."EmailValue",
    (
		SELECT 
			COUNT(0) 
		FROM cqc."Establishment" 
		WHERE 
			"ParentID" = est."EstablishmentID"
		AND 
			"DataOwner" = 'Workplace'
		AND 
			"Archived" = false
	) as subcountsubowned,
	(
		SELECT 
			COUNT(0) 
		FROM cqc."Establishment" 
		WHERE 
			"ParentID" = est."EstablishmentID"
		AND 
			"DataOwner" = 'Parent'
		AND 
			"Archived" = false
	) as subcountparentowned
FROM cqc."Establishment" as est
FULL OUTER JOIN cqc."User" as usr ON est."EstablishmentID" = usr."EstablishmentID"
WHERE
	est."IsParent" = true
AND
	est."Archived" = false
AND
	usr."Archived" = false
AND
	usr."UserRoleValue" = 'Edit'
;
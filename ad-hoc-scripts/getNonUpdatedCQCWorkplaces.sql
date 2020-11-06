SELECT 
	est."EstablishmentID",
	est."NmdsID", 
	est."NameValue", 
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
	CASE 
		WHEN wrk."updated" is null THEN to_char(est."updated", 'DD/MM/YYYY')
		WHEN est."updated" > wrk."updated" THEN to_char(est."updated", 'DD/MM/YYYY')
		ELSE to_char(wrk."updated", 'DD/MM/YYYY')
	END as lastupdated,
	to_char(est."updated", 'DD/MM/YYYY') as estupdated,
 	to_char(wrk."updated", 'DD/MM/YYYY') as wrkupdated,
	to_char(est."created", 'DD/MM/YYYY') as estcreated,
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
LEFT JOIN LATERAL(
 	SELECT
		"EstablishmentFK",
		"updated"
	FROM cqc."Worker"
	WHERE
		est."EstablishmentID" = "EstablishmentFK" 
 	ORDER BY "updated" DESC
  	LIMIT 1
) as wrk ON est."EstablishmentID" = wrk."EstablishmentFK"
WHERE
	(
		est."updated" < DATE('2019-02-01')  -- update date
		AND
		wrk."updated" < DATE('2020-02-01') -- update date
	)
AND
    est."IsRegulated" = true
AND
	est."Archived" = false
AND 
	usr."Archived" = false
AND
	usr."UserRoleValue" = 'Edit'
ORDER BY
	lastupdated DESC;
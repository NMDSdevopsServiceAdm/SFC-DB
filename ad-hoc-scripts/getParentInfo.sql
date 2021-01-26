SELECT 
	est."EstablishmentID",
    prnt."EstablishmentID" as prntID,
	prnt."NmdsID" as prntNmdsID,
	est."NmdsID",
    prnt."NameValue" as prntname, 
	est."NameValue", 
    est."DataOwner",
    usr."FullNameValue",
	CASE
		WHEN usr."IsPrimary" = true THEN 'Yes'
		ELSE 'No'
	END as primaryuser,
	usr."EmailValue"
FROM cqc."Establishment" as est
FULL OUTER JOIN cqc."Establishment" as prnt ON est."ParentID" = prnt."EstablishmentID"
FULL OUTER JOIN cqc."User" as usr ON prnt."EstablishmentID" = usr."EstablishmentID"
LEFT JOIN cqc."Login" as login ON usr."RegistrationID" = login."RegistrationID"
WHERE 
    est."NmdsID" IN (
**IDS**
    )
AND 
    est."DataOwner" = "Parent"
AND
	usr."Archived" = false
AND
	usr."UserRoleValue" = 'Edit';
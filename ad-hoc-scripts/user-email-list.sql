----------------------------------------------
-- This will generate the info needed.
-- You can run the full statement below on the command line in psql. 
-- Just copy and paste and hit enter - it copes fine with multi-line statements.
-- Run these three commands first (login details are your cloud foundry account login):
--
--      cf login
--      cf conduit sfcuatdb01 -- psql
--      \o [todays-date]_ASC-WDS-emails.csv
--
-- That last one will save the output in the specified file.
-- Sadly I didn't find a way of getting the output comma-separated, so I also had to do the following:
-- 1. Open in a text editor and replace all commas with semi-colons
-- 2. Still in text editor, replace all pipe characters (|) with commas
-- 3. Open in Excel, and use the TRIM function to remove all trailing spaces 
--      I created a new worksheet that referenced the original with formulas like this: =TRIM(Emails01!B1)
-- 4. Turn off the psql output redirection with this command: \o
-- 5. Type exit to exit psql.
-- 6. !! IMPORTANT! Don't email the results! Instead, send via Slack.
----------------------------------------------
select 
	usr."EmailValue" as "EmailAddress",
  usr."FullNameValue" as "UserName",
	usr."EstablishmentID",
	estab."NmdsID",
  usr."UserRoleValue" as "UserType",
  estab."NameValue" as "WorkplaceName",
  CASE 
    WHEN estab."IsParent" = true  THEN 'Parent'
    WHEN estab."IsParent" = false AND estab."ParentID" is not null  THEN 'Sub'
    ELSE 'Standalone'
  END AS "ParentStatus",
  estab."ParentID",
  CASE 
    WHEN estab."ParentID" is not null THEN estab."DataOwner"
    ELSE null
  END AS "DataOwner"
from 
	cqc."User" usr 
inner join
	cqc."Establishment" estab on usr."EstablishmentID" = estab."EstablishmentID"
where
  usr."EmailValue" is not null
  and usr."EmailValue" <> ''
order by 
	"ParentStatus", usr."EmailValue";
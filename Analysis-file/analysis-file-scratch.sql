SET SEARCH_PATH TO cqc;
SELECT 
       COALESCE("NumberOfStaffValue", -1) totalstaff, --****COALESCE**** -- 038
       CASE 
          WHEN "StartersValue" = 'None' THEN 0 -- happens when you actively select "None"
          WHEN "StartersValue" = 'Don''t know' THEN -2
          WHEN "StartersValue" IS NULL THEN -1 -- happens when you have brand new workplace and nothing entered
          ELSE (SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Starters')
       END totalstarters --****COALESCE**** -- 044
FROM   
   "Establishment" e 
WHERE
   "NmdsID" = 'I1003200'; 
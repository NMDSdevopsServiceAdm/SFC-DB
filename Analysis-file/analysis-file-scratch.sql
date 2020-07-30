------------------------------
select * FROM "EstablishmentJobs" ej WHERE ej."EstablishmentID" = 2532;
select distinct "Total" FROM "EstablishmentJobs" ej order by "Total";
select distinct "JobName" FROM "Job" j where j."JobID" IN (25,10,11,12,3,29,20,16);
------------------------------
select '25,10,11,12,3,29,20,16';
select distinct "JobName" FROM "Job" j where j."JobID" IN (25,10,11,12,3,29,20,16);
select '26,15,13,22,28,14';
select distinct "JobName" FROM "Job" j where j."JobID" IN (26,15,13,22,28,14);
select '27,18,23,4,24,17';
select distinct "JobName" FROM "Job" j where j."JobID" IN (27,18,23,4,24,17);
select '2,5,21,1,19,7,8,9,6';
select "JobID", "JobName" FROM "Job" j where j."JobID" IN (2,5,21,1,19,7,8,9,6);
select "JobID", "JobName" FROM "Job" j where j."JobID" = 26;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 15;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 13;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 22;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 28;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 27;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 25;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 10;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 11;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 12;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 3 ;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 18;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 23;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 4 ;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 29;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 20;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 14;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 2 ;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 5 ;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 21;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 1 ;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 24;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 19;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 17;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 16;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 7 ;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 8 ;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 9 ;
select "JobID", "JobName" FROM "Job" j where j."JobID" = 6 ;
------------------------------
SELECT 
       "EstablishmentID",
	   "StartersValue",
	   "LeaversValue",
	   "VacanciesValue",
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Starters'),-1) END jr28strt, --****COALESCE**** -- 064
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Leavers'),-1) END jr28stop, --****COALESCE**** -- 064a
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Vacancies'),-1) END jr28vacy, --****COALESCE**** -- 065
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (25,10,11,12,3,29,20,16) AND "JobType" = 'Starters'),-1) END jr29strt, --****COALESCE**** -- 074
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (25,10,11,12,3,29,20,16) AND "JobType" = 'Leavers'),-1) END jr29stop, --****COALESCE**** -- 075
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (25,10,11,12,3,29,20,16) AND "JobType" = 'Vacancies'),-1) END jr29vacy, --****COALESCE**** -- 076
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (27,18,23,4,24,17) AND "JobType" = 'Starters'),-1) END jr31strt, --****COALESCE**** -- 074
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (27,18,23,4,24,17) AND "JobType" = 'Leavers'),-1) END jr31stop, --****COALESCE**** -- 075
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (27,18,23,4,24,17) AND "JobType" = 'Vacancies'),-1) END jr31vacy --****COALESCE**** -- 076
FROM   
   "Establishment" e 
WHERE
	"NmdsID" = 'I1003200'
--JOIN 
--   "Afr1BatchiSkAi0mo" b ON e."EstablishmentID" = b."EstablishmentID" AND b."BatchNo" = 1;
------------------------------
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
------------------------------
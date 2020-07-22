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
SELECT
       COALESCE("NumberOfStaffValue", -1) totalstaff, --****COALESCE**** -- 038
       TO_CHAR("NumberOfStaffChangedAt",'DD/MM/YYYY') totalstaff_changedate, -- 039
       TO_CHAR("NumberOfStaffSavedAt",'DD/MM/YYYY') totalstaff_savedate, -- 040
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "Archived" = false) wkrrecs, -- 041
       (
          SELECT TO_CHAR(MAX("When"),'DD/MM/YYYY')
          FROM   "WorkerAudit"
          WHERE  "WorkerFK" IN (SELECT "ID" FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID")
          AND    "EventType" IN ('created','deleted','updated')
       ) wkrrecs_changedate, -- 042
       TO_CHAR("NumberOfStaffSavedAt",'DD/MM/YYYY') wkrrecs_WDFsavedate, -- 043
       CASE 
          WHEN "StartersValue" = 'None' THEN 0
          WHEN "StartersValue" = 'Don''t know' THEN -2
          WHEN "StartersValue" IS NULL THEN -1
          ELSE (SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Starters')
       END totalstarters, --****COALESCE**** -- 044
       TO_CHAR("StartersChangedAt",'DD/MM/YYYY') totalstarters_changedate, -- 045
       TO_CHAR("StartersSavedAt",'DD/MM/YYYY') totalstarters_savedate, -- 046
       CASE
          WHEN "LeaversValue" = 'None' THEN 0
          WHEN "LeaversValue" = 'Don''t know' THEN -2
          WHEN "LeaversValue" IS NULL THEN -1
          ELSE (SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Leavers')
       END totalleavers, --****COALESCE**** -- 047
       TO_CHAR("LeaversChangedAt",'DD/MM/YYYY') totalleavers_changedate, -- 048
       TO_CHAR("LeaversSavedAt",'DD/MM/YYYY') totalleavers_savedate, -- 049
       CASE
          WHEN "VacanciesValue" = 'None' THEN 0
          WHEN "VacanciesValue" = 'Don''t know' THEN -2
          WHEN "VacanciesValue" IS NULL THEN -1
          ELSE (SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Vacancies')
       END totalvacancies, --****COALESCE**** -- 050
       TO_CHAR("VacanciesChangedAt",'DD/MM/YYYY') totalvacancies_changedate, -- 051
       TO_CHAR("VacanciesSavedAt",'DD/MM/YYYY') totalvacancies_savedate, -- 052
       (
          SELECT CASE name
                    WHEN 'Care home services with nursing' THEN 1
                    WHEN 'Care home services without nursing' THEN 2
                    WHEN 'Other adult residential care services' THEN 5
                    WHEN 'Day care and day services' THEN 6
                    WHEN 'Other adult day care services' THEN 7
                    WHEN 'Domiciliary care services' THEN 8
                    WHEN 'Domestic services and home help' THEN 10
                    WHEN 'Other adult domiciliary care service' THEN 12
                    WHEN 'Carers support' THEN 13
                    WHEN 'Short breaks / respite care' THEN 14
                    WHEN 'Community support and outreach' THEN 15
                    WHEN 'Social work and care management' THEN 16
                    WHEN 'Shared lives' THEN 17
                    WHEN 'Disability adaptations / assistive technology services' THEN 18
                    WHEN 'Occupational / employment-related services' THEN 19
                    WHEN 'Information and advice services' THEN 20
                    WHEN 'Other adult community care service' THEN 21
                    WHEN 'Any other services' THEN 52
                    WHEN 'Sheltered housing' THEN 53
                    WHEN 'Extra care housing services' THEN 54
                    WHEN 'Supported living services' THEN 55
                    WHEN 'Specialist college services' THEN 60
                    WHEN 'Community based services for people with a learning disability' THEN 61
                    WHEN 'Community based services for people with mental health needs' THEN 62
                    WHEN 'Community based services for people who misuse substances' THEN 63
                    WHEN 'Community healthcare services' THEN 64
                    WHEN 'Hospice services' THEN 66
                    WHEN 'Long term conditions services' THEN 67
                    WHEN 'Hospital services for people with mental health needs, learning disabilities and/or problems with substance misuse' THEN 68
                    WHEN 'Rehabilitation services' THEN 69
                    WHEN 'Residential substance misuse treatment/ rehabilitation services' THEN 70
                    WHEN 'Other healthcare service' THEN 71
                    WHEN 'Head office services' THEN 72
                    WHEN 'Nurses agency' THEN 74
                    WHEN 'Any childrens / young peoples services' THEN 75
                 END
          FROM   services
          WHERE  id = e."MainServiceFKValue"
       ) mainstid, -- 053
       TO_CHAR("MainServiceFKChangedAt",'DD/MM/YYYY') mainstid_changedate, -- 054
       TO_CHAR("MainServiceFKSavedAt",'DD/MM/YYYY') mainstid_savedate, -- 055
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "Archived" = false LIMIT 1),0) jr28flag, -- 056
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "ContractValue" = 'Permanent' AND "Archived" = false) jr28perm, -- 057
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "ContractValue" = 'Temporary' AND "Archived" = false) jr28temp, -- 058
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr28pool, -- 059
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "ContractValue" = 'Agency' AND "Archived" = false) jr28agcy, -- 060
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "ContractValue" = 'Other' AND "Archived" = false) jr28oth, -- 061
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr28emp, -- 062
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "Archived" = false) jr28work, -- 063
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Starters'),-1) jr28strt, --****COALESCE**** -- 064
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Leavers'),-1) jr28stop, --****COALESCE**** -- 064a
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Vacancies'),-1) jr28vacy, --****COALESCE**** -- 065
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (25,10,11,12,3,29,20,16) AND "Archived" = false LIMIT 1),0) jr29flag, -- 066
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (25,10,11,12,3,29,20,16) AND "ContractValue" = 'Permanent' AND "Archived" = false) jr29perm, -- 067
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (25,10,11,12,3,29,20,16) AND "ContractValue" = 'Temporary' AND "Archived" = false) jr29temp, -- 068
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (25,10,11,12,3,29,20,16) AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr29pool, -- 069
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (25,10,11,12,3,29,20,16) AND "ContractValue" = 'Agency' AND "Archived" = false) jr29agcy, -- 070
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (25,10,11,12,3,29,20,16) AND "ContractValue" = 'Other' AND "Archived" = false) jr29oth, -- 071
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (25,10,11,12,3,29,20,16) AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr29emp, -- 072
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (25,10,11,12,3,29,20,16) AND "Archived" = false) jr29work, -- 073
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (25,10,11,12,3,29,20,16) AND "JobType" = 'Starters'),-1) jr29strt, --****COALESCE**** -- 074
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (25,10,11,12,3,29,20,16) AND "JobType" = 'Leavers'),-1) jr29stop, --****COALESCE**** -- 075
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (25,10,11,12,3,29,20,16) AND "JobType" = 'Vacancies'),-1) jr29vacy, --****COALESCE**** -- 076
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (26,15,13,22,28,14) AND "Archived" = false LIMIT 1),0) jr30flag, -- 077
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (26,15,13,22,28,14) AND "ContractValue" = 'Permanent' AND "Archived" = false) jr30perm, -- 078
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (26,15,13,22,28,14) AND "ContractValue" = 'Temporary' AND "Archived" = false) jr30temp, -- 079
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (26,15,13,22,28,14) AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr30pool, -- 080
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (26,15,13,22,28,14) AND "ContractValue" = 'Agency' AND "Archived" = false) jr30agcy, -- 081
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (26,15,13,22,28,14) AND "ContractValue" = 'Other' AND "Archived" = false) jr30oth, -- 082
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (26,15,13,22,28,14) AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr30emp, -- 083
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (26,15,13,22,28,14) AND "Archived" = false) jr30work, -- 084
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (26,15,13,22,28,14) AND "JobType" = 'Starters'),-1) jr30strt, --****COALESCE**** -- 085
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (26,15,13,22,28,14) AND "JobType" = 'Leavers'),-1) jr30stop, --****COALESCE**** -- 086
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (26,15,13,22,28,14) AND "JobType" = 'Vacancies'),-1) jr30vacy, --****COALESCE**** -- 087
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (27,18,23,4,24,17) AND "Archived" = false LIMIT 1),0) jr31flag, -- 088
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (27,18,23,4,24,17) AND "ContractValue" = 'Permanent' AND "Archived" = false) jr31perm, -- 089
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (27,18,23,4,24,17) AND "ContractValue" = 'Temporary' AND "Archived" = false) jr31temp, -- 090
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (27,18,23,4,24,17) AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr31pool, -- 091
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (27,18,23,4,24,17) AND "ContractValue" = 'Agency' AND "Archived" = false) jr31agcy, -- 092
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (27,18,23,4,24,17) AND "ContractValue" = 'Other' AND "Archived" = false) jr31oth, -- 093
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (27,18,23,4,24,17) AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr31emp, -- 094
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (27,18,23,4,24,17) AND "Archived" = false) jr31work, -- 095
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (27,18,23,4,24,17) AND "JobType" = 'Starters'),-1) jr31strt, --****COALESCE**** -- 096
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (27,18,23,4,24,17) AND "JobType" = 'Leavers'),-1) jr31stop, --****COALESCE**** -- 097
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (27,18,23,4,24,17) AND "JobType" = 'Vacancies'),-1) jr31vacy, --****COALESCE**** -- 098
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (2,5,21,1,19,7,8,9,6) AND "Archived" = false LIMIT 1),0) jr32flag, -- 099
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (2,5,21,1,19,7,8,9,6) AND "ContractValue" = 'Permanent' AND "Archived" = false) jr32perm, -- 100
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (2,5,21,1,19,7,8,9,6) AND "ContractValue" = 'Temporary' AND "Archived" = false) jr32temp, -- 101
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (2,5,21,1,19,7,8,9,6) AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr32pool, -- 102
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (2,5,21,1,19,7,8,9,6) AND "ContractValue" = 'Agency' AND "Archived" = false) jr32agcy, -- 103
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (2,5,21,1,19,7,8,9,6) AND "ContractValue" = 'Other' AND "Archived" = false) jr32oth, -- 104
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (2,5,21,1,19,7,8,9,6) AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr32emp, -- 105
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (2,5,21,1,19,7,8,9,6) AND "Archived" = false) jr32work, -- 106
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (2,5,21,1,19,7,8,9,6) AND "JobType" = 'Starters'),-1) jr32strt, --****COALESCE**** -- 107
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (2,5,21,1,19,7,8,9,6) AND "JobType" = 'Leavers'),-1) jr32stop, --****COALESCE**** -- 108
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (2,5,21,1,19,7,8,9,6) AND "JobType" = 'Vacancies'),-1) jr32vacy, --****COALESCE**** -- 109
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 26 AND "Archived" = false LIMIT 1),0) jr01flag, -- 110
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 26 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr01perm, -- 111
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 26 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr01temp, -- 112
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 26 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr01pool, -- 113
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 26 AND "ContractValue" = 'Agency' AND "Archived" = false) jr01agcy, -- 114
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 26 AND "ContractValue" = 'Other' AND "Archived" = false) jr01oth, -- 115
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 26 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr01emp, -- 116
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 26 AND "Archived" = false) jr01work, -- 117
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 26 AND "JobType" = 'Starters'),-1) jr01strt, --****COALESCE**** -- 118
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 26 AND "JobType" = 'Leavers'),-1) jr01stop, --****COALESCE**** -- 119
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 26 AND "JobType" = 'Vacancies'),-1) jr01vacy, --****COALESCE**** -- 120
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 15 AND "Archived" = false LIMIT 1),0) jr02flag, -- 121
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 15 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr02perm, -- 122
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 15 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr02temp, -- 123
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 15 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr02pool, -- 124
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 15 AND "ContractValue" = 'Agency' AND "Archived" = false) jr02agcy, -- 125
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 15 AND "ContractValue" = 'Other' AND "Archived" = false) jr02oth, -- 126
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 15 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr02emp, -- 127
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 15 AND "Archived" = false) jr02work, -- 128
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 15 AND "JobType" = 'Starters'),-1) jr02strt, --****COALESCE**** -- 129
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 15 AND "JobType" = 'Leavers'),-1) jr02stop, --****COALESCE**** -- 130
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 15 AND "JobType" = 'Vacancies'),-1) jr02vacy, --****COALESCE**** -- 131
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 13 AND "Archived" = false LIMIT 1),0) jr03flag, -- 132
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 13 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr03perm, -- 133
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 13 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr03temp, -- 134
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 13 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr03pool, -- 135
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 13 AND "ContractValue" = 'Agency' AND "Archived" = false) jr03agcy, -- 136
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 13 AND "ContractValue" = 'Other' AND "Archived" = false) jr03oth, -- 137
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 13 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr03emp, -- 138
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 13 AND "Archived" = false) jr03work, -- 139
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 13 AND "JobType" = 'Starters'),-1) jr03strt, --****COALESCE**** -- 140
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 13 AND "JobType" = 'Leavers'),-1) jr03stop, --****COALESCE**** -- 141
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 13 AND "JobType" = 'Vacancies'),-1) jr03vacy, --****COALESCE**** -- 142
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 22 AND "Archived" = false LIMIT 1),0) jr04flag, -- 143
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 22 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr04perm, -- 144
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 22 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr04temp, -- 145
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 22 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr04pool, -- 146
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 22 AND "ContractValue" = 'Agency' AND "Archived" = false) jr04agcy, -- 147
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 22 AND "ContractValue" = 'Other' AND "Archived" = false) jr04oth, -- 148
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 22 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr04emp, -- 149
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 22 AND "Archived" = false) jr04work, -- 150
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 22 AND "JobType" = 'Starters'),-1) jr04strt, --****COALESCE**** -- 151
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 22 AND "JobType" = 'Leavers'),-1) jr04stop, --****COALESCE**** -- 152
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 22 AND "JobType" = 'Vacancies'),-1) jr04vacy, --****COALESCE**** -- 153
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 28 AND "Archived" = false LIMIT 1),0) jr05flag, -- 154
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 28 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr05perm, -- 155
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 28 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr05temp, -- 156
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 28 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr05pool, -- 157
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 28 AND "ContractValue" = 'Agency' AND "Archived" = false) jr05agcy, -- 158
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 28 AND "ContractValue" = 'Other' AND "Archived" = false) jr05oth, -- 159
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 28 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr05emp, -- 160
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 28 AND "Archived" = false) jr05work, -- 161
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 28 AND "JobType" = 'Starters'),-1) jr05strt, --****COALESCE**** -- 162
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 28 AND "JobType" = 'Leavers'),-1) jr05stop, --****COALESCE**** -- 163
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 28 AND "JobType" = 'Vacancies'),-1) jr05vacy, --****COALESCE**** -- 164
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 27 AND "Archived" = false LIMIT 1),0) jr06flag, -- 165
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 27 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr06perm, -- 166
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 27 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr06temp, -- 167
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 27 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr06pool, -- 168
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 27 AND "ContractValue" = 'Agency' AND "Archived" = false) jr06agcy, -- 169
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 27 AND "ContractValue" = 'Other' AND "Archived" = false) jr06oth, -- 170
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 27 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr06emp, -- 171
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 27 AND "Archived" = false) jr06work, -- 172
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 27 AND "JobType" = 'Starters'),-1) jr06strt, --****COALESCE**** -- 173
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 27 AND "JobType" = 'Leavers'),-1) jr06stop, --****COALESCE**** -- 174
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 27 AND "JobType" = 'Vacancies'),-1) jr06vacy, --****COALESCE**** -- 175
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 25 AND "Archived" = false LIMIT 1),0) jr07flag, -- 176
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 25 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr07perm, -- 177
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 25 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr07temp, -- 178
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 25 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr07pool, -- 179
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 25 AND "ContractValue" = 'Agency' AND "Archived" = false) jr07agcy, -- 180
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 25 AND "ContractValue" = 'Other' AND "Archived" = false) jr07oth, -- 181
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 25 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr07emp, -- 182
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 25 AND "Archived" = false) jr07work, -- 183
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 25 AND "JobType" = 'Starters'),-1) jr07strt, --****COALESCE**** -- 184
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 25 AND "JobType" = 'Leavers'),-1) jr07stop, --****COALESCE**** -- 185
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 25 AND "JobType" = 'Vacancies'),-1) jr07vacy, --****COALESCE**** -- 186
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 10 AND "Archived" = false LIMIT 1),0) jr08flag, -- 187
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 10 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr08perm, -- 188
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 10 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr08temp, -- 189
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 10 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr08pool, -- 190
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 10 AND "ContractValue" = 'Agency' AND "Archived" = false) jr08agcy, -- 191
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 10 AND "ContractValue" = 'Other' AND "Archived" = false) jr08oth, -- 192
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 10 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr08emp, -- 193
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 10 AND "Archived" = false) jr08work, -- 194
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 10 AND "JobType" = 'Starters'),-1) jr08strt, --****COALESCE**** -- 195
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 10 AND "JobType" = 'Leavers'),-1) jr08stop, --****COALESCE**** -- 196
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 10 AND "JobType" = 'Vacancies'),-1) jr08vacy, --****COALESCE**** -- 197
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 11 AND "Archived" = false LIMIT 1),0) jr09flag, -- 198
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 11 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr09perm, -- 199
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 11 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr09temp, -- 200
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 11 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr09pool, -- 201
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 11 AND "ContractValue" = 'Agency' AND "Archived" = false) jr09agcy, -- 202
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 11 AND "ContractValue" = 'Other' AND "Archived" = false) jr09oth, -- 203
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 11 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr09emp, -- 204
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 11 AND "Archived" = false) jr09work, -- 205
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 11 AND "JobType" = 'Starters'),-1) jr09strt, --****COALESCE**** -- 206
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 11 AND "JobType" = 'Leavers'),-1) jr09stop, --****COALESCE**** -- 207
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 11 AND "JobType" = 'Vacancies'),-1) jr09vacy, --****COALESCE**** -- 208
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 12 AND "Archived" = false LIMIT 1),0) jr10flag, -- 209
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 12 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr10perm, -- 210
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 12 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr10temp, -- 211
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 12 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr10pool, -- 212
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 12 AND "ContractValue" = 'Agency' AND "Archived" = false) jr10agcy, -- 213
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 12 AND "ContractValue" = 'Other' AND "Archived" = false) jr10oth, -- 214
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 12 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr10emp, -- 215
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 12 AND "Archived" = false) jr10work, -- 216
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 12 AND "JobType" = 'Starters'),-1) jr10strt, --****COALESCE**** -- 217
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 12 AND "JobType" = 'Leavers'),-1) jr10stop, --****COALESCE**** -- 218
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 12 AND "JobType" = 'Vacancies'),-1) jr10vacy, --****COALESCE**** -- 219
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 3 AND "Archived" = false LIMIT 1),0) jr11flag, -- 220
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 3 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr11perm, -- 221
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 3 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr11temp, -- 222
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 3 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr11pool, -- 223
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 3 AND "ContractValue" = 'Agency' AND "Archived" = false) jr11agcy, -- 224
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 3 AND "ContractValue" = 'Other' AND "Archived" = false) jr11oth, -- 225
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 3 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr11emp, -- 226
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 3 AND "Archived" = false) jr11work, -- 227
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 3 AND "JobType" = 'Starters'),-1) jr11strt, --****COALESCE**** -- 228
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 3 AND "JobType" = 'Leavers'),-1) jr11stop, --****COALESCE**** -- 229
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 3 AND "JobType" = 'Vacancies'),-1) jr11vacy, --****COALESCE**** -- 230
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 18 AND "Archived" = false LIMIT 1),0) jr15flag, -- 231
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 18 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr15perm, -- 232
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 18 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr15temp, -- 233
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 18 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr15pool, -- 234
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 18 AND "ContractValue" = 'Agency' AND "Archived" = false) jr15agcy, -- 235
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 18 AND "ContractValue" = 'Other' AND "Archived" = false) jr15oth, -- 236
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 18 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr15emp, -- 237
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 18 AND "Archived" = false) jr15work, -- 238
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 18 AND "JobType" = 'Starters'),-1) jr15strt, --****COALESCE**** -- 239
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 18 AND "JobType" = 'Leavers'),-1) jr15stop, --****COALESCE**** -- 240
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 18 AND "JobType" = 'Vacancies'),-1) jr15vacy, --****COALESCE**** -- 241
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 23 AND "Archived" = false LIMIT 1),0) jr16flag, -- 242
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 23 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr16perm, -- 243
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 23 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr16temp, -- 244
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 23 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr16pool, -- 245
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 23 AND "ContractValue" = 'Agency' AND "Archived" = false) jr16agcy, -- 246
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 23 AND "ContractValue" = 'Other' AND "Archived" = false) jr16oth, -- 247
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 23 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr16emp, -- 248
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 23 AND "Archived" = false) jr16work, -- 249
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 23 AND "JobType" = 'Starters'),-1) jr16strt, --****COALESCE**** -- 250
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 23 AND "JobType" = 'Leavers'),-1) jr16stop, --****COALESCE**** -- 251
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 23 AND "JobType" = 'Vacancies'),-1) jr16vacy, --****COALESCE**** -- 252
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 4 AND "Archived" = false LIMIT 1),0) jr17flag, -- 253
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 4 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr17perm, -- 254
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 4 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr17temp, -- 255
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 4 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr17pool, -- 256
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 4 AND "ContractValue" = 'Agency' AND "Archived" = false) jr17agcy, -- 257
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 4 AND "ContractValue" = 'Other' AND "Archived" = false) jr17oth, -- 258
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 4 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr17emp, -- 259
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 4 AND "Archived" = false) jr17work, -- 260
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 4 AND "JobType" = 'Starters'),-1) jr17strt, --****COALESCE**** -- 261
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 4 AND "JobType" = 'Leavers'),-1) jr17stop, --****COALESCE**** -- 262
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 4 AND "JobType" = 'Vacancies'),-1) jr17vacy, --****COALESCE**** -- 263
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 29 AND "Archived" = false LIMIT 1),0) jr22flag, -- 264
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 29 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr22perm, -- 265
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 29 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr22temp, -- 266
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 29 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr22pool, -- 267
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 29 AND "ContractValue" = 'Agency' AND "Archived" = false) jr22agcy, -- 268
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 29 AND "ContractValue" = 'Other' AND "Archived" = false) jr22oth, -- 269
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 29 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr22emp, -- 270
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 29 AND "Archived" = false) jr22work, -- 271
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 29 AND "JobType" = 'Starters'),-1) jr22strt, --****COALESCE**** -- 272
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 29 AND "JobType" = 'Leavers'),-1) jr22stop, --****COALESCE**** -- 273
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 29 AND "JobType" = 'Vacancies'),-1) jr22vacy, --****COALESCE**** -- 274
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 20 AND "Archived" = false LIMIT 1),0) jr23flag, -- 275
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 20 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr23perm, -- 276
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 20 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr23temp, -- 277
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 20 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr23pool, -- 278
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 20 AND "ContractValue" = 'Agency' AND "Archived" = false) jr23agcy, -- 279
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 20 AND "ContractValue" = 'Other' AND "Archived" = false) jr23oth, -- 280
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 20 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr23emp, -- 281
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 20 AND "Archived" = false) jr23work, -- 282
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 20 AND "JobType" = 'Starters'),-1) jr23strt, --****COALESCE**** -- 283
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 20 AND "JobType" = 'Leavers'),-1) jr23stop, --****COALESCE**** -- 284
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 20 AND "JobType" = 'Vacancies'),-1) jr23vacy, --****COALESCE**** -- 285
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 14 AND "Archived" = false LIMIT 1),0) jr24flag, -- 286
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 14 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr24perm, -- 287
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 14 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr24temp, -- 288
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 14 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr24pool, -- 289
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 14 AND "ContractValue" = 'Agency' AND "Archived" = false) jr24agcy, -- 290
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 14 AND "ContractValue" = 'Other' AND "Archived" = false) jr24oth, -- 291
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 14 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr24emp, -- 292
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 14 AND "Archived" = false) jr24work, -- 293
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 14 AND "JobType" = 'Starters'),-1) jr24strt, --****COALESCE**** -- 294
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 14 AND "JobType" = 'Leavers'),-1) jr24stop, --****COALESCE**** -- 295
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 14 AND "JobType" = 'Vacancies'),-1) jr24vacy, --****COALESCE**** -- 296
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 2 AND "Archived" = false LIMIT 1),0) jr25flag, -- 297
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 2 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr25perm, -- 298
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 2 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr25temp, -- 299
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 2 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr25pool, -- 300
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 2 AND "ContractValue" = 'Agency' AND "Archived" = false) jr25agcy, -- 301
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 2 AND "ContractValue" = 'Other' AND "Archived" = false) jr25oth, -- 302
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 2 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr25emp, -- 303
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 2 AND "Archived" = false) jr25work, -- 304
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 2 AND "JobType" = 'Starters'),-1) jr25strt, --****COALESCE**** -- 305
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 2 AND "JobType" = 'Leavers'),-1) jr25stop, --****COALESCE**** -- 306
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 2 AND "JobType" = 'Vacancies'),-1) jr25vacy, --****COALESCE**** -- 307
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 5 AND "Archived" = false LIMIT 1),0) jr26flag, -- 308
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 5 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr26perm, -- 309
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 5 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr26temp, -- 310
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 5 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr26pool, -- 311
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 5 AND "ContractValue" = 'Agency' AND "Archived" = false) jr26agcy, -- 312
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 5 AND "ContractValue" = 'Other' AND "Archived" = false) jr26oth, -- 313
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 5 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr26emp, -- 314
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 5 AND "Archived" = false) jr26work, -- 315
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 5 AND "JobType" = 'Starters'),-1) jr26strt, --****COALESCE**** -- 316
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 5 AND "JobType" = 'Leavers'),-1) jr26stop, --****COALESCE**** -- 317
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 5 AND "JobType" = 'Vacancies'),-1) jr26vacy, --****COALESCE**** -- 318
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 21 AND "Archived" = false LIMIT 1),0) jr27flag, -- 319
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 21 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr27perm, -- 320
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 21 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr27temp, -- 321
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 21 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr27pool, -- 322
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 21 AND "ContractValue" = 'Agency' AND "Archived" = false) jr27agcy, -- 323
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 21 AND "ContractValue" = 'Other' AND "Archived" = false) jr27oth, -- 324
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 21 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr27emp, -- 325
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 21 AND "Archived" = false) jr27work, -- 326
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 21 AND "JobType" = 'Starters'),-1) jr27strt, --****COALESCE**** -- 327
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 21 AND "JobType" = 'Leavers'),-1) jr27stop, --****COALESCE**** -- 328
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 21 AND "JobType" = 'Vacancies'),-1) jr27vacy, --****COALESCE**** -- 329
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 1 AND "Archived" = false LIMIT 1),0) jr34flag, -- 330
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 1 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr34perm, -- 331
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 1 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr34temp, -- 332
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 1 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr34pool, -- 333
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 1 AND "ContractValue" = 'Agency' AND "Archived" = false) jr34agcy, -- 334
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 1 AND "ContractValue" = 'Other' AND "Archived" = false) jr34oth, -- 335
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 1 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr34emp, -- 336
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 1 AND "Archived" = false) jr34work, -- 337
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 1 AND "JobType" = 'Starters'),-1) jr34strt, --****COALESCE**** -- 338
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 1 AND "JobType" = 'Leavers'),-1) jr34stop, --****COALESCE**** -- 339
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 1 AND "JobType" = 'Vacancies'),-1) jr34vacy, --****COALESCE**** -- 340
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 24 AND "Archived" = false LIMIT 1),0) jr35flag, -- 341
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 24 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr35perm, -- 342
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 24 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr35temp, -- 343
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 24 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr35pool, -- 344
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 24 AND "ContractValue" = 'Agency' AND "Archived" = false) jr35agcy, -- 345
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 24 AND "ContractValue" = 'Other' AND "Archived" = false) jr35oth, -- 346
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 24 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr35emp, -- 347
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 24 AND "Archived" = false) jr35work, -- 348
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 24 AND "JobType" = 'Starters'),-1) jr35strt, --****COALESCE**** -- 349
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 24 AND "JobType" = 'Leavers'),-1) jr35stop, --****COALESCE**** -- 350
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 24 AND "JobType" = 'Vacancies'),-1) jr35vacy, --****COALESCE**** -- 351
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 19 AND "Archived" = false LIMIT 1),0) jr36flag, -- 352
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 19 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr36perm, -- 353
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 19 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr36temp, -- 354
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 19 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr36pool, -- 355
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 19 AND "ContractValue" = 'Agency' AND "Archived" = false) jr36agcy, -- 356
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 19 AND "ContractValue" = 'Other' AND "Archived" = false) jr36oth, -- 357
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 19 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr36emp, -- 358
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 19 AND "Archived" = false) jr36work, -- 359
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 19 AND "JobType" = 'Starters'),-1) jr36strt, --****COALESCE**** -- 360
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 19 AND "JobType" = 'Leavers'),-1) jr36stop, --****COALESCE**** -- 361
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 19 AND "JobType" = 'Vacancies'),-1) jr36vacy, --****COALESCE**** -- 362
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 17 AND "Archived" = false LIMIT 1),0) jr37flag, -- 363
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 17 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr37perm, -- 364
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 17 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr37temp, -- 365
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 17 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr37pool, -- 366
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 17 AND "ContractValue" = 'Agency' AND "Archived" = false) jr37agcy, -- 367
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 17 AND "ContractValue" = 'Other' AND "Archived" = false) jr37oth, -- 368
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 17 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr37emp, -- 369
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 17 AND "Archived" = false) jr37work, -- 370
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 17 AND "JobType" = 'Starters'),-1) jr37strt, --****COALESCE**** -- 371
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 17 AND "JobType" = 'Leavers'),-1) jr37stop, --****COALESCE**** -- 372
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 17 AND "JobType" = 'Vacancies'),-1) jr37vacy, --****COALESCE**** -- 373
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 16 AND "Archived" = false LIMIT 1),0) jr38flag, -- 374
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 16 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr38perm, -- 375
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 16 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr38temp, -- 376
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 16 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr38pool, -- 377
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 16 AND "ContractValue" = 'Agency' AND "Archived" = false) jr38agcy, -- 378
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 16 AND "ContractValue" = 'Other' AND "Archived" = false) jr38oth, -- 379
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 16 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr38emp, -- 380
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 16 AND "Archived" = false) jr38work, -- 381
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 16 AND "JobType" = 'Starters'),-1) jr38strt, --****COALESCE**** -- 382
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 16 AND "JobType" = 'Leavers'),-1) jr38stop, --****COALESCE**** -- 383
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 16 AND "JobType" = 'Vacancies'),-1) jr38vacy, --****COALESCE**** -- 384
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 7 AND "Archived" = false LIMIT 1),0) jr39flag, -- 385
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 7 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr39perm, -- 386
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 7 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr39temp, -- 387
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 7 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr39pool, -- 388
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 7 AND "ContractValue" = 'Agency' AND "Archived" = false) jr39agcy, -- 389
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 7 AND "ContractValue" = 'Other' AND "Archived" = false) jr39oth, -- 390
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 7 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr39emp, -- 391
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 7 AND "Archived" = false) jr39work, -- 392
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 7 AND "JobType" = 'Starters'),-1) jr39strt, --****COALESCE**** -- 393
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 7 AND "JobType" = 'Leavers'),-1) jr39stop, --****COALESCE**** -- 394
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 7 AND "JobType" = 'Vacancies'),-1) jr39vacy, --****COALESCE**** -- 395
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 8 AND "Archived" = false LIMIT 1),0) jr40flag, -- 396
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 8 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr40perm, -- 397
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 8 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr40temp, -- 398
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 8 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr40pool, -- 399
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 8 AND "ContractValue" = 'Agency' AND "Archived" = false) jr40agcy, -- 400
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 8 AND "ContractValue" = 'Other' AND "Archived" = false) jr40oth, -- 401
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 8 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr40emp, -- 402
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 8 AND "Archived" = false) jr40work, -- 403
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 8 AND "JobType" = 'Starters'),-1) jr40strt, --****COALESCE**** -- 404
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 8 AND "JobType" = 'Leavers'),-1) jr40stop, --****COALESCE**** -- 405
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 8 AND "JobType" = 'Vacancies'),-1) jr40vacy, --****COALESCE**** -- 406
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 9 AND "Archived" = false LIMIT 1),0) jr41flag, -- 407
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 9 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr41perm, -- 408
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 9 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr41temp, -- 409
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 9 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr41pool, -- 410
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 9 AND "ContractValue" = 'Agency' AND "Archived" = false) jr41agcy, -- 411
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 9 AND "ContractValue" = 'Other' AND "Archived" = false) jr41oth, -- 412
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 9 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr41emp, -- 413
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 9 AND "Archived" = false) jr41work, -- 414
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 9 AND "JobType" = 'Starters'),-1) jr41strt, --****COALESCE**** -- 415
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 9 AND "JobType" = 'Leavers'),-1) jr41stop, --****COALESCE**** -- 416
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 9 AND "JobType" = 'Vacancies'),-1) jr41vacy, --****COALESCE**** -- 417
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 6 AND "Archived" = false LIMIT 1),0) jr42flag, -- 418
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 6 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr42perm, -- 419
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 6 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr42temp, -- 420
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 6 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr42pool, -- 421
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 6 AND "ContractValue" = 'Agency' AND "Archived" = false) jr42agcy, -- 422
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 6 AND "ContractValue" = 'Other' AND "Archived" = false) jr42oth, -- 423
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 6 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr42emp, -- 424
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 6 AND "Archived" = false) jr42work, -- 425
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 6 AND "JobType" = 'Starters'),-1) jr42strt, --****COALESCE**** -- 426
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 6 AND "JobType" = 'Leavers'),-1) jr42stop, --****COALESCE**** -- 427
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 6 AND "JobType" = 'Vacancies'),-1) jr42vacy, --****COALESCE**** -- 428
       TO_CHAR("ServiceUsersChangedAt",'DD/MM/YYYY') ut_changedate, -- 429
       TO_CHAR("ServiceUsersSavedAt",'DD/MM/YYYY') ut_savedate, -- 430
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 1 LIMIT 1),0) ut01flag, -- 431
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 2 LIMIT 1),0) ut02flag, -- 432
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 3 LIMIT 1),0) ut22flag, -- 433
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 4 LIMIT 1),0) ut23flag, -- 434
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 5 LIMIT 1),0) ut25flag, -- 435
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 6 LIMIT 1),0) ut26flag, -- 436
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 7 LIMIT 1),0) ut27flag, -- 437
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 8 LIMIT 1),0) ut46flag, -- 438
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 9 LIMIT 1),0) ut03flag, -- 439
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 10 LIMIT 1),0) ut28flag, -- 440
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 11 LIMIT 1),0) ut06flag, -- 441
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 12 LIMIT 1),0) ut29flag, -- 442
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 13 LIMIT 1),0) ut05flag, -- 443
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 14 LIMIT 1),0) ut04flag, -- 444
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 15 LIMIT 1),0) ut07flag, -- 445
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 16 LIMIT 1),0) ut08flag, -- 446
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 17 LIMIT 1),0) ut31flag, -- 447
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 18 LIMIT 1),0) ut09flag, -- 448
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 19 LIMIT 1),0) ut45flag, -- 449
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 20 LIMIT 1),0) ut18flag, -- 450
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 21 LIMIT 1),0) ut19flag, -- 451
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 22 LIMIT 1),0) ut20flag, -- 452
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 23 LIMIT 1),0) ut21flag, -- 453
       TO_CHAR(GREATEST("MainServiceFKChangedAt","OtherServicesChangedAt"),'DD/MM/YYYY') st_changedate, -- 454
       TO_CHAR(GREATEST("MainServiceFKSavedAt","OtherServicesSavedAt"),'DD/MM/YYYY') st_savedate, -- 455
       CASE
          WHEN "MainServiceFKValue" = 24 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 24) = 1 THEN 1
          ELSE 0
       END st01flag, -- 456
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 24 AND sc."Type" = 'Capacity'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st01cap, --****COALESCE**** -- 457
       CASE
          WHEN "MainServiceFKValue" = 24 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 24) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st01cap_changedate, -- 458
       CASE
          WHEN "MainServiceFKValue" = 24 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 24) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st01cap_savedate, -- 459
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 24 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st01util, --****COALESCE**** -- 460
       CASE
          WHEN "MainServiceFKValue" = 24 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 24) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st01util_changedate, -- 461
       CASE
          WHEN "MainServiceFKValue" = 24 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 24) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st01util_savedate, -- 462
       CASE
          WHEN "MainServiceFKValue" = 25 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 25) = 1 THEN 1
          ELSE 0
       END st02flag, -- 463
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 25 AND sc."Type" = 'Capacity'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st02cap, --****COALESCE**** -- 464
       CASE
          WHEN "MainServiceFKValue" = 25 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 25) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st02cap_changedate, -- 465
       CASE
          WHEN "MainServiceFKValue" = 25 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 25) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st02cap_savedate, -- 466
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 25 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st02util, --****COALESCE**** -- 467
       CASE
          WHEN "MainServiceFKValue" = 25 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 25) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st02util_changedate, -- 468
       CASE
          WHEN "MainServiceFKValue" = 25 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 25) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st02util_savedate, -- 469
       CASE
          WHEN "MainServiceFKValue" = 13 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 13) = 1 THEN 1
          ELSE 0
       END st53flag, -- 470
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 13 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st53util, --****COALESCE**** -- 471
       CASE
          WHEN "MainServiceFKValue" = 13 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 13) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st53util_changedate, -- 472
       CASE
          WHEN "MainServiceFKValue" = 13 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 13) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st53util_savedate, -- 473
       CASE
          WHEN "MainServiceFKValue" = 12 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 12) = 1 THEN 1
          ELSE 0
       END st05flag, -- 474
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 12 AND sc."Type" = 'Capacity'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st05cap, --****COALESCE**** -- 475
       CASE
          WHEN "MainServiceFKValue" = 12 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 12) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st05cap_changedate, -- 476
       CASE
          WHEN "MainServiceFKValue" = 12 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 12) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st05cap_savedate, -- 477
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 12 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st05util, --****COALESCE**** -- 478
       CASE
          WHEN "MainServiceFKValue" = 12 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 12) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st05util_changedate, -- 479
       CASE
          WHEN "MainServiceFKValue" = 12 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 12) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st05util_savedate, -- 480
       CASE
          WHEN "MainServiceFKValue" = 9 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 9) = 1 THEN 1
          ELSE 0
       END st06flag, -- 481
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 9 AND sc."Type" = 'Capacity'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st06cap, --****COALESCE**** -- 482
       CASE
          WHEN "MainServiceFKValue" = 9 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 9) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st06cap_changedate, -- 483
       CASE
          WHEN "MainServiceFKValue" = 9 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 9) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st06cap_savedate, -- 484
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 9 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st06util, --****COALESCE**** -- 485
       CASE
          WHEN "MainServiceFKValue" = 9 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 9) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st06util_changedate, -- 486
       CASE
          WHEN "MainServiceFKValue" = 9 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 9) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st06util_savedate, -- 487
       CASE
          WHEN "MainServiceFKValue" = 10 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 10) = 1 THEN 1
          ELSE 0
       END st07flag, -- 488
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 10 AND sc."Type" = 'Capacity'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st07cap, --****COALESCE**** -- 489
       CASE
          WHEN "MainServiceFKValue" = 10 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 10) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st07cap_changedate, -- 490
       CASE
          WHEN "MainServiceFKValue" = 10 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 10) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st07cap_savedate, -- 491
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 10 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st07util, --****COALESCE**** -- 492
       CASE
          WHEN "MainServiceFKValue" = 10 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 10) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st07util_changedate, -- 493
       CASE
          WHEN "MainServiceFKValue" = 10 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 10) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st07util_savedate, -- 494
       CASE
          WHEN "MainServiceFKValue" = 11 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 11) = 1 THEN 1
          ELSE 0
       END st10flag, -- 495
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 11 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st10util, --****COALESCE**** -- 496
       CASE
          WHEN "MainServiceFKValue" = 11 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 11) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st10util_changedate, -- 497
       CASE
          WHEN "MainServiceFKValue" = 11 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 11) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st10util_savedate, -- 498
       CASE
          WHEN "MainServiceFKValue" = 20 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 20) = 1 THEN 1
          ELSE 0
       END st08flag, -- 499
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 20 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st08util, --****COALESCE**** -- 500
       CASE
          WHEN "MainServiceFKValue" = 20 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 20) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st08util_changedate, -- 501
       CASE
          WHEN "MainServiceFKValue" = 20 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 20) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st08util_savedate, -- 502
       CASE
          WHEN "MainServiceFKValue" = 21 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 21) = 1 THEN 1
          ELSE 0
       END st54flag, -- 503
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 21 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st54util, --****COALESCE**** -- 504
       CASE
          WHEN "MainServiceFKValue" = 21 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 21) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st54util_changedate, -- 505
       CASE
          WHEN "MainServiceFKValue" = 21 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 21) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st54util_savedate, -- 506
       CASE
          WHEN "MainServiceFKValue" = 22 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 22) = 1 THEN 1
          ELSE 0
       END st74flag, -- 507
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 22 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st74util, --****COALESCE**** -- 508
       CASE
          WHEN "MainServiceFKValue" = 22 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 22) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st74util_changedate, -- 509
       CASE
          WHEN "MainServiceFKValue" = 22 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 22) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st74util_savedate, -- 510
       CASE
          WHEN "MainServiceFKValue" = 23 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 23) = 1 THEN 1
          ELSE 0
       END st55flag, -- 511
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 23 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st55util, --****COALESCE**** -- 512
       CASE
          WHEN "MainServiceFKValue" = 23 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 23) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st55util_changedate, -- 513
       CASE
          WHEN "MainServiceFKValue" = 23 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 23) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st55util_savedate, -- 514
       CASE
          WHEN "MainServiceFKValue" = 35 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 35) = 1 THEN 1
          ELSE 0
       END st73flag, -- 515
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 35 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st73util, --****COALESCE**** -- 516
       CASE
          WHEN "MainServiceFKValue" = 35 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 35) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st73util_changedate, -- 517
       CASE
          WHEN "MainServiceFKValue" = 35 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 35) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st73util_savedate, -- 518
       CASE
          WHEN "MainServiceFKValue" = 18 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 18) = 1 THEN 1
          ELSE 0
       END st12flag, -- 519
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 18 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st12util, --****COALESCE**** -- 520
       CASE
          WHEN "MainServiceFKValue" = 18 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 18) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st12util_changedate, -- 521
       CASE
          WHEN "MainServiceFKValue" = 18 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 18) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st12util_savedate, -- 522
       CASE
          WHEN "MainServiceFKValue" = 1 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 1) = 1 THEN 1
          ELSE 0
       END st13flag, -- 523
       CASE
          WHEN "MainServiceFKValue" = 2 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 2) = 1 THEN 1
          ELSE 0
       END st15flag, -- 524
       CASE
          WHEN "MainServiceFKValue" = 3 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 3) = 1 THEN 1
          ELSE 0
       END st18flag, -- 525
       CASE
          WHEN "MainServiceFKValue" = 4 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 4) = 1 THEN 1
          ELSE 0
       END st20flag, -- 526
       CASE
          WHEN "MainServiceFKValue" = 5 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 5) = 1 THEN 1
          ELSE 0
       END st19flag, -- 527
       CASE
          WHEN "MainServiceFKValue" = 19 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 19) = 1 THEN 1
          ELSE 0
       END st17flag, -- 528
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 19 AND sc."Type" = 'Capacity'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st17cap, --****COALESCE**** -- 529
       CASE
          WHEN "MainServiceFKValue" = 19 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 19) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st17cap_changedate, -- 530
       CASE
          WHEN "MainServiceFKValue" = 19 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 19) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st17cap_savedate, -- 531
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 19 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st17util --****COALESCE**** -- 532
FROM   
    "Establishment" e 
WHERE
   "NmdsID" = 'I1003200'; 

SET SEARCH_PATH TO cqc;
------------------------------
SELECT 
       COALESCE("NumberOfStaffValue", -1) totalstaff, --****COALESCE**** -- 038
       CASE 
          WHEN "StartersValue" = 'None' THEN 0 -- happens when you actively select "None"
          WHEN "StartersValue" = 'Don''t know' THEN -2
          WHEN "StartersValue" IS NULL THEN -1 -- happens when you have brand new workplace and nothing entered
          ELSE (SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Starters')
       END totalstarters, --****COALESCE**** -- 044
       CASE
          WHEN "LeaversValue" = 'None' THEN 0
          WHEN "LeaversValue" = 'Don''t know' THEN -2
          WHEN "LeaversValue" IS NULL THEN -1
          ELSE (SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Leavers')
       END totalleavers, --****COALESCE**** -- 047
       CASE
          WHEN "VacanciesValue" = 'None' THEN 0
          WHEN "VacanciesValue" = 'Don''t know' THEN -2
          WHEN "VacanciesValue" IS NULL THEN -1
          ELSE (SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Vacancies')
       END totalvacancies, --****COALESCE**** -- 050
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Starters'),-1) END jr28strt, --****COALESCE**** -- 064
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Leavers'),-1) END jr28stop, --****COALESCE**** -- 064a
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Vacancies'),-1) END jr28vacy, --****COALESCE**** -- 065
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (25,10,11,12,3,29,20,16) AND "JobType" = 'Starters'),-1) END jr29strt, --****COALESCE**** -- 074
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (25,10,11,12,3,29,20,16) AND "JobType" = 'Leavers'),-1) END jr29stop, --****COALESCE**** -- 075
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (25,10,11,12,3,29,20,16) AND "JobType" = 'Vacancies'),-1) END jr29vacy, --****COALESCE**** -- 076
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (26,15,13,22,28,14) AND "JobType" = 'Starters'),-1) END jr30strt, --****COALESCE**** -- 085
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (26,15,13,22,28,14) AND "JobType" = 'Leavers'),-1) END jr30stop, --****COALESCE**** -- 086
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (26,15,13,22,28,14) AND "JobType" = 'Vacancies'),-1) END jr30vacy, --****COALESCE**** -- 087
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (27,18,23,4,24,17) AND "JobType" = 'Starters'),-1) END jr31strt, --****COALESCE**** -- 096
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (27,18,23,4,24,17) AND "JobType" = 'Leavers'),-1) END jr31stop, --****COALESCE**** -- 097
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (27,18,23,4,24,17) AND "JobType" = 'Vacancies'),-1) END jr31vacy, --****COALESCE**** -- 098
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (2,5,21,1,19,7,8,9,6) AND "JobType" = 'Starters'),-1) END jr32strt, --****COALESCE**** -- 107
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (2,5,21,1,19,7,8,9,6) AND "JobType" = 'Leavers'),-1) END jr32stop, --****COALESCE**** -- 108
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (2,5,21,1,19,7,8,9,6) AND "JobType" = 'Vacancies'),-1) END jr32vacy, --****COALESCE**** -- 109
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 26 AND "JobType" = 'Starters'),-1) END jr01strt, --****COALESCE**** -- 118
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 26 AND "JobType" = 'Leavers'),-1) END jr01stop, --****COALESCE**** -- 119
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 26 AND "JobType" = 'Vacancies'),-1) END jr01vacy, --****COALESCE**** -- 120
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 15 AND "JobType" = 'Starters'),-1) END jr02strt, --****COALESCE**** -- 129
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 15 AND "JobType" = 'Leavers'),-1) END jr02stop, --****COALESCE**** -- 130
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 15 AND "JobType" = 'Vacancies'),-1) END jr02vacy, --****COALESCE**** -- 131
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 13 AND "JobType" = 'Starters'),-1) END jr03strt, --****COALESCE**** -- 140
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 13 AND "JobType" = 'Leavers'),-1) END jr03stop, --****COALESCE**** -- 141
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 13 AND "JobType" = 'Vacancies'),-1) END jr03vacy, --****COALESCE**** -- 142
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 22 AND "JobType" = 'Starters'),-1) END jr04strt, --****COALESCE**** -- 151
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 22 AND "JobType" = 'Leavers'),-1) END jr04stop, --****COALESCE**** -- 152
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 22 AND "JobType" = 'Vacancies'),-1) END jr04vacy, --****COALESCE**** -- 153
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 28 AND "JobType" = 'Starters'),-1) END jr05strt, --****COALESCE**** -- 162
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 28 AND "JobType" = 'Leavers'),-1) END jr05stop, --****COALESCE**** -- 163
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 28 AND "JobType" = 'Vacancies'),-1) END jr05vacy, --****COALESCE**** -- 164
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 27 AND "JobType" = 'Starters'),-1) END jr06strt, --****COALESCE**** -- 173
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 27 AND "JobType" = 'Leavers'),-1) END jr06stop, --****COALESCE**** -- 174
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 27 AND "JobType" = 'Vacancies'),-1) END jr06vacy, --****COALESCE**** -- 175
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 25 AND "JobType" = 'Starters'),-1) END jr07strt, --****COALESCE**** -- 184
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 25 AND "JobType" = 'Leavers'),-1) END jr07stop, --****COALESCE**** -- 185
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 25 AND "JobType" = 'Vacancies'),-1) END jr07vacy, --****COALESCE**** -- 186
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 10 AND "JobType" = 'Starters'),-1) END jr08strt, --****COALESCE**** -- 195
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 10 AND "JobType" = 'Leavers'),-1) END jr08stop, --****COALESCE**** -- 196
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 10 AND "JobType" = 'Vacancies'),-1) END jr08vacy, --****COALESCE**** -- 197
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 11 AND "JobType" = 'Starters'),-1) END jr09strt, --****COALESCE**** -- 206
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 11 AND "JobType" = 'Leavers'),-1) END jr09stop, --****COALESCE**** -- 207
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 11 AND "JobType" = 'Vacancies'),-1) END jr09vacy, --****COALESCE**** -- 208
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 12 AND "JobType" = 'Starters'),-1) END jr10strt, --****COALESCE**** -- 217
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 12 AND "JobType" = 'Leavers'),-1) END jr10stop, --****COALESCE**** -- 218
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 12 AND "JobType" = 'Vacancies'),-1) END jr10vacy, --****COALESCE**** -- 219
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 3 AND "JobType" = 'Starters'),-1) END jr11strt, --****COALESCE**** -- 228
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 3 AND "JobType" = 'Leavers'),-1) END jr11stop, --****COALESCE**** -- 229
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 3 AND "JobType" = 'Vacancies'),-1) END jr11vacy, --****COALESCE**** -- 230
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 18 AND "JobType" = 'Starters'),-1) END jr15strt, --****COALESCE**** -- 239
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 18 AND "JobType" = 'Leavers'),-1) END jr15stop, --****COALESCE**** -- 240
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 18 AND "JobType" = 'Vacancies'),-1) END jr15vacy, --****COALESCE**** -- 241
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 23 AND "JobType" = 'Starters'),-1) END jr16strt, --****COALESCE**** -- 250
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 23 AND "JobType" = 'Leavers'),-1) END jr16stop, --****COALESCE**** -- 251
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 23 AND "JobType" = 'Vacancies'),-1) END jr16vacy, --****COALESCE**** -- 252
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 4 AND "JobType" = 'Starters'),-1) END jr17strt, --****COALESCE**** -- 261
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 4 AND "JobType" = 'Leavers'),-1) END jr17stop, --****COALESCE**** -- 262
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 4 AND "JobType" = 'Vacancies'),-1) END jr17vacy, --****COALESCE**** -- 263
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 29 AND "JobType" = 'Starters'),-1) END jr22strt, --****COALESCE**** -- 272
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 29 AND "JobType" = 'Leavers'),-1) END jr22stop, --****COALESCE**** -- 273
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 29 AND "JobType" = 'Vacancies'),-1) END jr22vacy, --****COALESCE**** -- 274
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 20 AND "JobType" = 'Starters'),-1) END jr23strt, --****COALESCE**** -- 283
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 20 AND "JobType" = 'Leavers'),-1) END jr23stop, --****COALESCE**** -- 284
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 20 AND "JobType" = 'Vacancies'),-1) END jr23vacy, --****COALESCE**** -- 285
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 14 AND "JobType" = 'Starters'),-1) END jr24strt, --****COALESCE**** -- 294
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 14 AND "JobType" = 'Leavers'),-1) END jr24stop, --****COALESCE**** -- 295
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 14 AND "JobType" = 'Vacancies'),-1) END jr24vacy, --****COALESCE**** -- 296
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 2 AND "JobType" = 'Starters'),-1) END jr25strt, --****COALESCE**** -- 305
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 2 AND "JobType" = 'Leavers'),-1) END jr25stop, --****COALESCE**** -- 306
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 2 AND "JobType" = 'Vacancies'),-1) END jr25vacy, --****COALESCE**** -- 307
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 5 AND "JobType" = 'Starters'),-1) END jr26strt, --****COALESCE**** -- 316
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 5 AND "JobType" = 'Leavers'),-1) END jr26stop, --****COALESCE**** -- 317
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 5 AND "JobType" = 'Vacancies'),-1) END jr26vacy, --****COALESCE**** -- 318
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 21 AND "JobType" = 'Starters'),-1) END jr27strt, --****COALESCE**** -- 327
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 21 AND "JobType" = 'Leavers'),-1) END jr27stop, --****COALESCE**** -- 328
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 21 AND "JobType" = 'Vacancies'),-1) END jr27vacy, --****COALESCE**** -- 329
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 1 AND "JobType" = 'Starters'),-1) END jr34strt, --****COALESCE**** -- 338
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 1 AND "JobType" = 'Leavers'),-1) END jr34stop, --****COALESCE**** -- 339
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 1 AND "JobType" = 'Vacancies'),-1) END jr34vacy, --****COALESCE**** -- 340
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 24 AND "JobType" = 'Starters'),-1) END jr35strt, --****COALESCE**** -- 349
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 24 AND "JobType" = 'Leavers'),-1) END jr35stop, --****COALESCE**** -- 350
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 24 AND "JobType" = 'Vacancies'),-1) END jr35vacy, --****COALESCE**** -- 351
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 19 AND "JobType" = 'Starters'),-1) END jr36strt, --****COALESCE**** -- 360
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 19 AND "JobType" = 'Leavers'),-1) END jr36stop, --****COALESCE**** -- 361
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 19 AND "JobType" = 'Vacancies'),-1) END jr36vacy, --****COALESCE**** -- 362
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 17 AND "JobType" = 'Starters'),-1) END jr37strt, --****COALESCE**** -- 371
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 17 AND "JobType" = 'Leavers'),-1) END jr37stop, --****COALESCE**** -- 372
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 17 AND "JobType" = 'Vacancies'),-1) END jr37vacy, --****COALESCE**** -- 373
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 16 AND "JobType" = 'Starters'),-1) END jr38strt, --****COALESCE**** -- 382
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 16 AND "JobType" = 'Leavers'),-1) END jr38stop, --****COALESCE**** -- 383
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 16 AND "JobType" = 'Vacancies'),-1) END jr38vacy, --****COALESCE**** -- 384
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 7 AND "JobType" = 'Starters'),-1) END jr39strt, --****COALESCE**** -- 393
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 7 AND "JobType" = 'Leavers'),-1) END jr39stop, --****COALESCE**** -- 394
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 7 AND "JobType" = 'Vacancies'),-1) END jr39vacy, --****COALESCE**** -- 395
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 8 AND "JobType" = 'Starters'),-1) END jr40strt, --****COALESCE**** -- 404
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 8 AND "JobType" = 'Leavers'),-1) END jr40stop, --****COALESCE**** -- 405
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 8 AND "JobType" = 'Vacancies'),-1) END jr40vacy, --****COALESCE**** -- 406
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 9 AND "JobType" = 'Starters'),-1) END jr41strt, --****COALESCE**** -- 415
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 9 AND "JobType" = 'Leavers'),-1) END jr41stop, --****COALESCE**** -- 416
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 9 AND "JobType" = 'Vacancies'),-1) END jr41vacy, --****COALESCE**** -- 417
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 6 AND "JobType" = 'Starters'),-1) END jr42strt, --****COALESCE**** -- 426
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 6 AND "JobType" = 'Leavers'),-1) END jr42stop, --****COALESCE**** -- 427
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 6 AND "JobType" = 'Vacancies'),-1) END jr42vacy, --****COALESCE**** -- 428
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 24 AND sc."Type" = 'Capacity'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st01cap, --****COALESCE**** -- 457
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 24 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st01util, --****COALESCE**** -- 460
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 25 AND sc."Type" = 'Capacity'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st02cap, --****COALESCE**** -- 464
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 25 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st02util, --****COALESCE**** -- 467
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 13 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st53util, --****COALESCE**** -- 471
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 12 AND sc."Type" = 'Capacity'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st05cap, --****COALESCE**** -- 475
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 12 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st05util, --****COALESCE**** -- 478
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 9 AND sc."Type" = 'Capacity'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st06cap, --****COALESCE**** -- 482
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 9 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st06util, --****COALESCE**** -- 485
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 10 AND sc."Type" = 'Capacity'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st07cap, --****COALESCE**** -- 489
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 10 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st07util, --****COALESCE**** -- 492
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 11 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st10util, --****COALESCE**** -- 496
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 20 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st08util, --****COALESCE**** -- 500
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 21 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st54util, --****COALESCE**** -- 504
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 22 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st74util, --****COALESCE**** -- 508
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 23 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st55util, --****COALESCE**** -- 512
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 35 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st73util, --****COALESCE**** -- 516
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 18 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st12util, --****COALESCE**** -- 520
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 19 AND sc."Type" = 'Capacity'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st17cap, --****COALESCE**** -- 529
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 19 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st17util --****COALESCE**** -- 532
FROM   
   "Establishment" e 
JOIN 
   "Afr1BatchiSkAi0mo" b ON e."EstablishmentID" = b."EstablishmentID" AND b."BatchNo" = 1;
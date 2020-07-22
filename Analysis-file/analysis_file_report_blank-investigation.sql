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
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Starters'),-1) jr28strt, --****COALESCE**** -- 064
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Leavers'),-1) jr28stop, --****COALESCE**** -- 064a
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Vacancies'),-1) jr28vacy, --****COALESCE**** -- 065
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (25,10,11,12,3,29,20,16) AND "JobType" = 'Starters'),-1) jr29strt, --****COALESCE**** -- 074
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (25,10,11,12,3,29,20,16) AND "JobType" = 'Leavers'),-1) jr29stop, --****COALESCE**** -- 075
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (25,10,11,12,3,29,20,16) AND "JobType" = 'Vacancies'),-1) jr29vacy, --****COALESCE**** -- 076
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (26,15,13,22,28,14) AND "JobType" = 'Starters'),-1) jr30strt, --****COALESCE**** -- 085
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (26,15,13,22,28,14) AND "JobType" = 'Leavers'),-1) jr30stop, --****COALESCE**** -- 086
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (26,15,13,22,28,14) AND "JobType" = 'Vacancies'),-1) jr30vacy, --****COALESCE**** -- 087
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (27,18,23,4,24,17) AND "JobType" = 'Starters'),-1) jr31strt, --****COALESCE**** -- 096
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (27,18,23,4,24,17) AND "JobType" = 'Leavers'),-1) jr31stop, --****COALESCE**** -- 097
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (27,18,23,4,24,17) AND "JobType" = 'Vacancies'),-1) jr31vacy, --****COALESCE**** -- 098
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (2,5,21,1,19,7,8,9,6) AND "JobType" = 'Starters'),-1) jr32strt, --****COALESCE**** -- 107
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (2,5,21,1,19,7,8,9,6) AND "JobType" = 'Leavers'),-1) jr32stop, --****COALESCE**** -- 108
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (2,5,21,1,19,7,8,9,6) AND "JobType" = 'Vacancies'),-1) jr32vacy, --****COALESCE**** -- 109
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 26 AND "JobType" = 'Starters'),-1) jr01strt, --****COALESCE**** -- 118
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 26 AND "JobType" = 'Leavers'),-1) jr01stop, --****COALESCE**** -- 119
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 26 AND "JobType" = 'Vacancies'),-1) jr01vacy, --****COALESCE**** -- 120
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 15 AND "JobType" = 'Starters'),-1) jr02strt, --****COALESCE**** -- 129
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 15 AND "JobType" = 'Leavers'),-1) jr02stop, --****COALESCE**** -- 130
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 15 AND "JobType" = 'Vacancies'),-1) jr02vacy, --****COALESCE**** -- 131
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 13 AND "JobType" = 'Starters'),-1) jr03strt, --****COALESCE**** -- 140
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 13 AND "JobType" = 'Leavers'),-1) jr03stop, --****COALESCE**** -- 141
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 13 AND "JobType" = 'Vacancies'),-1) jr03vacy, --****COALESCE**** -- 142
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 22 AND "JobType" = 'Starters'),-1) jr04strt, --****COALESCE**** -- 151
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 22 AND "JobType" = 'Leavers'),-1) jr04stop, --****COALESCE**** -- 152
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 22 AND "JobType" = 'Vacancies'),-1) jr04vacy, --****COALESCE**** -- 153
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 28 AND "JobType" = 'Starters'),-1) jr05strt, --****COALESCE**** -- 162
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 28 AND "JobType" = 'Leavers'),-1) jr05stop, --****COALESCE**** -- 163
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 28 AND "JobType" = 'Vacancies'),-1) jr05vacy, --****COALESCE**** -- 164
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 27 AND "JobType" = 'Starters'),-1) jr06strt, --****COALESCE**** -- 173
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 27 AND "JobType" = 'Leavers'),-1) jr06stop, --****COALESCE**** -- 174
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 27 AND "JobType" = 'Vacancies'),-1) jr06vacy, --****COALESCE**** -- 175
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 25 AND "JobType" = 'Starters'),-1) jr07strt, --****COALESCE**** -- 184
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 25 AND "JobType" = 'Leavers'),-1) jr07stop, --****COALESCE**** -- 185
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 25 AND "JobType" = 'Vacancies'),-1) jr07vacy, --****COALESCE**** -- 186
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 10 AND "JobType" = 'Starters'),-1) jr08strt, --****COALESCE**** -- 195
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 10 AND "JobType" = 'Leavers'),-1) jr08stop, --****COALESCE**** -- 196
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 10 AND "JobType" = 'Vacancies'),-1) jr08vacy, --****COALESCE**** -- 197
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 11 AND "JobType" = 'Starters'),-1) jr09strt, --****COALESCE**** -- 206
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 11 AND "JobType" = 'Leavers'),-1) jr09stop, --****COALESCE**** -- 207
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 11 AND "JobType" = 'Vacancies'),-1) jr09vacy, --****COALESCE**** -- 208
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 12 AND "JobType" = 'Starters'),-1) jr10strt, --****COALESCE**** -- 217
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 12 AND "JobType" = 'Leavers'),-1) jr10stop, --****COALESCE**** -- 218
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 12 AND "JobType" = 'Vacancies'),-1) jr10vacy, --****COALESCE**** -- 219
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 3 AND "JobType" = 'Starters'),-1) jr11strt, --****COALESCE**** -- 228
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 3 AND "JobType" = 'Leavers'),-1) jr11stop, --****COALESCE**** -- 229
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 3 AND "JobType" = 'Vacancies'),-1) jr11vacy, --****COALESCE**** -- 230
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 18 AND "JobType" = 'Starters'),-1) jr15strt, --****COALESCE**** -- 239
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 18 AND "JobType" = 'Leavers'),-1) jr15stop, --****COALESCE**** -- 240
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 18 AND "JobType" = 'Vacancies'),-1) jr15vacy, --****COALESCE**** -- 241
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 23 AND "JobType" = 'Starters'),-1) jr16strt, --****COALESCE**** -- 250
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 23 AND "JobType" = 'Leavers'),-1) jr16stop, --****COALESCE**** -- 251
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 23 AND "JobType" = 'Vacancies'),-1) jr16vacy, --****COALESCE**** -- 252
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 4 AND "JobType" = 'Starters'),-1) jr17strt, --****COALESCE**** -- 261
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 4 AND "JobType" = 'Leavers'),-1) jr17stop, --****COALESCE**** -- 262
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 4 AND "JobType" = 'Vacancies'),-1) jr17vacy, --****COALESCE**** -- 263
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 29 AND "JobType" = 'Starters'),-1) jr22strt, --****COALESCE**** -- 272
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 29 AND "JobType" = 'Leavers'),-1) jr22stop, --****COALESCE**** -- 273
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 29 AND "JobType" = 'Vacancies'),-1) jr22vacy, --****COALESCE**** -- 274
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 20 AND "JobType" = 'Starters'),-1) jr23strt, --****COALESCE**** -- 283
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 20 AND "JobType" = 'Leavers'),-1) jr23stop, --****COALESCE**** -- 284
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 20 AND "JobType" = 'Vacancies'),-1) jr23vacy, --****COALESCE**** -- 285
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 14 AND "JobType" = 'Starters'),-1) jr24strt, --****COALESCE**** -- 294
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 14 AND "JobType" = 'Leavers'),-1) jr24stop, --****COALESCE**** -- 295
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 14 AND "JobType" = 'Vacancies'),-1) jr24vacy, --****COALESCE**** -- 296
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 2 AND "JobType" = 'Starters'),-1) jr25strt, --****COALESCE**** -- 305
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 2 AND "JobType" = 'Leavers'),-1) jr25stop, --****COALESCE**** -- 306
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 2 AND "JobType" = 'Vacancies'),-1) jr25vacy, --****COALESCE**** -- 307
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 5 AND "JobType" = 'Starters'),-1) jr26strt, --****COALESCE**** -- 316
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 5 AND "JobType" = 'Leavers'),-1) jr26stop, --****COALESCE**** -- 317
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 5 AND "JobType" = 'Vacancies'),-1) jr26vacy, --****COALESCE**** -- 318
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 21 AND "JobType" = 'Starters'),-1) jr27strt, --****COALESCE**** -- 327
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 21 AND "JobType" = 'Leavers'),-1) jr27stop, --****COALESCE**** -- 328
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 21 AND "JobType" = 'Vacancies'),-1) jr27vacy, --****COALESCE**** -- 329
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 1 AND "JobType" = 'Starters'),-1) jr34strt, --****COALESCE**** -- 338
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 1 AND "JobType" = 'Leavers'),-1) jr34stop, --****COALESCE**** -- 339
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 1 AND "JobType" = 'Vacancies'),-1) jr34vacy, --****COALESCE**** -- 340
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 24 AND "JobType" = 'Starters'),-1) jr35strt, --****COALESCE**** -- 349
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 24 AND "JobType" = 'Leavers'),-1) jr35stop, --****COALESCE**** -- 350
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 24 AND "JobType" = 'Vacancies'),-1) jr35vacy, --****COALESCE**** -- 351
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 19 AND "JobType" = 'Starters'),-1) jr36strt, --****COALESCE**** -- 360
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 19 AND "JobType" = 'Leavers'),-1) jr36stop, --****COALESCE**** -- 361
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 19 AND "JobType" = 'Vacancies'),-1) jr36vacy, --****COALESCE**** -- 362
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 17 AND "JobType" = 'Starters'),-1) jr37strt, --****COALESCE**** -- 371
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 17 AND "JobType" = 'Leavers'),-1) jr37stop, --****COALESCE**** -- 372
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 17 AND "JobType" = 'Vacancies'),-1) jr37vacy, --****COALESCE**** -- 373
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 16 AND "JobType" = 'Starters'),-1) jr38strt, --****COALESCE**** -- 382
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 16 AND "JobType" = 'Leavers'),-1) jr38stop, --****COALESCE**** -- 383
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 16 AND "JobType" = 'Vacancies'),-1) jr38vacy, --****COALESCE**** -- 384
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 7 AND "JobType" = 'Starters'),-1) jr39strt, --****COALESCE**** -- 393
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 7 AND "JobType" = 'Leavers'),-1) jr39stop, --****COALESCE**** -- 394
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 7 AND "JobType" = 'Vacancies'),-1) jr39vacy, --****COALESCE**** -- 395
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 8 AND "JobType" = 'Starters'),-1) jr40strt, --****COALESCE**** -- 404
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 8 AND "JobType" = 'Leavers'),-1) jr40stop, --****COALESCE**** -- 405
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 8 AND "JobType" = 'Vacancies'),-1) jr40vacy, --****COALESCE**** -- 406
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 9 AND "JobType" = 'Starters'),-1) jr41strt, --****COALESCE**** -- 415
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 9 AND "JobType" = 'Leavers'),-1) jr41stop, --****COALESCE**** -- 416
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 9 AND "JobType" = 'Vacancies'),-1) jr41vacy, --****COALESCE**** -- 417
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 6 AND "JobType" = 'Starters'),-1) jr42strt, --****COALESCE**** -- 426
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 6 AND "JobType" = 'Leavers'),-1) jr42stop, --****COALESCE**** -- 427
       COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 6 AND "JobType" = 'Vacancies'),-1) jr42vacy, --****COALESCE**** -- 428
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
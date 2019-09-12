
-- Cohort3 scripts to change standing migration helper data

update migration.services set sfcid=18 where tribalid=12 and sfcid=15;

insert into migration.ethnicity(tribalid,sfcid) values(98,19);


update migration.services set sfcid=11 where tribalid=9 and sfcid=15;
update migration.services set sfcid=18 where tribalid=11 and sfcid=15;
update migration.services set sfcid=14 where tribalid=23 and sfcid=15;
update migration.services set sfcid=14 where tribalid=40 and sfcid=28;
update migration.services set sfcid=17 where tribalid=50 and sfcid=15;
update migration.services set sfcid=14 where tribalid=57 and sfcid=15;
update migration.services set sfcid=17 where tribalid=65 and sfcid=15;

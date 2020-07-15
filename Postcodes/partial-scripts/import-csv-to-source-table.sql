BEGIN TRANSACTION;
----------------
--TRUNCATE cqcref."pcodedata-source";


--FROM 'C:/skills-for-care/postcodes/dummy-postcodes.csv' -- 2002 rows
--FROM 'C:/skills-for-care/postcodes/dummy-postcodes-bigger.csv' -- 10000 rows
--FROM 'C:/skills-for-care/postcodes/AddressBasePlus_COU_2020-03-19_002.csv' -- 258152 rows
--FROM 'C:/skills-for-care/postcodes/AddressBasePlus_COU_2020-03-19_001.csv' -- 1,000,000 rows

-- original COPY command 
COPY cqcref."pcodedata-source" FROM 'C:/skills-for-care/postcodes/AddressBasePlus_COU_2020-03-19_001.csv' WITH (FORMAT csv);
COPY cqcref."pcodedata-source" FROM 'C:/skills-for-care/postcodes/AddressBasePlus_COU_2020-03-19_002.csv' WITH (FORMAT csv);

-- changed to \copy because of permissions errors in preprod
\copy cqcref."pcodedata-source-2" FROM 'C:/skills-for-care/postcodes/AddressBasePlus_COU_2020-03-19_001.csv' WITH (FORMAT csv);
\copy cqcref."pcodedata-source-2" FROM 'C:/skills-for-care/postcodes/AddressBasePlus_COU_2020-03-19_002.csv' WITH (FORMAT csv);

/*
Dummy test with 2002 rows:
COPY 2002
Query returned successfully in 100 msec.
---------
Dummy test-bigger with 10000 rows:
COPY 10000
Query returned successfully in 212 msec.
--------
'C:/skills-for-care/postcodes/AddressBasePlus_COU_2020-03-19_002.csv' -- 258,152 rows
COPY 258152
Query returned successfully in 5 secs 537 msec.
--------
'C:/skills-for-care/postcodes/AddressBasePlus_COU_2020-03-19_001.csv' -- 1,000,000 rows
COPY 1000000
Query returned successfully in 22 secs 298 msec.
*/
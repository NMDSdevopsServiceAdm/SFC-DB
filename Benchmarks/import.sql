BEGIN TRANSACTION;

-------------------
-- Turn timing on so we can see how long it took
-------------------
\timing

-------------------
-- Create a temp table, "benchmarks-source", to hold the new postcode data from the csv
-------------------
SELECT 'Creating temp source table';

DROP TABLE IF EXISTS cqc."Benchmarks";

CREATE TABLE cqc."Benchmarks"
(
    "CssrID" integer NOT NULL,
    "MainServiceFK" integer NOT NULL,
    "Pay" integer,
    "Sickness" integer,
    "Turnover" numeric(5,2),
    "Qualifications" numeric(3,2),
    "Workplaces" integer NOT NULL,
    "Staff" integer NOT NULL,
    CONSTRAINT "Benchmarks_pkey" PRIMARY KEY ("CssrID", "MainServiceFK"),
    CONSTRAINT "Benchmarks_MainServiceFK_fkey1" FOREIGN KEY ("MainServiceFK")
        REFERENCES cqc.services ("reportingID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
-- if local -- 
-- ALTER TABLE cqc."Benchmarks"
--     OWNER to sfcadmin;

-------------------
-- Import the new benchmark data from the csvs into your temp table
-- !! Edit the path to the csvs !!
-------------------
SELECT 'Importing new benchmark data from the csvs into temp source table';
TRUNCATE cqc."Benchmarks";
\copy cqc."Benchmarks" FROM '/mnt/c/Users/arussell/Downloads/benchmark-data2.csv' WITH (FORMAT csv, ENCODING 'UTF8');
-------------------
-- Check new data successfully updated
-------------------
SELECT 
  COUNT(0)
FROM 
  cqc."Benchmarks";

----------------
END TRANSACTION;
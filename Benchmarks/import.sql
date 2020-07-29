BEGIN TRANSACTION;

-------------------
-- Turn timing on so we can see how long it took
-------------------
\timing

-------------------
-- Create a temp table, "benchmarks-source", to hold the new postcode data from the csv
-------------------
SELECT 'Creating temp source table';

DROP TABLE IF EXISTS cqc."Benchmarks_new";

CREATE TABLE cqc."Benchmarks_new"
(
    "CssrIDFK" integer NOT NULL,
    "MainServiceFK" integer NOT NULL,
    "Pay" integer,
    "Sickness" integer,
    "Turnover" numeric(3,2),
    "Qualifications" numeric(3,2),
    "Workplaces" integer NOT NULL,
    "Staff" integer NOT NULL,
    CONSTRAINT "Benchmarks_MainServiceFK_fkey" FOREIGN KEY ("MainServiceFK")
        REFERENCES cqc.services ("reportingID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);

ALTER TABLE cqc."Benchmarks_new"
    OWNER to sfcadmin;

-------------------
-- Import the new benchmark data from the csvs into your temp table
-- !! Edit the path to the csvs !!
-------------------
SELECT 'Importing new benchmark data from the csvs into temp source table';
TRUNCATE cqc."Benchmarks_new";
\copy cqc."Benchmarks_new" FROM 'C:\Users\arussell\Downloads\File_format_for_comparisons.csv' WITH (FORMAT csv);
-------------------
-- Check new data successfully updated
-------------------
SELECT 
  COUNT(0)
FROM 
  cqc."Benchmarks_new";

DROP TABLE IF EXISTS cqc."Benchmarks-backup";
ALTER TABLE cqc."Benchmarks" RENAME TO "Benchmarks-backup";
----------------
ALTER TABLE cqc."Benchmarks_new" RENAME TO "Benchmarks";

----------------
END TRANSACTION;
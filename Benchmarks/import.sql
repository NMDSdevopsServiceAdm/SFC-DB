BEGIN TRANSACTION;

-------------------
-- Turn timing on so we can see how long it took
-------------------
\timing

-------------------
-- Create a temp table, "benchmarks-source", to hold the new postcode data from the csv
-------------------
SELECT 'Creating temp source table';

-------------------
-- Import the new benchmark data from the csvs into your temp table
-- !! Edit the path to the csvs !!
-------------------
SELECT 'Importing new benchmark data from the csvs into temp source table';
TRUNCATE cqc."Benchmarks", cqc."BenchmarksPay", cqc."BenchmarksTurnover", cqc."BenchmarksQualifications", cqc."BenchmarksSickness";
\copy cqc."Benchmarks" FROM '/mnt/c/Users/arussell/Downloads/benchmarks-aug2020.csv' WITH (FORMAT csv, ENCODING 'UTF8', HEADER);
\copy cqc."BenchmarksPay" FROM '/mnt/c/Users/arussell/Downloads/benchmarksPay.csv' WITH (FORMAT csv, ENCODING 'UTF8', HEADER);
\copy cqc."BenchmarksTurnover" FROM '/mnt/c/Users/arussell/Downloads/benchmarksTurnover.csv' WITH (FORMAT csv, ENCODING 'UTF8', HEADER);
\copy cqc."BenchmarksQualifications" FROM '/mnt/c/Users/arussell/Downloads/benchmarksQualifications.csv' WITH (FORMAT csv, ENCODING 'UTF8', HEADER);
\copy cqc."BenchmarksSickness" FROM '/mnt/c/Users/arussell/Downloads/benchmarksSickness.csv' WITH (FORMAT csv, ENCODING 'UTF8', HEADER);

INSERT INTO cqc."DataImports" ("Type", "Date") VALUES ('Benchmarks', current_timestamp);
-------------------
-- Check new data successfully updated
-------------------
SELECT 
  COUNT(0)
FROM 
  cqc."Benchmarks";

  SELECT 
  COUNT(0)
FROM 
  cqc."BenchmarksPay";
  
  SELECT 
  COUNT(0)
FROM 
  cqc."BenchmarksTurnover";

  SELECT 
  COUNT(0)
FROM 
  cqc."BenchmarksQualifications";

  SELECT 
  COUNT(0)
FROM 
  cqc."BenchmarksSickness";

----------------
END TRANSACTION;
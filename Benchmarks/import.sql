BEGIN TRANSACTION;

-------------------
-- Turn timing on so we can see how long it took
-------------------
\timing

TRUNCATE cqc."Benchmarks", cqc."BenchmarksPay", cqc."BenchmarksTurnover", cqc."BenchmarksQualifications", cqc."BenchmarksSickness";

\copy cqc."Benchmarks" FROM '/efs/benchmarks/Benchmarks.csv' WITH (FORMAT csv, ENCODING 'UTF8', HEADER);
\copy cqc."BenchmarksPay" ("CssrID", "MainServiceFK", "EstablishmentFK", "Pay") FROM '/efs/benchmarks/BenchmarksPay.csv' WITH (FORMAT csv, ENCODING 'UTF8', HEADER);
\copy cqc."BenchmarksTurnover" ("CssrID", "MainServiceFK", "EstablishmentFK", "Turnover") FROM '/efs/benchmarks/BenchmarksTurnover.csv' WITH (FORMAT csv, ENCODING 'UTF8', HEADER);
\copy cqc."BenchmarksQualifications" ("CssrID", "MainServiceFK", "EstablishmentFK", "Qualifications") FROM '/efs/benchmarks/BenchmarksQuals.csv' WITH (FORMAT csv, ENCODING 'UTF8', HEADER);
\copy cqc."BenchmarksSickness" ("CssrID", "MainServiceFK", "EstablishmentFK", "Sickness") FROM '/efs/benchmarks/BenchmarksSickness.csv' WITH (FORMAT csv, ENCODING 'UTF8', HEADER);

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

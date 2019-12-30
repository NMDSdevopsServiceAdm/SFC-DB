SET SEARCH_PATH TO cqc;
BEGIN TRANSACTION;

CREATE TYPE "TrainingReportStates" AS ENUM
    ('READY', 'DOWNLOADING', 'FAILED', 'WARNINGS', 'COMPLETING');

ALTER TABLE "Establishment"
    ADD COLUMN "TrainingReportLockHeld" boolean NOT NULL DEFAULT false;

ALTER TABLE "Establishment"
    ADD COLUMN "TrainingReportState" "TrainingReportStates" NOT NULL DEFAULT 'READY'::"TrainingReportStates";

SELECT t.table_schema, t.table_name, c.column_name
FROM information_schema.tables t
JOIN information_schema.columns c ON c.table_name = t.table_name AND c.table_schema = t.table_schema
WHERE t.table_schema = 'cqc'
AND t.table_name = 'Establishment'
AND c.column_name = 'TrainingReportState'
ORDER BY 1,2,3;

SELECT n.nspname as enum_schema,
t.typname as enum_name,
e.enumtypid,
STRING_AGG(e.enumsortorder || ') ' || e.enumlabel,' ' ORDER BY e.enumsortorder) enumsortorder_enumlabel
FROM pg_type t
JOIN pg_enum e ON t.oid = e.enumtypid
JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
WHERE n.nspname = 'cqc'
AND t.typname = 'TrainingReportStates'
GROUP BY 1,2,3
ORDER BY 1,2,3;

END TRANSACTION;

\a \t
SELECT '';
SELECT CASE SUBSTRING(CURRENT_DATABASE(),1,3)
          WHEN 'sfc' THEN
             'ALTER TYPE "TrainingReportStates" OWNER TO sfcadmin;'
          ELSE NULL
       END;
SELECT '';
\t \a
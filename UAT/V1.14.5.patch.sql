BEGIN TRANSACTION;

CREATE TYPE cqc."TrainingReportStates" AS ENUM
    ('READY', 'DOWNLOADING', 'FAILED', 'WARNINGS', 'COMPLETING');

ALTER TABLE cqc."Establishment"
    ADD COLUMN "TrainingReportLockHeld" boolean NOT NULL DEFAULT false;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "TrainingReportState" cqc."TrainingReportStates" NOT NULL DEFAULT 'READY'::cqc."TrainingReportStates";

END TRANSACTION;

\a \t
SELECT '';
SELECT CASE SUBSTRING(CURRENT_DATABASE(),1,3)
          WHEN 'sfc' THEN
             'ALTER TYPE cqc."TrainingReportStates" OWNER TO sfcadmin;'
          ELSE NULL
       END;
SELECT '';
\t \a
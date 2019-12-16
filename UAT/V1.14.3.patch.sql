BEGIN TRANSACTION;

CREATE TYPE cqc."wdfReportStates" AS ENUM
    ('READY', 'DOWNLOADING', 'FAILED', 'WARNINGS', 'COMPLETING');

ALTER TABLE cqc."Establishment"
    ADD COLUMN "WDFReportLockHeld" boolean NOT NULL DEFAULT false;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "WDFReportState" cqc."WDFReportStates" NOT NULL DEFAULT 'READY'::cqc."WDFReportStates";

END TRANSACTION;

\a \t
SELECT '';
SELECT CASE SUBSTRING(CURRENT_DATABASE(),1,3)
          WHEN 'sfc' THEN
             'ALTER TYPE cqc."WDFReportStates" OWNER TO sfcadmin;'
          ELSE NULL
       END;
SELECT '';
\t \a
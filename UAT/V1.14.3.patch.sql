BEGIN TRANSACTION;

CREATE TYPE cqc."WdfReportStates" AS ENUM
    ('READY', 'DOWNLOADING', 'FAILED', 'WARNINGS', 'COMPLETING');

ALTER TABLE cqc."Establishment"
    ADD COLUMN "WdfReportLockHeld" boolean NOT NULL DEFAULT false;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "WdfReportState" cqc."WdfReportStates" NOT NULL DEFAULT 'READY'::cqc."WdfReportStates";

END TRANSACTION;

\a \t
SELECT '';
SELECT CASE SUBSTRING(CURRENT_DATABASE(),1,3)
          WHEN 'sfc' THEN
             'ALTER TYPE cqc."WdfReportStates" OWNER TO sfcadmin;'
          ELSE NULL
       END;
SELECT '';
\t \a
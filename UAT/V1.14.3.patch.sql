BEGIN TRANSACTION;

CREATE TYPE cqc."wdfReportStates" AS ENUM
    ('READY', 'DOWNLOADING', 'FAILED', 'WARNINGS', 'COMPLETING');

ALTER TABLE cqc."Establishment"
    ADD COLUMN "wdfReportLockHeld" boolean NOT NULL DEFAULT false;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "wdfReportState" cqc."wdfReportStates" NOT NULL DEFAULT 'READY'::cqc."wdfReportStates";

END TRANSACTION;

\a \t
SELECT '';
SELECT CASE SUBSTRING(CURRENT_DATABASE(),1,3)
          WHEN 'sfc' THEN
             'ALTER TYPE cqc."wdfReportStates" OWNER TO sfcadmin;'
          ELSE NULL
       END;
SELECT '';
\t \a
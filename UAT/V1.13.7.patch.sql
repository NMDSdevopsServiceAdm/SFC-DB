BEGIN TRANSACTION;

CREATE TYPE cqc."bulkUploadStates" AS ENUM
    ('READY', 'DOWNLOADING', 'UPLOADING', 'UPLOADED', 'VALIDATING', 'FAILED', 'WARNINGS', 'PASSED', 'COMPLETING');

ALTER TABLE cqc."Establishment"
    ADD COLUMN "bulkUploadLockHeld" boolean NOT NULL DEFAULT false;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "bulkUploadState" cqc."bulkUploadStates" NOT NULL DEFAULT 'READY'::cqc."bulkUploadStates";

END TRANSACTION;

\a \t
SELECT '';
SELECT CASE SUBSTRING(CURRENT_DATABASE(),1,3)
          WHEN 'sfc' THEN
             'ALTER TYPE cqc."bulkUploadStates" OWNER TO sfcadmin;'
          ELSE NULL
       END;
SELECT '';
\t \a

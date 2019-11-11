BEGIN TRANSACTION;

ALTER TABLE cqc."Establishment"
    ADD COLUMN "bulkUploadLockHeld" boolean NOT NULL DEFAULT false;

END TRANSACTION;
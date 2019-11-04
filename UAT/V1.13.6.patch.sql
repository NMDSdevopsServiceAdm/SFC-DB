BEGIN TRANSACTION;
-- Adding new column : CreatedByUserUID
ALTER TABLE cqc."Notifications" ADD COLUMN "createdByUserUID" UUID NOT NULL;
END TRANSACTION;
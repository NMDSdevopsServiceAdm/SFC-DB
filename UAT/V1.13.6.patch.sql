BEGIN TRANSACTION;
-- Adding new column : CreatedByUserUID
ALTER TABLE cqc."Notifications" ADD COLUMN "createdByUserUID" uuid;
END TRANSACTION;
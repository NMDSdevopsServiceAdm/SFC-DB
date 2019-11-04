BEGIN TRANSACTION;
-- Adding new column : CreatedByUserUID
ALTER TABLE cqc."Notifications" ADD COLUMN "CreatedByUserUID" uuid;
END TRANSACTION;
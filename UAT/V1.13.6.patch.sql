BEGIN TRANSACTION;
-- Adding new column : CreatedByUserUID
ALTER TABLE cqc."Notifications" ADD COLUMN "CreatedByUserUID" string NOT NULL;
END TRANSACTION;
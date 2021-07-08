----------------
-- Use this if there is a problem with new postcode data and you want to bring the old postcode data back.
----------------
BEGIN TRANSACTION;
----------------
ALTER TABLE cqcref."pcodedata" RENAME TO "pcodedata-backup2";
----------------
ALTER TABLE cqcref."pcodedata-backup" RENAME TO "pcodedata";
----------------
END TRANSACTION;
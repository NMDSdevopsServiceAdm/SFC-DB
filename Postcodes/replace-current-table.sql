----------------
-- Use this at the end of importing new postcode data, to swap the new table in and backup the old one.
----------------
BEGIN TRANSACTION;
----------------
ALTER TABLE cqcref."pcodedata" RENAME TO "pcodedata-backup";
----------------
ALTER TABLE cqcref."pcodedata_new" RENAME TO "pcodedata";
----------------
END TRANSACTION;
----------------
-- Use this if you used revert-current-table.sql but now you want to restore the new postcode data again.
----------------
BEGIN TRANSACTION;
----------------
ALTER TABLE cqcref."pcodedata" RENAME TO "pcodedata-backup";
----------------
ALTER TABLE cqcref."pcodedata-backup2" RENAME TO "pcodedata";
----------------
END TRANSACTION;
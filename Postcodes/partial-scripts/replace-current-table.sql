BEGIN TRANSACTION;
----------------
ALTER TABLE cqcref."pcodedata" RENAME TO "pcodedata-backup";
----------------
ALTER TABLE cqcref."pcodedata_new" RENAME TO "pcodedata";
----------------
END TRANSACTION;
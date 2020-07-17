BEGIN TRANSACTION;
----------------
ALTER TABLE cqcref."pcodedata" RENAME TO "pcodedata-backup2";
----------------
ALTER TABLE cqcref."pcodedata-backup" RENAME TO "pcodedata";
----------------
END TRANSACTION;
BEGIN TRANSACTION;
----------------
ALTER TABLE cqcref."pcodedata"
  RENAME TO cqcref."pcodedata-backup";
----------------
ALTER TABLE cqcref."pcodedata_new"
  RENAME TO cqcref."pcodedata";
----------------
END TRANSACTION;
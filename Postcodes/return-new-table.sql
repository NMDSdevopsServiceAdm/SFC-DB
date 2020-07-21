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

-- select "NameOrIdValue" from cqc."Worker" where "NameOrIdValue" like 'Aaron in%' limit 10;
-- select "postcode" from cqcref."pcodedata" limit 1;
-- select "postcode" from cqcref."pcodedata-backup" limit 1;
-- select "postcode" from cqcref."pcodedata-backup2" limit 1;
-- select "uprn", "postcode" from cqcref."pcodedata-backup" where "postcode" = 'NW9 4EW';
-- select "uprn", "postcode" from cqcref."pcodedata" where "postcode" = 'NW9 4EW';
--Added a primary key on the uprn column for the pcodedata table I restored from prod
--Started 15:42, ended some time before 15:47
BEGIN TRANSACTION;
----------------
ALTER TABLE cqcref."pcodedata_new"
  ADD CONSTRAINT pcodedata_uprn_pk 
    PRIMARY KEY (uprn);
----------------
END TRANSACTION;
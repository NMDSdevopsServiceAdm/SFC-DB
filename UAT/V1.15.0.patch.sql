-- https://trello.com/c/6xyj97Nf/28

SET SEARCH_PATH TO cqc;

START TRANSACTION;

ALTER TABLE "Worker" DROP CONSTRAINT "worker_LocalIdentifier_unq";

END TRANSACTION;

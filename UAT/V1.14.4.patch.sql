SET SEARCH_PATH TO cqc;
-- BEGIN TRANSACTION;

-- Adding new value to enumeration for the notification type

ALTER TYPE "NotificationType" ADD VALUE 'DELINKTOPARENT';

-- END TRANSACTION;
SET SEARCH_PATH TO cqc;
-- BEGIN TRANSACTION;

-- Adding new value to enumeration for the notification type

ALTER TYPE "NotificationType" ADD VALUE 'LINKTOPARENTREQUEST'; 
ALTER TYPE "NotificationType" ADD VALUE 'LINKTOPARENTAPPROVED'; 
ALTER TYPE "NotificationType" ADD VALUE 'LINKTOPARENTREJECTED'; 

-- END TRANSACTION;

-- https://trello.com/c/0ZyA1yib

BEGIN TRANSACTION;

-- Adding new value to enumeration for the notification type
ALTER TYPE cqc."NotificationType" ADD VALUE 'OWNERCHANGEAPPROVED'; 
ALTER TYPE cqc."NotificationType" ADD VALUE 'OWNERCHANGEREJECTED'; 

END TRANSACTION;
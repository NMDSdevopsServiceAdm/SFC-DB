--https://trello.com/c/74VGreZm - admin user role

-- run the following command manually!!!
-- ALTER TYPE cqc.user_role ADD VALUE 'Admin';

ALTER TABLE cqc."User" ALTER COLUMN "EstablishmentID" DROP NOT NULL;
ALTER TABLE cqc."User" DROP COLUMN "AdminUser";
ALTER TABLE cqc."Establishment" RENAME "ParentAccess" TO "DataPermissions";
ALTER TABLE cqc."Establishment" RENAME "Owner" TO "DataOwner";

CREATE TYPE cqc.establishment_data_access_permission AS ENUM (
    'Workplace and Staff',
    'Workplace',
    'None'
);

ALTER TABLE cqc."Establishment" ALTER COLUMN "DataPermissions" TYPE cqc.establishment_data_access_permission USING "DataPermissions"::text::cqc.establishment_data_access_permission;

ALTER TABLE cqc."Establishment" ALTER COLUMN "DataPermissions" SET DEFAULT 'None';

UPDATE cqc."Establishment" SET "DataPermissions" = 'None' WHERE "DataPermissions" IS NULL;








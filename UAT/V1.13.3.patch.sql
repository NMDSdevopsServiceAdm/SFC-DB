-- https://trello.com/c/BmEiIfud

DROP TYPE IF EXISTS cqc.owner_change_status;
CREATE TYPE cqc.owner_change_status AS ENUM (
  'REQUESTED',
  'APPROVED',
  'DENIED'
);

DROP TABLE IF EXISTS cqc."OwnerChangeRequest";
CREATE TABLE IF NOT EXISTS cqc."OwnerChangeRequest" (
  "ownerChangeRequestUID" UUID NOT NULL PRIMARY KEY,
  "subEstablishmentID" integer NOT NULL,
  "permissionRequest" cqc.establishment_data_access_permission,
  "approvalStatus" cqc.owner_change_status,
  "approvalReason" TEXT,
  "created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
  "createdByUserUID" UUID NOT NULL,
  "updated" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
  "updatedByUserUID" UUID NOT NULL,
  CONSTRAINT establishment_owner_change_request_fk FOREIGN KEY ("subEstablishmentID")
      REFERENCES cqc."Establishment" ("EstablishmentID") MATCH SIMPLE
      ON UPDATE NO ACTION
      ON DELETE NO ACTION,
  CONSTRAINT user_owner_change_request_created_by_fk FOREIGN KEY ("createdByUserUID")
      REFERENCES cqc."User" ("UserUID") MATCH SIMPLE
      ON UPDATE NO ACTION
      ON DELETE NO ACTION,
  CONSTRAINT user_owner_change_request_updated_by_fk FOREIGN KEY ("updatedByUserUID")
      REFERENCES cqc."User" ("UserUID") MATCH SIMPLE
      ON UPDATE NO ACTION
      ON DELETE NO ACTION
);

-- only run these on dev, staging and accessibility/demo databases
-- GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE cqc."OwnerChangeRequest" TO "Sfc_App_Role";
-- GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE cqc."OwnerChangeRequest" TO "Sfc_Admin_Role";
-- GRANT ALL ON TABLE cqc."OwnerChangeRequest" TO sfcadmin;
-- GRANT INSERT, SELECT, UPDATE ON TABLE cqc."OwnerChangeRequest" TO "Read_Update_Role";
-- GRANT SELECT ON TABLE cqc."OwnerChangeRequest" TO "Read_Only_Role";

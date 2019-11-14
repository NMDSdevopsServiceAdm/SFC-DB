BEGIN TRANSACTION;

DROP TABLE IF EXISTS cqc."ParentEstablishmentPermissions";

CREATE TABLE IF NOT EXISTS cqc."ParentEstablishmentPermissions" (
  "parentEstablishmentID" integer NOT NULL,
  "subEstablishmentID" integer NOT NULL,
  "permissionRequest" cqc.establishment_data_access_permission,
  "created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
  "createdByUserUID" UUID NOT NULL,
  "updated" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
  "updatedByUserUID" UUID NOT NULL,
  CONSTRAINT establishment_parent_establishment_fk FOREIGN KEY ("parentEstablishmentID")
      REFERENCES cqc."Establishment" ("EstablishmentID") MATCH SIMPLE
      ON UPDATE NO ACTION
      ON DELETE NO ACTION,
  CONSTRAINT establishment_sub_establishment_fk FOREIGN KEY ("subEstablishmentID")
      REFERENCES cqc."Establishment" ("EstablishmentID") MATCH SIMPLE
      ON UPDATE NO ACTION
      ON DELETE NO ACTION,
  CONSTRAINT establishment_permission_request_created_by_fk FOREIGN KEY ("createdByUserUID")
      REFERENCES cqc."User" ("UserUID") MATCH SIMPLE
      ON UPDATE NO ACTION
      ON DELETE NO ACTION,
  CONSTRAINT user_permission_request_updated_by_fk FOREIGN KEY ("updatedByUserUID")
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

END TRANSACTION;
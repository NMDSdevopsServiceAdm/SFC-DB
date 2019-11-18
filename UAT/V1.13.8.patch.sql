SET SEARCH_PATH TO cqc;
BEGIN TRANSACTION;

DROP TABLE IF EXISTS cqc."ParentEstablishmentPermissions";

CREATE TABLE IF NOT EXISTS cqc."ParentEstablishmentPermissions" (
  "ParentEstablishmentID" integer NOT NULL,
  "SubEstablishmentID" integer NOT NULL,
  "PermissionRequest" cqc.establishment_data_access_permission,
  "Created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
  "CreatedByUserUID" UUID NOT NULL,
  "Updated" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
  "UpdatedByUserUID" UUID NOT NULL,
  CONSTRAINT establishment_parent_establishment_fk FOREIGN KEY ("ParentEstablishmentID")
      REFERENCES "Establishment" ("EstablishmentID") MATCH SIMPLE
      ON UPDATE NO ACTION
      ON DELETE NO ACTION,
  CONSTRAINT establishment_sub_establishment_fk FOREIGN KEY ("SubEstablishmentID")
      REFERENCES "Establishment" ("EstablishmentID") MATCH SIMPLE
      ON UPDATE NO ACTION
      ON DELETE NO ACTION,
  CONSTRAINT establishment_permission_request_created_by_fk FOREIGN KEY ("CreatedByUserUID")
      REFERENCES "User" ("UserUID") MATCH SIMPLE
      ON UPDATE NO ACTION
      ON DELETE NO ACTION,
  CONSTRAINT user_permission_request_updated_by_fk FOREIGN KEY ("UpdatedByUserUID")
      REFERENCES "User" ("UserUID") MATCH SIMPLE
      ON UPDATE NO ACTION
      ON DELETE NO ACTION  
);

END TRANSACTION;

-- The following would be produced for only dev, staging and accessibility/demo databases - so please execute it accordingly.
\a \t
SELECT '';
SELECT CASE SUBSTRING(CURRENT_DATABASE(),1,3)
          WHEN 'sfc' THEN
             'ALTER TABLE "ParentEstablishmentPermissions" OWNER TO sfcadmin;' || E'\n' ||
             'GRANT ALL ON TABLE "ParentEstablishmentPermissions" TO sfcadmin;' || E'\n' ||
             'GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE "ParentEstablishmentPermissions" TO "Sfc_Admin_Role";' || E'\n' ||
             'GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE "ParentEstablishmentPermissions" TO "Sfc_App_Role";' || E'\n' ||
             'GRANT INSERT, SELECT, UPDATE ON TABLE "ParentEstablishmentPermissions" TO "Read_Update_Role";' || E'\n' ||
             'GRANT SELECT ON TABLE "ParentEstablishmentPermissions" TO "Read_Only_Role";'
          ELSE NULL
       END;
SELECT '';
\t \a
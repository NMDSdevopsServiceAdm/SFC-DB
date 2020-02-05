-- https://trello.com/c/1mmHEelF

SET SEARCH_PATH TO cqc;
BEGIN TRANSACTION;

DROP TABLE IF EXISTS "MandatoryTraining";
CREATE TABLE "MandatoryTraining"
(
   "ID"                 SERIAL NOT NULL PRIMARY KEY,
   "EstablishmentFK"    INTEGER NOT NULL,
   "TrainingCategoryFK" INTEGER NOT NULL,
   "JobFK"              INTEGER NOT NULL,
   created              TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
   updated              TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
   "CreatedByUserUID"   UUID NOT NULL,
   "UpdatedByUserUID"   UUID NOT NULL,
   CONSTRAINT establishment_mandatory_training_fk FOREIGN KEY ("EstablishmentFK")
      REFERENCES "Establishment" ("EstablishmentID") MATCH SIMPLE
      ON UPDATE NO ACTION
      ON DELETE NO ACTION,
   CONSTRAINT worker_training_mandatory_training_category_fk FOREIGN KEY ("TrainingCategoryFK")
      REFERENCES "TrainingCategories" ("ID") MATCH SIMPLE
      ON UPDATE NO ACTION
      ON DELETE NO ACTION,  
   CONSTRAINT job_mandatory_training_fk FOREIGN KEY ("JobFK")
      REFERENCES "Job" ("JobID") MATCH SIMPLE
      ON UPDATE NO ACTION
      ON DELETE NO ACTION,  
   CONSTRAINT user_mandatory_training_created_by_fk FOREIGN KEY ("CreatedByUserUID")
      REFERENCES "User" ("UserUID") MATCH SIMPLE
      ON UPDATE NO ACTION
      ON DELETE NO ACTION,
   CONSTRAINT user_owner_change_request_updated_by_fk FOREIGN KEY ("UpdatedByUserUID")
      REFERENCES "User" ("UserUID") MATCH SIMPLE
      ON UPDATE NO ACTION
      ON DELETE NO ACTION
);

CREATE SEQUENCE IF NOT EXISTS "MandatoryTraining_ID_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE IF EXISTS "MandatoryTraining_ID_seq" OWNED BY "MandatoryTraining"."ID";

END TRANSACTION;

-- The following would be produced for only dev, staging and accessibility/demo databases - so please execute it accordingly.
\a \t
SELECT '';
SELECT CASE SUBSTRING(CURRENT_DATABASE(),1,3)
          WHEN 'sfc' THEN
             'ALTER TABLE "MandatoryTraining" OWNER TO sfcadmin;' || E'\n' ||
             'GRANT ALL ON TABLE "MandatoryTraining" TO sfcadmin;' || E'\n' ||
             'GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE "MandatoryTraining" TO "Sfc_Admin_Role";' || E'\n' ||
             'GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE "MandatoryTraining" TO "Sfc_App_Role";' || E'\n' ||
             'GRANT INSERT, SELECT, UPDATE ON TABLE "MandatoryTraining" TO "Read_Update_Role";' || E'\n' ||
             'GRANT SELECT ON TABLE "MandatoryTraining" TO "Read_Only_Role";' || E'\n' ||
             'GRANT USAGE, SELECT ON SEQUENCE "MandatoryTraining_ID_seq" TO sfcadmin;' || E'\n' ||
             'GRANT USAGE, SELECT ON SEQUENCE "MandatoryTraining_ID_seq" TO "Sfc_App_Role";'
          ELSE NULL
       END;
SELECT '';
\t \a

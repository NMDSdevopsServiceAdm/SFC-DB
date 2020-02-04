-- https://trello.com/c/1mmHEelF

SET SEARCH_PATH TO cqc;
BEGIN TRANSACTION;

DROP TABLE IF EXISTS "MandatoryTraining";
CREATE TABLE "MandatoryTraining" (
	"ID" SERIAL NOT NULL PRIMARY KEY,
	"WorkplaceFK" INTEGER NOT NULL,
	"TrainingFK" INTEGER NOT NULL,
	"JobFK" INTEGER NOT NULL,
	"CreatedAt" DATE NOT NULL,
	"UpdatedAt" DATE NOT NULL,
	"CreatedByUserUID" INTEGER NOT NULL,
	"UpdatedByUserUID" INTEGER NOT NULL,
	CONSTRAINT establishment_mandatory_training_fk FOREIGN KEY ("WorkplaceFK")
      REFERENCES "Establishment" ("EstablishmentID") MATCH SIMPLE
      ON UPDATE NO ACTION
      ON DELETE NO ACTION,
    CONSTRAINT worker_training_mandatory_training_fk FOREIGN KEY ("TrainingFK")
      REFERENCES "WorkerTraining" ("ID") MATCH SIMPLE
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

END TRANSACTION;
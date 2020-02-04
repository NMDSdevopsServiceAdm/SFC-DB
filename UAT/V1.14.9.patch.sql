-- https://trello.com/c/1mmHEelF

SET SEARCH_PATH TO cqc;
BEGIN TRANSACTION;

DROP TABLE IF EXISTS "MandatoryTraining";
CREATE TABLE "MandatoryTraining" (
	"ID"               SERIAL NOT NULL PRIMARY KEY,
	"EstablishmentFK"  INTEGER NOT NULL,
	"TrainingFK"       INTEGER NOT NULL,
	"JobFK"            INTEGER NOT NULL,
	created            TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
	updated            TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
	"CreatedByUserUID" UUID NOT NULL,
	"UpdatedByUserUID" UUID NOT NULL,
	CONSTRAINT establishment_mandatory_training_fk FOREIGN KEY ("EstablishmentFK")
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
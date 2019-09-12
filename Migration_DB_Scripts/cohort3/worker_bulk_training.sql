-- FUNCTION: migration.worker_bulk_training(integer)

-- DROP FUNCTION migration.worker_bulk_training(integer);

CREATE OR REPLACE FUNCTION migration.worker_bulk_training(
	estbid integer)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
DECLARE
BEGIN
  RAISE NOTICE '... migrating Worker training records (in bulk)';

  INSERT INTO cqc."WorkerTraining" (
	"TribalID",
	"UID",
	"WorkerFK",
	"CategoryFK",
	"Title",
	"Accredited",
	"Completed",
	"Expires",
	"Notes",
	created,
	updated,
	updatedby)
	SELECT
		training_tribalid,
		target_uid,
		target_workerfk,
		target_training_id,
		target_title,
		target_accredited::cqc."WorkerTrainingAccreditation",
		target_completed,
		target_expires,
		target_notes,
		target_created,
		target_updated,
		target_updatedby
	FROM (SELECT
			worker_training.id AS training_tribalid,
			"Worker"."ID" AS target_workerfk,
			worker_training.training_category_id AS tribal_training_id,
			trainingcategories.sfcid AS target_training_id,
			CASE WHEN length(worker_training.training_name) > 120 THEN LEFT(worker_training.training_name, 120) ELSE worker_training.training_name END AS target_title,
			CASE WHEN length(worker_training.training_name) > 120 THEN worker_training.training_name ELSE NULL END AS target_notes,
			worker_training.achievedate as target_completed,
			worker_training.expirydate as target_expires,
			CASE WHEN worker_training.isaccredited = 0 THEN 'No' WHEN worker_training.isaccredited = 1 THEN 'Yes' ELSE NULL END AS target_accredited,
			worker_training.createddate AS target_created,
			COALESCE(worker_training.updateddate, worker_training.createddate) AS target_updated,
			'migration' AS target_updatedby,
			migration.generate_uuid() AS target_uid
		FROM worker_training
			INNER JOIN worker
				INNER JOIN establishment ON establishment.id = worker.establishment_id
				INNER JOIN cqc."Worker" ON "Worker"."TribalID" = worker.id
				ON worker.id = worker_training.worker_id
			LEFT JOIN migration.trainingcategories ON trainingcategories.tribalid = worker_training.training_category_id
			LEFT JOIN cqc."WorkerTraining" ON "WorkerTraining"."TribalID" = worker_training.id
		WHERE establishment.id=estbid
/*
(248,189859,225383,59, 248, 669, 187078, 215842, 162286, 2533, 2952, 200560, 225586, 3278, 60682, 5228, 12937, 232842, 10121, 10757, 216264, 12041, 17047, 177958, 136485, 15000, 20876, 233642, 17661, 168369, 40762, 205162, 154806, 42683, 45882, 196119, 85603, 181062, 218926, 196840, 144133, 215263, 170258, 217893, 231842)
*/
		  AND "WorkerTraining"."TribalID" IS NULL
		ORDER BY target_created) AllTrainingRecords;
END;
$BODY$;

ALTER FUNCTION migration.worker_bulk_training(integer)
    OWNER TO postgres;

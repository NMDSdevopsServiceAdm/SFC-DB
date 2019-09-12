-- FUNCTION: migration.worker_bulk_qualifications(integer)

-- DROP FUNCTION migration.worker_bulk_qualifications(integer);

CREATE OR REPLACE FUNCTION migration.worker_bulk_qualifications(
	estbid integer)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
DECLARE
BEGIN
  RAISE NOTICE '... migrating Worker qualification records (in bulk)';

  INSERT INTO cqc."WorkerQualifications" (
	"TribalID",
	"UID",
	"WorkerFK",
	"QualificationsFK",
	"Year",
	"Notes",
	created,
	updated,
	updatedby,
	"DataSource")
		SELECT
			worker_qualification.id AS tribal_qualification_id,
			migration.generate_uuid() AS target_uid,
			"Worker"."ID" AS target_worker_id,
			qualificationcategories.sfcid AS target_qualification_id,
			worker_qualification.achievedate AS target_qualification_year,
			CASE WHEN qualificationcategories.sfcid = 27 THEN CONCAT(qualification.name, ' - ', worker_qualification.notes) ELSE worker_qualification.notes END AS target_qualification_notes,
			worker_qualification.date_qualification AS target_qualification_created,
			worker_qualification.date_qualification AS target_qualification_updated,
			'migration' AS target_qualification_updated_by,
			NULL
		FROM worker_qualification
			INNER JOIN qualification_level
				INNER JOIN migration.qualificationcategories
						INNER JOIN cqc."Qualifications" ON qualificationcategories.sfcid = "Qualifications"."ID"
						ON qualificationcategories.tribalid = qualification_level.id
					INNER JOIN qualification ON qualification.id = qualification_level.qualification_id
				ON qualification_level.id = worker_qualification.qualification_level_id
			LEFT JOIN cqc."WorkerQualifications"
				ON  "WorkerQualifications"."TribalID" = worker_qualification.id
			INNER JOIN worker
				INNER JOIN establishment ON establishment.id = worker.establishment_id
				INNER JOIN cqc."Worker" ON "Worker"."TribalID" = worker.id
					ON worker.id = worker_qualification.worker_id
		WHERE establishment.id=estbid 
/*
(248,189859,225383,59, 248, 669, 187078, 215842, 162286, 2533, 2952, 200560, 225586, 3278, 60682, 5228, 12937, 232842, 10121, 10757, 216264, 12041, 17047, 177958, 136485, 15000, 20876, 233642, 17661, 168369, 40762, 205162, 154806, 42683, 45882, 196119, 85603, 181062, 218926, 196840, 144133, 215263, 170258, 217893, 231842)
*/
			AND "WorkerQualifications"."TribalID" IS NULL
			AND worker_qualification.achievestatus <> 2
	ORDER BY target_qualification_created;
END;
$BODY$;

ALTER FUNCTION migration.worker_bulk_qualifications(integer)
    OWNER TO postgres;

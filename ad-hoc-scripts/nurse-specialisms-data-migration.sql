BEGIN;

UPDATE cqc."Worker"
SET "NurseSpecialismsValue" = CASE
		WHEN "NurseSpecialismFKValue" BETWEEN 1 AND 6 THEN 'Yes'::cqc."enum_Worker_NurseSpecialismsValue"
		WHEN "NurseSpecialismFKValue" = 7 THEN 'No'::cqc."enum_Worker_NurseSpecialismsValue"
		WHEN "NurseSpecialismFKValue" = 8 THEN 'Don''t know'::cqc."enum_Worker_NurseSpecialismsValue"
	    ELSE NULL
	END,
	"NurseSpecialismsSavedAt" = (SELECT CURRENT_TIMESTAMP), 
	"NurseSpecialismsChangedAt" = (SELECT CURRENT_TIMESTAMP), 
	"NurseSpecialismsSavedBy" = 'data-migration-script',
	"NurseSpecialismsChangedBy" = 'data-migration-script'
WHERE "NurseSpecialismFKValue" IS NOT NULL
AND "NurseSpecialismsValue" IS NULL;

INSERT INTO cqc."WorkerNurseSpecialisms"("WorkerFK", "NurseSpecialismFK")
SELECT "ID", "NurseSpecialismFKValue"
FROM cqc."Worker"
WHERE "NurseSpecialismsValue" = 'Yes'
AND "NurseSpecialismFKValue" IS NOT NULL;

COMMIT;
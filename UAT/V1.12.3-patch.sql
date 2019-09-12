-- https://trello.com/c/6DpN53GL

DROP VIEW IF EXISTS cqc."AllEstablishmentAndWorkersVW";
DROP VIEW IF EXISTS cqc."EstablishmentMainServicesWithCapacitiesVW";
CREATE OR REPLACE VIEW cqc."EstablishmentMainServicesWithCapacitiesVW" AS
SELECT
	"EstablishmentID",
	CASE WHEN "CAPACITY" is null THEN -1 ELSE "CAPACITY" END,
	CASE WHEN "UTILISATION" is null THEN -1 ELSE "UTILISATION" END
FROM (
	SELECT
		"EstablishmentID",
		SUM("Answer") FILTER(WHERE "Type"='Capacity') "CAPACITY",
		SUM("Answer") FILTER(WHERE "Type"='Utilisation') "UTILISATION"
	FROM (
		SELECT
			"AllEstablishmentCapacityQuestions"."EstablishmentID",
			"AllEstablishmentCapacityQuestions"."ServiceCapacityID",
			"AllEstablishmentCapacityQuestions"."Sequence",
			"AllEstablishmentCapacityQuestions"."Type",
			"AllEstablishmentCapacityQuestions"."Question",
			"AllEstablishmentCapacities"."Answer"
		FROM
			(
				SELECT
					"Establishment"."EstablishmentID",
					"ServicesCapacity"."ServiceCapacityID",
					"ServicesCapacity"."Sequence",
					"ServicesCapacity"."Type",
					"ServicesCapacity"."Question"
				FROM cqc."ServicesCapacity", cqc."Establishment"
					INNER JOIN cqc.services on "Establishment"."MainServiceFKValue" = services.id
					LEFT JOIN cqc."EstablishmentCapacity" on "Establishment"."EstablishmentID" = "EstablishmentCapacity"."EstablishmentID"
				WHERE "ServicesCapacity"."ServiceID" = services.id
          		  AND services.id in (SELECT DISTINCT "ServiceID" FROM cqc."ServicesCapacity" GROUP BY "ServiceID" HAVING COUNT(0) > 1)
				GROUP BY "Establishment"."EstablishmentID", "ServicesCapacity"."ServiceCapacityID", "ServicesCapacity"."Type", "ServicesCapacity"."Sequence"
				ORDER BY "Establishment"."EstablishmentID", "ServicesCapacity"."Sequence"
			) "AllEstablishmentCapacityQuestions"
				LEFT JOIN (
					SELECT "EstablishmentID", "EstablishmentCapacity"."ServiceCapacityID", "Answer"
					FROM cqc."EstablishmentCapacity"
						INNER JOIN cqc."ServicesCapacity" on "ServicesCapacity"."ServiceCapacityID" = "EstablishmentCapacity"."ServiceCapacityID"
				) "AllEstablishmentCapacities"
					ON "AllEstablishmentCapacities"."ServiceCapacityID" = "AllEstablishmentCapacityQuestions"."ServiceCapacityID" AND
					   "AllEstablishmentCapacities"."EstablishmentID" = "AllEstablishmentCapacityQuestions"."EstablishmentID"
		ORDER BY "AllEstablishmentCapacityQuestions"."EstablishmentID", "AllEstablishmentCapacityQuestions"."Sequence") AS "EstablishmentMainServicesWithCapacities"
	GROUP BY "EstablishmentID") AS "EstablishmentMainServicesWithCapacitiesTwo"
UNION
SELECT
	"EstablishmentID",
	CASE WHEN "CAPACITY" is null THEN -1 ELSE "CAPACITY" END,
	null "UTILISATION"
FROM (
	SELECT
		"EstablishmentID",
		SUM("Answer") FILTER(WHERE "Type"='Capacity') "CAPACITY"
	FROM (
		SELECT
			"AllEstablishmentCapacityQuestions"."EstablishmentID",
			"AllEstablishmentCapacityQuestions"."ServiceCapacityID",
			"AllEstablishmentCapacityQuestions"."Sequence",
			"AllEstablishmentCapacityQuestions"."Type",
			"AllEstablishmentCapacityQuestions"."Question",
			"AllEstablishmentCapacities"."Answer"
		FROM
			(
				SELECT
					"Establishment"."EstablishmentID",
					"ServicesCapacity"."ServiceCapacityID",
					"services"."id",
					"services"."name",
					"ServicesCapacity"."Sequence",
					"ServicesCapacity"."Type",
					"ServicesCapacity"."Question"
				FROM cqc."ServicesCapacity", cqc."Establishment"
					INNER JOIN cqc.services on "Establishment"."MainServiceFKValue" = services.id
					LEFT JOIN cqc."EstablishmentCapacity" on "Establishment"."EstablishmentID" = "EstablishmentCapacity"."EstablishmentID"
				WHERE "ServicesCapacity"."ServiceID" = services.id
          		  AND services.id in (SELECT DISTINCT "ServiceID" FROM cqc."ServicesCapacity" GROUP BY "ServiceID" HAVING COUNT(0) = 1)
				  AND "ServicesCapacity"."Type" = 'Capacity'
				GROUP BY "Establishment"."EstablishmentID", "ServicesCapacity"."ServiceCapacityID", "services"."id", "services"."name", "ServicesCapacity"."Sequence"
				ORDER BY "Establishment"."EstablishmentID", "ServicesCapacity"."Sequence"
			) "AllEstablishmentCapacityQuestions"
				LEFT JOIN (
					SELECT "EstablishmentID", "EstablishmentCapacity"."ServiceCapacityID", "Answer"
					FROM cqc."EstablishmentCapacity"
						INNER JOIN cqc."ServicesCapacity" on "ServicesCapacity"."ServiceCapacityID" = "EstablishmentCapacity"."ServiceCapacityID"
				) "AllEstablishmentCapacities"
					ON "AllEstablishmentCapacities"."ServiceCapacityID" = "AllEstablishmentCapacityQuestions"."ServiceCapacityID" AND
					   "AllEstablishmentCapacities"."EstablishmentID" = "AllEstablishmentCapacityQuestions"."EstablishmentID"
		ORDER BY "AllEstablishmentCapacityQuestions"."EstablishmentID", "AllEstablishmentCapacityQuestions"."Sequence") AS "EstablishmentMainServicesWithCapacities"
	GROUP BY "EstablishmentID") AS "EstablishmentMainServicesWithCapacitiesTwo"
UNION
SELECT
	"EstablishmentID",
	null "CAPACITY",
	CASE WHEN "UTILISATION" is null THEN -1 ELSE "UTILISATION" END
FROM (
	SELECT
		"EstablishmentID",
		SUM("Answer") FILTER(WHERE "Type"='Utilisation') "UTILISATION"
	FROM (
		SELECT
			"AllEstablishmentCapacityQuestions"."EstablishmentID",
			"AllEstablishmentCapacityQuestions"."ServiceCapacityID",
			"AllEstablishmentCapacityQuestions"."Sequence",
			"AllEstablishmentCapacityQuestions"."Type",
			"AllEstablishmentCapacityQuestions"."Question",
			"AllEstablishmentCapacities"."Answer"
		FROM
			(
				SELECT
					"Establishment"."EstablishmentID",
					"ServicesCapacity"."ServiceCapacityID",
					"services"."id",
					"services"."name",
					"ServicesCapacity"."Sequence",
					"ServicesCapacity"."Type",
					"ServicesCapacity"."Question"
				FROM cqc."ServicesCapacity", cqc."Establishment"
					INNER JOIN cqc.services on "Establishment"."MainServiceFKValue" = services.id
					LEFT JOIN cqc."EstablishmentCapacity" on "Establishment"."EstablishmentID" = "EstablishmentCapacity"."EstablishmentID"
				WHERE "ServicesCapacity"."ServiceID" = services.id
          		  AND services.id in (SELECT DISTINCT "ServiceID" FROM cqc."ServicesCapacity" GROUP BY "ServiceID" HAVING COUNT(0) = 1)
				  AND "ServicesCapacity"."Type" = 'Utilisation'
				GROUP BY "Establishment"."EstablishmentID", "ServicesCapacity"."ServiceCapacityID", "services"."id", "services"."name", "ServicesCapacity"."Sequence"
				ORDER BY "Establishment"."EstablishmentID", "ServicesCapacity"."Sequence"
			) "AllEstablishmentCapacityQuestions"
				LEFT JOIN (
					SELECT "EstablishmentID", "EstablishmentCapacity"."ServiceCapacityID", "Answer"
					FROM cqc."EstablishmentCapacity"
						INNER JOIN cqc."ServicesCapacity" on "ServicesCapacity"."ServiceCapacityID" = "EstablishmentCapacity"."ServiceCapacityID"
				) "AllEstablishmentCapacities"
					ON "AllEstablishmentCapacities"."ServiceCapacityID" = "AllEstablishmentCapacityQuestions"."ServiceCapacityID" AND
					   "AllEstablishmentCapacities"."EstablishmentID" = "AllEstablishmentCapacityQuestions"."EstablishmentID"
		ORDER BY "AllEstablishmentCapacityQuestions"."EstablishmentID", "AllEstablishmentCapacityQuestions"."Sequence") AS "EstablishmentMainServicesWithCapacities"
	GROUP BY "EstablishmentID") AS "EstablishmentMainServicesWithCapacitiesTwo"
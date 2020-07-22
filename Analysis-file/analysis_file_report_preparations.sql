SET SEARCH_PATH TO cqc;
------------------------------
CREATE TABLE "Afr1BatchiSkAi0mo" AS
SELECT "EstablishmentID",
       ROW_NUMBER() OVER (ORDER BY "EstablishmentID") "SerialNo",
       NULL::INT "BatchNo",
       TO_DATE('22-07-2020','DD-MM-YYYY')::DATE AS "RunDate"
FROM   "Establishment"
WHERE  "Archived" = false
AND    "Status" IS NULL;
------------------------------
CREATE INDEX "Afr1BatchiSkAi0mo_idx" ON "Afr1BatchiSkAi0mo"("BatchNo");
------------------------------
CREATE OR REPLACE FUNCTION create_batch_4_workspace(p_no_of_workspace integer) RETURNS VOID AS $$
DECLARE
   current_status INT := 1;
   no_of_batch_created INT := 0;
BEGIN
   LOOP
      current_status := (SELECT COUNT(1) FROM "Afr1BatchiSkAi0mo" WHERE "BatchNo" IS NULL);
      IF current_status <> 0 THEN
         no_of_batch_created := no_of_batch_created + 1;
      END IF;

      EXIT WHEN current_status = 0;

      UPDATE "Afr1BatchiSkAi0mo"
      SET    "BatchNo" = (SELECT MAX(COALESCE("BatchNo",0)) + 1 FROM "Afr1BatchiSkAi0mo")
      WHERE  "SerialNo" <= p_no_of_workspace
      AND    "BatchNo" IS NULL;

      UPDATE "Afr1BatchiSkAi0mo"
      SET    "SerialNo" = "SerialNo" - p_no_of_workspace
      WHERE  "BatchNo" IS NULL;
   END LOOP;

   RAISE NOTICE 'Created: [ % ] batch.', (SELECT COUNT(DISTINCT "BatchNo") FROM "Afr1BatchiSkAi0mo");
END;
$$ LANGUAGE plpgsql;
------------------------------
SELECT create_batch_4_workspace(2000);
DROP FUNCTION create_batch_4_workspace(integer);
SELECT "BatchNo",COUNT(1) "NoOfWorkspaces" FROM "Afr1BatchiSkAi0mo" GROUP BY 1 ORDER BY 1;
------------------------------
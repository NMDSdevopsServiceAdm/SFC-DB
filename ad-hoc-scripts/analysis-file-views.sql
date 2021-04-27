BEGIN;

CREATE MATERIALIZED VIEW "cqc"."WorkerContractStats" AS SELECT "Worker"."EstablishmentFK",
    "Worker"."MainJobFKValue",
    count(*) AS total_staff,
    count(*) FILTER (WHERE "Worker"."ContractValue" = 'Permanent'::cqc."WorkerContract") AS total_perm_staff,
    count(*) FILTER (WHERE "Worker"."ContractValue" = 'Temporary'::cqc."WorkerContract") AS total_temp_staff,
    count(*) FILTER (WHERE "Worker"."ContractValue" = 'Pool/Bank'::cqc."WorkerContract") AS total_pool_bank,
    count(*) FILTER (WHERE "Worker"."ContractValue" = 'Agency'::cqc."WorkerContract") AS total_agency,
    count(*) FILTER (WHERE "Worker"."ContractValue" = 'Other'::cqc."WorkerContract") AS total_other,
    count(*) FILTER (WHERE "Worker"."ContractValue" = ANY (ARRAY['Permanent'::cqc."WorkerContract", 'Temporary'::cqc."WorkerContract"])) AS total_employed
   FROM cqc."Worker"
  WHERE "Worker"."Archived" = false
  GROUP BY "Worker"."EstablishmentFK", ROLLUP("Worker"."MainJobFKValue");
  
CREATE MATERIALIZED VIEW "cqc"."WorkerJobStats" AS SELECT "EstablishmentJobs"."EstablishmentID",
    "EstablishmentJobs"."JobID",
    sum("EstablishmentJobs"."Total") FILTER (WHERE "EstablishmentJobs"."JobType" = 'Starters'::cqc.job_type) AS total_starters,
    sum("EstablishmentJobs"."Total") FILTER (WHERE "EstablishmentJobs"."JobType" = 'Leavers'::cqc.job_type) AS total_leavers,
    sum("EstablishmentJobs"."Total") FILTER (WHERE "EstablishmentJobs"."JobType" = 'Vacancies'::cqc.job_type) AS total_vacancies
   FROM cqc."EstablishmentJobs"
  GROUP BY "EstablishmentJobs"."EstablishmentID", ROLLUP("EstablishmentJobs"."JobID");
  
CREATE MATERIALIZED VIEW "cqc"."WorkerQualificationStats" AS SELECT wt."WorkerFK",
    wt."QualificationsFK",
    wt."Year",
    count(*) AS total_quals
   FROM cqc."Worker" w
     JOIN cqc."WorkerQualifications" wt ON wt."WorkerFK" = w."ID"
  WHERE w."Archived" = false
  GROUP BY wt."WorkerFK", ROLLUP(wt."QualificationsFK", wt."Year");
  
CREATE MATERIALIZED VIEW "cqc"."WorkerTrainingStats" AS SELECT wt."WorkerFK",
    wt."CategoryFK",
    count(*) AS total_training,
    count(*) FILTER (WHERE wt."Accredited" = 'Yes'::cqc."WorkerTrainingAccreditation") AS total_accredited_yes,
    count(*) FILTER (WHERE wt."Accredited" = 'No'::cqc."WorkerTrainingAccreditation") AS total_accredited_no,
    count(*) FILTER (WHERE wt."Accredited" = 'Don''t know'::cqc."WorkerTrainingAccreditation") AS total_accredited_unknown,
    to_char(max(wt."Completed")::timestamp with time zone, 'DD/MM/YYYY'::text) AS latest_training_date
   FROM cqc."Worker" w
     JOIN cqc."WorkerTraining" wt ON wt."WorkerFK" = w."ID"
  WHERE w."Archived" = false
  GROUP BY wt."WorkerFK", ROLLUP(wt."CategoryFK");
CREATE UNIQUE INDEX WorkerContractStats_Uniq_Idx
  ON cqc."WorkerContractStats" ("EstablishmentFK", "MainJobFKValue");
CREATE INDEX WorkerContractStats_MainJob_Idx
  ON cqc."WorkerContractStats" ("MainJobFKValue");
CREATE UNIQUE INDEX WorkerJobStats_Uniq_Idx
  ON cqc."WorkerJobStats" ("EstablishmentID", "JobID");
CREATE INDEX WorkerJobStats_JobID_Idx
  ON cqc."WorkerJobStats" ("JobID");
  
CREATE INDEX WorkerTrainingStats_Worker_Category_Idx ON cqc."WorkerTrainingStats" ("WorkerFK", "CategoryFK");
CREATE INDEX WorkerQualificationStats_Worker_Qualification_Idx ON cqc."WorkerQualificationStats" ("WorkerFK", "QualificationsFK");

COMMIT;

CREATE INDEX CONCURRENTLY User_Est_Archived_Idx ON cqc."User" ("EstablishmentID", "Archived");
CREATE INDEX CONCURRENTLY WorkerAudit_EventType_Idx ON cqc."WorkerAudit" ("EventType");
CREATE INDEX CONCURRENTLY WorkerAudit_Worker_EventType_Idx ON cqc."WorkerAudit" ("WorkerFK", "EventType");
CREATE INDEX CONCURRENTLY Pcodedata_Postcode_Local_Idx ON cqcref."pcodedata" ("postcode", "local_custodian_code");
CREATE INDEX CONCURRENTLY Establishment_Archived_Idx ON cqc."Establishment" ("Archived");
CREATE INDEX CONCURRENTLY EstablishmentServiceUsers_Service_Est_Idx ON cqc."EstablishmentServiceUsers" ("ServiceUserID", "EstablishmentID");
CREATE INDEX CONCURRENTLY Worker_Archived_Est_Idx ON cqc."Worker" ("Archived", "EstablishmentFK");
CREATE INDEX CONCURRENTLY WorkerQuals_Qual_Worker_Idx ON cqc."WorkerQualifications" ("QualificationsFK", "WorkerFK");
CREATE INDEX CONCURRENTLY WorkerTraining_Category_Accred_Worker_Idx ON cqc."WorkerTraining" ("CategoryFK", "Accredited", "WorkerFK");
CREATE INDEX CONCURRENTLY WorkerTraining_Category_Worker_Idx ON cqc."WorkerTraining" ("CategoryFK", "WorkerFK");
CREATE INDEX CONCURRENTLY WorkerJobs_Worker_Job_Idx ON cqc."WorkerJobs" ("JobFK", "WorkerFK");

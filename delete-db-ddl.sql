-- views
DROP VIEW IF EXISTS cqc."VacanciesVW";
DROP VIEW IF EXISTS cqc."StartersVW";
DROP VIEW IF EXISTS cqc."LeaversVW";
DROP VIEW IF EXISTS cqc."AllEstablishmentAndWorkersVW";

-- other
DROP TABLE IF EXISTS cqc."Feedback";

-- workers
DROP TABLE IF EXISTS cqc."WorkerTraining";
DROP TABLE IF EXISTS cqc."WorkerQualifications";
DROP TABLE IF EXISTS cqc."WorkerAudit";
DROP TABLE IF EXISTS cqc."WorkerJobs";
DROP TABLE IF EXISTS cqc."Worker";
DROP TABLE IF EXISTS cqc."WorkerLeaveReasons";

-- establishments
DROP TABLE IF EXISTS cqc."EstablishmentServices";
DROP TABLE IF EXISTS cqc."EstablishmentServiceUsers";
DROP TABLE IF EXISTS cqc."EstablishmentLocalAuthority";
DROP TABLE IF EXISTS cqc."EstablishmentJobs";
DROP TABLE IF EXISTS cqc."EstablishmentCapacity";

-- user
DROP TABLE IF EXISTS cqc."AddUserTracking";
DROP TABLE IF EXISTS cqc."PasswdResetTracking";
DROP TABLE IF EXISTS cqc."UserAudit";

-- registration
DROP TABLE IF EXISTS cqc."EstablishmentAudit";
DROP TABLE IF EXISTS cqc."Login";
DROP TABLE IF EXISTS cqc."User";
DROP TABLE IF EXISTS cqc."Establishment";

-- lookup
DROP TABLE IF EXISTS cqc."Job";
DROP TABLE IF EXISTS cqc."Cssr";
DROP TABLE IF EXISTS cqc."ServicesCapacity";
DROP TABLE IF EXISTS cqc."ServiceUsers";
DROP TABLE IF EXISTS cqc."services";
DROP TABLE IF EXISTS cqc."Country";
DROP TABLE IF EXISTS cqc."Ethnicity";
DROP TABLE IF EXISTS cqc."LocalAuthority";
DROP TABLE IF EXISTS cqc."Nationality";
DROP TABLE IF EXISTS cqc."Qualification";
DROP TABLE IF EXISTS cqc."RecruitedFrom";
DROP TABLE IF EXISTS cqc."Qualifications";
DROP TABLE IF EXISTS cqc."TrainingCategories";


-- large external reference - do not drop!
-- cqc.pcodedata;
-- cqc.location;

-- types
DROP TYPE IF EXISTS cqc.est_employertype_enum;
DROP TYPE IF EXISTS cqc.job_type;
DROP TYPE IF EXISTS cqc.job_declaration;
DROP TYPE IF EXISTS cqc."WorkerContract";
DROP TYPE IF EXISTS cqc."WorkerAuditChangeType";
DROP TYPE IF EXISTS cqc."UserAuditChangeType";
DROP TYPE IF EXISTS cqc."AuditChangeType";
DROP TYPE IF EXISTS cqc."WorkerAnnualHourlyPay";
DROP TYPE IF EXISTS cqc."WorkerApprenticeshipTraining";
DROP TYPE IF EXISTS cqc."WorkerApprovedMentalHealthWorker";
DROP TYPE IF EXISTS cqc."WorkerBritishCitizenship";
DROP TYPE IF EXISTS cqc."WorkerCareCertificate";
DROP TYPE IF EXISTS cqc."WorkerContract";
DROP TYPE IF EXISTS cqc."WorkerCountryOfBirth";
DROP TYPE IF EXISTS cqc."WorkerDaysSick";
DROP TYPE IF EXISTS cqc."WorkerDisability";
DROP TYPE IF EXISTS cqc."WorkerGender";
DROP TYPE IF EXISTS cqc."WorkerNationality";
DROP TYPE IF EXISTS cqc."WorkerOtherJobs";
DROP TYPE IF EXISTS cqc."WorkerOtherQualifications";
DROP TYPE IF EXISTS cqc."WorkerQualificationInSocialCare";
DROP TYPE IF EXISTS cqc."WorkerSocialCareStartDate";
DROP TYPE IF EXISTS cqc."WorkerWeeklyHoursAverage";
DROP TYPE IF EXISTS cqc."WorkerWeeklyHoursContracted";
DROP TYPE IF EXISTS cqc."WorkerYearArrived";
DROP TYPE IF EXISTS cqc."WorkerZeroHoursContract";
DROP TYPE IF EXISTS cqc."WorkerRecruitedFrom";
DROP TYPE IF EXISTS cqc."user_role";
DROP TYPE IF EXISTS cqc."EstablishmentAuditChangeType";
DROP TYPE IF EXISTS cqc.establishment_owner;
DROP TYPE IF EXISTS cqc.establishment_parent_access_permission;
DROP TYPE IF EXISTS cqc."ServicesCapacityType";
DROP TYPE IF EXISTS cqc."DataSource";
DROP TYPE IF EXISTS cqc."worker_registerednurse_enum";
DROP TYPE IF EXISTS cqc."worker_registerednurses_enum";


-- sequences
DROP SEQUENCE IF EXISTS cqc."EstablishmentCapacity_EstablishmentCapacityID_seq";
DROP SEQUENCE IF EXISTS cqc."EstablishmentJobs_EstablishmentJobID_seq";
DROP SEQUENCE IF EXISTS cqc."EstablishmentLocalAuthority_EstablishmentLocalAuthorityID_seq";
DROP SEQUENCE IF EXISTS cqc."Establishment_EstablishmentID_seq";
DROP SEQUENCE IF EXISTS cqc."Feedback_seq";
DROP SEQUENCE IF EXISTS cqc."Login_ID_seq";
DROP SEQUENCE IF EXISTS cqc."User_RegistrationID_seq";
DROP SEQUENCE IF EXISTS cqc."passwdresettracking_seq";
DROP SEQUENCE IF EXISTS cqc."passwdresettracking_seq";
DROP SEQUENCE IF EXISTS cqc.services_id_seq;
DROP SEQUENCE IF EXISTS cqc."NmdsID_seq";
DROP SEQUENCE IF EXISTS cqc."AddUserTracking_seq";

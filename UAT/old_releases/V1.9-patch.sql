-- additional qualifications for mapping - https://trello.com/c/lcIxIvdw
INSERT INTO cqc."Qualifications" ("ID", "Seq", "Group", "Title", "Code", "From", "Until", "Level", "MultipleLevel", "RelevantToSocialCare", "AnalysisFileCode") VALUES 
  (134, 675, 'Certificate','Any other social care relevant certificate', 113, '2018-01-01', NULL,NULL, 'No', 'Yes', 'unknown'),
  (135, 676, 'Certificate','Any other non-social care relevant certificate', 114, '2018-01-01', NULL,NULL, 'No', 'No', 'unknown');

UPDATE cqc."Qualifications"
SET "Level" = NULL
WHERE "ID" in (25, 26, 89, 113, 114, 115, 116);


-- Additional service capacities -  https://trello.com/c/O1RxWYlU
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question") values (17, 21, 1, 'Number of people receiving care on the completion date');
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Sequence", "Question") values (18, 23, 1, 'Number of people using the service on the completion date');

-- V1.9 patch - parents and subs

-- establishment facts
ALTER TABLE cqc."Establishment" ADD COLUMN "IsParent" BOOLEAN DEFAULT FALSE;
ALTER TABLE cqc."Establishment" ADD COLUMN "ParentID" INTEGER NULL;
ALTER TABLE cqc."Establishment" ADD COLUMN "ParentUID" UUID NULL;
ALTER TABLE cqc."Establishment" ADD CONSTRAINT establishment_establishment_parent_fk FOREIGN KEY ("ParentID")
        REFERENCES cqc."Establishment" ("EstablishmentID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION;


-- analysis view
DROP VIEW IF EXISTS "cqc"."AllEstablishmentAndWorkersVW";
CREATE OR REPLACE VIEW "cqc"."AllEstablishmentAndWorkersVW" AS
  SELECT
    "Establishment"."EstablishmentID",
    "Establishment"."EstablishmentUID",
    "Establishment"."TribalID" AS "TribalEstablishmentID",
    "Establishment"."NmdsID",
    "Establishment"."Address",
    "Establishment"."LocationID",
    "Establishment"."PostCode",
    "Establishment"."IsRegulated",
    "Establishment"."OverallWdfEligibility",
    "Establishment"."LastWdfEligibility" AS "EstablishmentLastWdfEligibility",
    "Establishment"."IsParent",
    "Establishment"."ParentUID",
    "Establishment"."NameValue",
    "Establishment"."NameSavedAt",
    "Establishment"."NameChangedAt",
    "Establishment"."MainServiceFKValue",
    "Establishment"."MainServiceFKSavedAt",
    "Establishment"."MainServiceFKChangedAt",
    "Establishment"."EmployerTypeValue",
    "Establishment"."EmployerTypeSavedAt",
    "Establishment"."EmployerTypeChangedAt",
    "Establishment"."NumberOfStaffValue",
    "Establishment"."NumberOfStaffSavedAt",
    "Establishment"."NumberOfStaffChangedAt",
    (select count(0) from cqc."EstablishmentServices" where "EstablishmentServices"."EstablishmentID" = "Establishment"."EstablishmentID") AS "OtherServices",
    (select count(0) from cqc."EstablishmentCapacity" where "EstablishmentCapacity"."EstablishmentID" = "Establishment"."EstablishmentID") AS "Capacities",
    (select count(0) from cqc."EstablishmentServiceUsers" where "EstablishmentServiceUsers"."EstablishmentID" = "Establishment"."EstablishmentID") AS "ServiceUsers",
    "Establishment"."OtherServicesSavedAt",
    "Establishment"."OtherServicesChangedAt",
    "Establishment"."ServiceUsersSavedAt",
    "Establishment"."ServiceUsersChangedAt",
    "Establishment"."CapacityServicesSavedAt",
    "Establishment"."CapacityServicesChangedAt",
    "Establishment"."ShareDataValue",
    "Establishment"."ShareDataSavedAt",
    "Establishment"."ShareDataChangedAt",
    "Establishment"."ShareDataWithCQC",
    "Establishment"."ShareDataWithLA",
    (select count(0) from cqc."EstablishmentLocalAuthority" where "EstablishmentLocalAuthority"."EstablishmentID" = "Establishment"."EstablishmentID") AS "LocalAuthorities",
    "Establishment"."ShareWithLASavedAt",
    "Establishment"."ShareWithLAChangedAt",
	case when "Establishment"."VacanciesValue" = 'With Jobs' then "VacanciesStartersLeavers"."TotalVacancies"::text else "Establishment"."VacanciesValue"::text end AS "VacanciesValue",
	case when "Establishment"."StartersValue" = 'With Jobs' then "VacanciesStartersLeavers"."TotalStarters"::text else "Establishment"."StartersValue"::text end AS "StartersValue",
	case when "Establishment"."LeaversValue" = 'With Jobs' then "VacanciesStartersLeavers"."TotalLeavers"::text else "Establishment"."LeaversValue"::text end AS  "LeaversValue",
    "Establishment"."VacanciesSavedAt",
    "Establishment"."VacanciesChangedAt",
    "Establishment"."StartersSavedAt",
    "Establishment"."StartersChangedAt",
    "Establishment"."LeaversSavedAt",
    "Establishment"."LeaversChangedAt",
    "Establishment".created AS "EstablishmentCreated",
    "Establishment".updated AS "EstablishmentUpdated",
    "Worker"."WorkerUID",
    "Worker"."EstablishmentFK",
    "Worker"."TribalID" AS "TribalWorkerID",
    "Worker"."LastWdfEligibility"  AS "WorkerLastWdfEligibility",
    "Worker"."NameOrIdSavedAt",
    "Worker"."NameOrIdChangedAt",
    "Worker"."ContractValue",
    "Worker"."ContractSavedAt",
    "Worker"."ContractChangedAt",
    "Worker"."MainJobFKValue",
    "Worker"."MainJobFKSavedAt",
    "Worker"."MainJobFKChangedAt",
    "Worker"."ApprovedMentalHealthWorkerValue",
    "Worker"."ApprovedMentalHealthWorkerSavedAt",
    "Worker"."ApprovedMentalHealthWorkerChangedAt",
    "Worker"."MainJobStartDateValue",
    "Worker"."MainJobStartDateSavedAt",
    "Worker"."MainJobStartDateChangedAt",
    "Worker"."OtherJobsValue",
    "Worker"."OtherJobsSavedAt",
    "Worker"."OtherJobsChangedAt",
    CASE WHEN "Worker"."NationalInsuranceNumberValue" is not null THEN 'Yes' ELSE "Worker"."NationalInsuranceNumberValue" END AS "NationalInsuranceNumberValue",
    "Worker"."NationalInsuranceNumberSavedAt",
    "Worker"."NationalInsuranceNumberChangedAt",
    date_part('year', age(now(), "Worker"."DateOfBirthValue")) AS "DateOfBirthValue",
    "Worker"."DateOfBirthSavedAt",
    "Worker"."DateOfBirthChangedAt",
    LEFT("PostcodeValue", POSITION(' ' in "PostcodeValue")) AS "PostcodeValue",
    "Worker"."PostcodeSavedAt",
    "Worker"."PostcodeChangedAt",
    "Worker"."DisabilityValue",
    "Worker"."DisabilitySavedAt",
    "Worker"."DisabilityChangedAt",
    "Worker"."GenderValue",
    "Worker"."GenderSavedAt",
    "Worker"."GenderChangedAt",
    "Worker"."EthnicityFKValue",
    "Worker"."EthnicityFKSavedAt",
    "Worker"."EthnicityFKChangedAt",
    "Worker"."NationalityValue",
    "Worker"."NationalityOtherFK",
    "Worker"."NationalitySavedAt",
    "Worker"."NationalityChangedAt",
    "Worker"."CountryOfBirthValue",
    "Worker"."CountryOfBirthOtherFK",
    "Worker"."CountryOfBirthSavedAt",
    "Worker"."CountryOfBirthChangedAt",
    "Worker"."RecruitedFromValue",
    "Worker"."RecruitedFromOtherFK",
    "Worker"."RecruitedFromSavedAt",
    "Worker"."RecruitedFromChangedAt",
    "Worker"."BritishCitizenshipValue",
    "Worker"."BritishCitizenshipSavedAt",
    "Worker"."BritishCitizenshipChangedAt",
    "Worker"."YearArrivedValue",
    "Worker"."YearArrivedYear",
    "Worker"."YearArrivedSavedAt",
    "Worker"."YearArrivedChangedAt",
    "Worker"."SocialCareStartDateValue",
    "Worker"."SocialCareStartDateYear",
    "Worker"."SocialCareStartDateSavedAt",
    "Worker"."SocialCareStartDateChangedAt",
    "Worker"."DaysSickValue",
    "Worker"."DaysSickDays",
    "Worker"."DaysSickSavedAt",
    "Worker"."DaysSickChangedAt",
    "Worker"."ZeroHoursContractValue",
    "Worker"."ZeroHoursContractSavedAt",
    "Worker"."ZeroHoursContractChangedAt",
    "Worker"."WeeklyHoursAverageValue",
    "Worker"."WeeklyHoursAverageHours",
    "Worker"."WeeklyHoursAverageSavedAt",
    "Worker"."WeeklyHoursAverageChangedAt",
    "Worker"."WeeklyHoursContractedValue",
    "Worker"."WeeklyHoursContractedHours",
    "Worker"."WeeklyHoursContractedSavedAt",
    "Worker"."WeeklyHoursContractedChangedAt",
    "Worker"."AnnualHourlyPayValue",
    "Worker"."AnnualHourlyPayRate",
    "Worker"."AnnualHourlyPaySavedAt",
    "Worker"."AnnualHourlyPayChangedAt",
    "Worker"."CareCertificateValue",
    "Worker"."CareCertificateSavedAt",
    "Worker"."CareCertificateChangedAt",
    "Worker"."ApprenticeshipTrainingValue",
    "Worker"."ApprenticeshipTrainingSavedAt",
    "Worker"."ApprenticeshipTrainingChangedAt",
    "Worker"."QualificationInSocialCareValue",
    "Worker"."QualificationInSocialCareSavedAt",
    "Worker"."QualificationInSocialCareChangedAt",
    "Worker"."SocialCareQualificationFKValue",
    "Worker"."SocialCareQualificationFKSavedAt",
    "Worker"."SocialCareQualificationFKChangedAt",
    "Worker"."OtherQualificationsValue",
    "Worker"."OtherQualificationsSavedAt",
    "Worker"."OtherQualificationsChangedAt",
    "Worker"."HighestQualificationFKValue",
    "Worker"."HighestQualificationFKSavedAt",
    "Worker"."HighestQualificationFKChangedAt",
    "Worker"."CompletedValue",
    "Worker"."CompletedSavedAt",
    "Worker"."CompletedChangedAt",
    "Worker"."Archived",
    "Worker"."LeaveReasonFK",
    "Worker"."LeaveReasonOther",
    "Worker".created AS "WorkerCreated",
    "Worker".updated As "WorkerUpdated"
  from
    cqc."Establishment"
		LEFT JOIN cqc."Worker" ON "Establishment"."EstablishmentID" = "Worker"."EstablishmentFK"
		LEFT JOIN
			(SELECT
				"Establishment"."EstablishmentID" "EstablishmentID",
				sum(case when "JobType" = 'Vacancies' then "Total" end) "TotalVacancies",
				sum(case when "JobType" = 'Starters' then "Total" end) "TotalStarters",
				sum(case when "JobType" = 'Leavers' then "Total" end) "TotalLeavers"
			FROM cqc."EstablishmentJobs", cqc."Establishment",cqc."User"
			WHERE "Establishment"."EstablishmentID" = "EstablishmentJobs"."EstablishmentID" and "Establishment"."EstablishmentID"="User"."EstablishmentID"
			GROUP BY "Establishment"."EstablishmentID") "VacanciesStartersLeavers" ON "Establishment"."EstablishmentID" = "VacanciesStartersLeavers"."EstablishmentID" 
  ORDER BY "Establishment"."EstablishmentID", "WorkerUpdated";

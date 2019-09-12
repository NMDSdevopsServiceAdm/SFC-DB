-- https://trello.com/c/UsiGWFJU

DROP TABLE IF EXISTS cqc."LocalAuthorityReportEstablishment";
CREATE TABLE cqc."LocalAuthorityReportEstablishment" (
	"ID" SERIAL NOT NULL PRIMARY KEY,
	"ReportFrom" DATE NOT NULL,
	"ReportTo" DATE NOT NULL,
	"EstablishmentFK" INTEGER NOT NULL,
	"WorkplaceFK" INTEGER NOT NULL,
	"WorkplaceName" TEXT NOT NULL,
	"WorkplaceID" TEXT NOT NULL,
	"LastUpdatedDate" DATE NOT NULL,
	"EstablishmentType" TEXT NOT NULL,
	"MainService" TEXT NOT NULL,
	"ServiceUserGroups" TEXT NOT NULL,
	"CapacityOfMainService" TEXT NOT NULL,
	"UtilisationOfMainService" TEXT NOT NULL,
	"NumberOfVacancies" TEXT NOT NULL,
	"NumberOfStarters" TEXT NOT NULL,
	"NumberOfLeavers" TEXT NOT NULL,
	"NumberOfStaffRecords" TEXT NOT NULL,
	"WorkplaceComplete" BOOLEAN NULL,							-- a null value is equivalent to N/A
	"NumberOfIndividualStaffRecords" TEXT NOT NULL,
	"PercentageOfStaffRecords" NUMERIC(10,1) NOT NULL,
	"NumberOfStaffRecordsNotAgency" INTEGER NOT NULL,
	"NumberOfCompleteStaffNotAgency" INTEGER NOT NULL,
	"PercentageOfCompleteStaffRecords" NUMERIC(10,1) NOT NULL,
	"NumberOfAgencyStaffRecords" INTEGER NOT NULL,
	"NumberOfCompleteAgencyStaffRecords" INTEGER NOT NULL,
	"PercentageOfCompleteAgencyStaffRecords" NUMERIC(10,1) NOT NULL,
	CONSTRAINT "EstablishmentFK_WorkplaceID" UNIQUE ("EstablishmentFK", "WorkplaceID")
);
CREATE INDEX LocalAuthorityReportEstablishment_EstablishmentFK on cqc."LocalAuthorityReportEstablishment" ("EstablishmentFK");

-- intentionally not using foreign key constraints - although the worker records relate to the establishment records; they used separately
DROP TABLE IF EXISTS cqc."LocalAuthorityReportWorker";
CREATE TABLE cqc."LocalAuthorityReportWorker" (
	"ID" SERIAL NOT NULL PRIMARY KEY,
	"EstablishmentFK" INTEGER NOT NULL,
	"WorkplaceFK" INTEGER NOT NULL,
	"WorkerFK" INTEGER NOT NULL,
	"LocalID" TEXT,
	"WorkplaceName" TEXT NOT NULL,
	"WorkplaceID" TEXT NOT NULL,
	"Gender" TEXT NOT NULL,
	"DateOfBirth" TEXT NOT NULL,
	"Ethnicity" TEXT NOT NULL,
	"MainJob" TEXT NOT NULL,
	"EmploymentStatus" TEXT NOT NULL,
	"ContractedAverageHours" TEXT NOT NULL,
	"SickDays" TEXT NOT NULL,
	"PayInterval" TEXT NOT NULL,
	"RateOfPay" TEXT NOT NULL,
	"RelevantSocialCareQualification" TEXT NOT NULL,
	"HighestSocialCareQualification" TEXT NOT NULL,
	"NonSocialCareQualification" TEXT NOT NULL,
	"LastUpdated" DATE NOT NULL,
	"StaffRecordComplete" BOOLEAN NOT NULL,
	CONSTRAINT "EstablishmentFK_WorkerFK" UNIQUE ("EstablishmentFK", "WorkerFK")
);
CREATE INDEX LocalAuthorityReportWorker_EstablishmentFK on cqc."LocalAuthorityReportWorker" ("EstablishmentFK");
CREATE INDEX LocalAuthorityReportWorker_WorkerFK on cqc."LocalAuthorityReportWorker" ("WorkerFK");

-- only run these on dev, staging and accessibility/demo databases
-- GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE cqc."LocalAuthorityReportEstablishment" TO "Sfc_App_Role";
-- GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE cqc."LocalAuthorityReportEstablishment" TO "Sfc_Admin_Role";
-- GRANT ALL ON TABLE cqc."LocalAuthorityReportEstablishment" TO sfcadmin;
-- GRANT INSERT, SELECT, UPDATE ON TABLE cqc."LocalAuthorityReportEstablishment" TO "Read_Update_Role";
-- GRANT SELECT ON TABLE cqc."LocalAuthorityReportEstablishment" TO "Read_Only_Role";

-- GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE cqc."LocalAuthorityReportWorker" TO "Sfc_App_Role";
-- GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE cqc."LocalAuthorityReportWorker" TO "Sfc_Admin_Role";
-- GRANT ALL ON TABLE cqc."LocalAuthorityReportWorker" TO sfcadmin;
-- GRANT INSERT, SELECT, UPDATE ON TABLE cqc."LocalAuthorityReportWorker" TO "Read_Update_Role";
-- GRANT SELECT ON TABLE cqc."LocalAuthorityReportWorker" TO "Read_Only_Role";

---GRANT SELECT,USAGE ON SEQUENCE cqc."LocalAuthorityReportEstablishment_ID_seq" TO sfcapp;
-- GRANT SELECT,USAGE ON SEQUENCE cqc."LocalAuthorityReportWorker_ID_seq" TO sfcapp;

DROP FUNCTION IF EXISTS cqc.localAuthorityReportEstablishment;
CREATE OR REPLACE FUNCTION cqc.localAuthorityReportEstablishment(establishmentID INTEGER, reportFrom DATE, reportTo DATE)
 RETURNS BOOLEAN 
AS $$
DECLARE
	success BOOLEAN;
	v_error_msg TEXT;
	v_error_stack TEXT;
	AllEstablishments REFCURSOR;
	CurrentEstablishment RECORD;
	CalculatedEmployerType TEXT;
	CalculatedServiceUserGroups TEXT;
	CalculatedCapacity TEXT;
	CalculatedUtilisation TEXT;
	CalculatedVacancies TEXT;
	CalculatedStarters TEXT;
	CalculatedLeavers TEXT;
	CalculatedNumberOfStaff TEXT;
	CalculatedNumberOfStaffInt INTEGER;
	CalculatedWorkplaceComplete BOOLEAN;
BEGIN
	success := true;
	
	RAISE NOTICE 'localAuthorityReportEstablishment (%) from % to %', establishmentID, reportFrom, reportTo;
	
	OPEN AllEstablishments FOR
	SELECT
		"Establishment"."EstablishmentID",
		"NmdsID",
		"NameValue",
		"EmployerTypeValue",
		"EmployerTypeSavedAt",
		MainService.name AS "MainService",
		"MainServiceFKValue",
		"MainServiceFKSavedAt",
		(select count(0) from cqc."EstablishmentServiceUsers" where "EstablishmentServiceUsers"."EstablishmentID" = "Establishment"."EstablishmentID") AS "ServiceUsersCount",
		"ServiceUsersSavedAt",
		"VacanciesValue",
		(select sum("Total") from cqc."EstablishmentJobs" where "EstablishmentJobs"."EstablishmentID" = "Establishment"."EstablishmentID" AND "EstablishmentJobs"."JobType" = 'Vacancies') AS "Vacancies",
		"VacanciesSavedAt",
		"StartersValue",
		(select sum("Total") from cqc."EstablishmentJobs" where "EstablishmentJobs"."EstablishmentID" = "Establishment"."EstablishmentID" AND "EstablishmentJobs"."JobType" = 'Starters') AS "Starters",
		"StartersSavedAt",
		"LeaversValue",
		(select sum("Total") from cqc."EstablishmentJobs" where "EstablishmentJobs"."EstablishmentID" = "Establishment"."EstablishmentID" AND "EstablishmentJobs"."JobType" = 'Leavers') AS "Leavers",
		"LeaversSavedAt",
		"NumberOfStaffValue",
		"NumberOfStaffSavedAt",
		"EstablishmentMainServicesWithCapacitiesVW"."CAPACITY" AS "Capacities",
		"EstablishmentMainServicesWithCapacitiesVW"."UTILISATION" AS "Utilisations",
		"CapacityServicesSavedAt",
		"NumberOfStaffValue",
		"NumberOfStaffSavedAt",
		updated,
		to_char(updated, 'DD/MM/YYYY') AS lastupdateddate,
		"NumberOfIndividualStaffRecords",
		"NumberOfStaffRecordsNotAgency",
		"NumberOfAgencyStaffRecords",
		"NumberOfStaffRecordsNotAgencyCompleted",
		"NumberOfAgencyStaffRecordsCompleted"
    FROM
      cqc."Establishment"
	  	LEFT JOIN cqc.services as MainService on "Establishment"."MainServiceFKValue" = MainService.id
		LEFT JOIN cqc."EstablishmentMainServicesWithCapacitiesVW" on "EstablishmentMainServicesWithCapacitiesVW"."EstablishmentID" = "Establishment"."EstablishmentID"
		LEFT JOIN (
			SELECT
				"EstablishmentFK",
				"WorkplaceFK",
				count("LocalAuthorityReportWorker"."WorkerFK") AS "NumberOfIndividualStaffRecords",
				count("LocalAuthorityReportWorker"."WorkerFK") FILTER (WHERE "LocalAuthorityReportWorker"."EmploymentStatus" not in ('Agency')) AS "NumberOfStaffRecordsNotAgency",
				count("LocalAuthorityReportWorker"."WorkerFK") FILTER (WHERE "LocalAuthorityReportWorker"."EmploymentStatus" not in ('Agency') AND "LocalAuthorityReportWorker"."StaffRecordComplete" = true) AS "NumberOfStaffRecordsNotAgencyCompleted",
				count("LocalAuthorityReportWorker"."WorkerFK") FILTER (WHERE "LocalAuthorityReportWorker"."EmploymentStatus" in ('Agency')) AS "NumberOfAgencyStaffRecords",
				count("LocalAuthorityReportWorker"."WorkerFK") FILTER (WHERE "LocalAuthorityReportWorker"."EmploymentStatus" in ('Agency') AND "LocalAuthorityReportWorker"."StaffRecordComplete" = true) AS "NumberOfAgencyStaffRecordsCompleted"
			FROM cqc."LocalAuthorityReportWorker"
			WHERE
				"LocalAuthorityReportWorker"."EstablishmentFK" = establishmentID
			GROUP BY
				"EstablishmentFK", "WorkplaceFK"
		) "EstablishmentWorkers" ON "EstablishmentWorkers"."WorkplaceFK" = "Establishment"."EstablishmentID"
    WHERE
		("Establishment"."EstablishmentID" = establishmentID OR "Establishment"."ParentID" = establishmentID) AND
		"Archived" = false
	ORDER BY
		"EstablishmentID";
		
	LOOP
		FETCH AllEstablishments INTO CurrentEstablishment;
		EXIT WHEN NOT FOUND;
		
		-- RAISE NOTICE 'localAuthorityReportEstablishment: %, %, %, %, %, % %',
		-- 	CurrentEstablishment."EstablishmentID",
		-- 	CurrentEstablishment."NmdsID",
		-- 	CurrentEstablishment."NameValue",
		-- 	CurrentEstablishment.lastupdateddate,
		-- 	CurrentEstablishment."EmployerTypeValue",
		-- 	CurrentEstablishment."MainServiceFKValue",
		-- 	CurrentEstablishment."MainService";
		
		-- 16 is Head ofice services
		IF CurrentEstablishment."MainServiceFKValue" = 16 THEN
			CalculatedServiceUserGroups := 'n/a';
		ELSIF CurrentEstablishment."MainServiceFKValue" <> 16 AND CurrentEstablishment."ServiceUsersCount" > 0 THEN
			CalculatedServiceUserGroups := 'Completed';
		ELSE
			CalculatedServiceUserGroups := 'Missing';
		END IF;
		
		IF CurrentEstablishment."Capacities" = -1 THEN
			CalculatedCapacity := 'Missing';
		ELSIF CurrentEstablishment."Capacities" IS NULL THEN
			CalculatedCapacity := 'n/a';
		ELSE
			CalculatedCapacity := CurrentEstablishment."Capacities"::TEXT;
		END IF;
		IF CurrentEstablishment."Utilisations" = -1 THEN
			CalculatedUtilisation := 'Missing';
		ELSIF CurrentEstablishment."Utilisations" IS NULL THEN
			CalculatedUtilisation := 'n/a';
		ELSE
			CalculatedUtilisation := CurrentEstablishment."Utilisations"::TEXT;
		END IF;
		
		IF CurrentEstablishment."VacanciesValue" IS NOT NULL AND CurrentEstablishment."VacanciesValue" = 'With Jobs' THEN
			CalculatedVacancies := CurrentEstablishment."Vacancies"::TEXT;
		ELSIF CurrentEstablishment."VacanciesValue" IS NULL THEN
			CalculatedVacancies := 'Missing';
		ELSE
			CalculatedVacancies := 0;
		END IF;

		IF CurrentEstablishment."StartersValue" IS NOT NULL AND CurrentEstablishment."StartersValue" = 'With Jobs' THEN
			CalculatedStarters := CurrentEstablishment."Starters"::TEXT;
		ELSIF CurrentEstablishment."StartersValue" IS NULL THEN
			CalculatedStarters := 'Missing';
		ELSE
			CalculatedStarters := 0;
		END IF;

		IF CurrentEstablishment."LeaversValue" IS NOT NULL AND CurrentEstablishment."LeaversValue" = 'With Jobs' THEN
			CalculatedLeavers := CurrentEstablishment."Leavers"::TEXT;
		ELSIF CurrentEstablishment."LeaversValue" IS NULL THEN
			CalculatedLeavers := 'Missing';
		ELSE
			CalculatedLeavers := 0;
		END IF;

		
		IF CurrentEstablishment."NumberOfStaffValue" IS NOT NULL THEN
			CalculatedNumberOfStaff := CurrentEstablishment."NumberOfStaffValue"::TEXT;
			CalculatedNumberOfStaffInt := CurrentEstablishment."NumberOfStaffValue";
		ELSE
			CalculatedNumberOfStaff := 'Missing';
		END IF;
		
		IF CurrentEstablishment."EmployerTypeValue" IS NOT NULL THEN
			CalculatedEmployerType := CurrentEstablishment."EmployerTypeValue";
		ELSE
			CalculatedEmployerType := 'Missing';
		END IF;
		
		-- calculated the workplace "completed" flag is only true if:
		-- 1. The establishment type is one of Local Authority
		-- 2. The main service is known
		-- 3. The service user group is not -99 (n/a and completed are acceptable)
		-- 4. If the capacity of main service is not -99 (NULL is acceptable as is 0 or more)
		-- 5. If the utilisation of main service is not -99 (NULL is acceptable as is 0 or more)
		-- 6. If number of staff is not -99 (0 or more is acceptable)
		-- 7. If vacancies is not -99 (0 or more is acceptable)
		-- 8. If starters is not -99 (0 or more is acceptable)
		-- 9. If leavers is not -99 (0 or more is acceptable)
		CalculatedWorkplaceComplete := true;
		IF CurrentEstablishment.updated::DATE < reportFrom THEN
			-- RAISE NOTICE 'Establishment record not been updated';
			CalculatedWorkplaceComplete := false;
		END IF;

		IF SUBSTRING(CalculatedEmployerType::text from 1 for 15) <> 'Local Authority' THEN
			-- RAISE NOTICE 'employer type is NOT local authority: %', SUBSTRING(CalculatedEmployerType::text from 1 for 15);
			CalculatedWorkplaceComplete := false;
		END IF;
		
		IF CalculatedServiceUserGroups = 'Missing' THEN
			-- RAISE NOTICE 'calculated service groups is NOT valid: %', CalculatedServiceUserGroups;
			CalculatedWorkplaceComplete := false;
		END IF;
		
		IF CalculatedCapacity = 'Missing' THEN
			-- RAISE NOTICE 'calculated capacity is NOT valid: %', CalculatedCapacity;
			CalculatedWorkplaceComplete := false;
		END IF;
		
		IF CalculatedUtilisation = 'Missing' THEN
			-- RAISE NOTICE 'calculated utilisation is NOT valid: %', CalculatedUtilisation;
			CalculatedWorkplaceComplete := false;
		END IF;
		
		IF CalculatedNumberOfStaff = 'Missing' THEN
			-- RAISE NOTICE 'calculated number of staff is NOT valid: %', CalculatedNumberOfStaff;
			CalculatedWorkplaceComplete := false;
		END IF;
		
		IF CalculatedVacancies = 'Missing' THEN
			-- RAISE NOTICE 'calculated vacancies is NOT valid: %', CalculatedVacancies;
			CalculatedWorkplaceComplete := false;
		END IF;
		IF CalculatedStarters = 'Missing' THEN
			-- RAISE NOTICE 'calculated starters is NOT valid: %', CalculatedStarters;
			CalculatedWorkplaceComplete := false;
		END IF;
		IF CalculatedLeavers = 'Missing' THEN
			-- RAISE NOTICE 'calculated leavers is NOT valid: %', CalculatedLeavers;
			CalculatedWorkplaceComplete := false;
		END IF;

		INSERT INTO cqc."LocalAuthorityReportEstablishment" (
			"ReportFrom",
			"ReportTo",
			"EstablishmentFK",
			"WorkplaceFK",
			"WorkplaceName",
			"WorkplaceID",
			"LastUpdatedDate",
			"EstablishmentType",
			"MainService",
			"ServiceUserGroups",
			"CapacityOfMainService",
			"UtilisationOfMainService",
			"NumberOfVacancies",
			"NumberOfStarters",
			"NumberOfLeavers",
			"NumberOfStaffRecords",
			"WorkplaceComplete",
			"NumberOfIndividualStaffRecords",
			"PercentageOfStaffRecords",
			"NumberOfStaffRecordsNotAgency",
			"NumberOfCompleteStaffNotAgency",
			"PercentageOfCompleteStaffRecords",
			"NumberOfAgencyStaffRecords",
			"NumberOfCompleteAgencyStaffRecords",
			"PercentageOfCompleteAgencyStaffRecords"
		) VALUES (
			reportFrom,
			reportTo,
			establishmentID,
			CurrentEstablishment."EstablishmentID",
			CurrentEstablishment."NameValue",
			CurrentEstablishment."NmdsID",
			CurrentEstablishment.updated::DATE,
			CalculatedEmployerType,
			CurrentEstablishment."MainService",
			CalculatedServiceUserGroups,
			CalculatedCapacity,
			CalculatedUtilisation,
			CalculatedVacancies,
			CalculatedStarters,
			CalculatedLeavers,
			CalculatedNumberOfStaff,
			CalculatedWorkplaceComplete,
			CASE WHEN CurrentEstablishment."NumberOfIndividualStaffRecords" IS NOT NULL THEN CurrentEstablishment."NumberOfIndividualStaffRecords" ELSE 0 END,
			CASE WHEN CalculatedNumberOfStaff <> 'Missing' AND CurrentEstablishment."NumberOfIndividualStaffRecords" IS NOT NULL AND CalculatedNumberOfStaffInt::NUMERIC > 0 THEN ((CurrentEstablishment."NumberOfIndividualStaffRecords"::NUMERIC / CalculatedNumberOfStaffInt::NUMERIC) * 100.0)::NUMERIC(10,1) ELSE 0.00::NUMERIC END,
			CASE WHEN CurrentEstablishment."NumberOfStaffRecordsNotAgency" IS NOT NULL THEN CurrentEstablishment."NumberOfStaffRecordsNotAgency" ELSE 0 END,
			CASE WHEN CurrentEstablishment."NumberOfStaffRecordsNotAgencyCompleted" IS NOT NULL THEN CurrentEstablishment."NumberOfStaffRecordsNotAgencyCompleted" ELSE 0 END,
			CASE WHEN CurrentEstablishment."NumberOfStaffRecordsNotAgency" > 0 AND CurrentEstablishment."NumberOfStaffRecordsNotAgency" IS NOT NULL AND CurrentEstablishment."NumberOfStaffRecordsNotAgencyCompleted" IS NOT NULL THEN ((CurrentEstablishment."NumberOfStaffRecordsNotAgencyCompleted"::NUMERIC / CurrentEstablishment."NumberOfStaffRecordsNotAgency"::NUMERIC) * 100.0)::NUMERIC(10,1) ELSE 0.0::NUMERIC END,
			CASE WHEN CurrentEstablishment."NumberOfAgencyStaffRecords" IS NOT NULL THEN CurrentEstablishment."NumberOfAgencyStaffRecords" ELSE 0 END,
			CASE WHEN CurrentEstablishment."NumberOfAgencyStaffRecordsCompleted" IS NOT NULL THEN CurrentEstablishment."NumberOfAgencyStaffRecordsCompleted" ELSE 0 END,
			CASE WHEN CurrentEstablishment."NumberOfAgencyStaffRecords" > 0 AND CurrentEstablishment."NumberOfAgencyStaffRecords" IS NOT NULL AND CurrentEstablishment."NumberOfAgencyStaffRecordsCompleted" IS NOT NULL THEN ((CurrentEstablishment."NumberOfAgencyStaffRecordsCompleted"::NUMERIC / CurrentEstablishment."NumberOfAgencyStaffRecords"::NUMERIC) * 100.0)::NUMERIC ELSE 0.0::NUMERIC(10,1) END
		);
		
	END LOOP;

	RETURN success;
	
	EXCEPTION WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS v_error_stack=PG_EXCEPTION_CONTEXT, v_error_msg=MESSAGE_TEXT;
		RAISE WARNING 'localAuthorityReportWorker: %: %', v_error_msg, v_error_stack;
		RETURN false;

END; $$
LANGUAGE 'plpgsql';


DROP FUNCTION IF EXISTS cqc.localAuthorityReportWorker;
CREATE OR REPLACE FUNCTION cqc.localAuthorityReportWorker(establishmentID INTEGER, reportFrom DATE, reportTo DATE)
 RETURNS BOOLEAN 
AS $$
DECLARE
	success BOOLEAN;
	v_error_msg TEXT;
	v_error_stack TEXT;
	AllWorkers REFCURSOR;
	CurrentWorker RECORD;
	CalculatedGender TEXT;
	CalculatedDateOfBirth TEXT;
	CalculatedEthnicity TEXT;
	CalculatedMainJobRole TEXT;
	CalculatedEmploymentStatus TEXT;
	CalculatedSickDays TEXT;
	CalculatedPayInterval TEXT;
	CalculatedPayRate TEXT;
	CalculatedRelevantSocialCareQualification TEXT;
	CalculatedHighestSocialCareQualification TEXT;
	CalculatedNonSocialCareQualification TEXT;
	CalculatedContractedAverageHours TEXT;
	CalculatedStaffComplete BOOLEAN := true;
BEGIN
	success := true;
	
	RAISE NOTICE 'localAuthorityReportWorker (%) from % to %', establishmentID, reportFrom, reportTo;
	
	OPEN AllWorkers FOR
	SELECT
	  "Establishment"."EstablishmentID" AS "WorkplaceFK",
		"Establishment"."NameValue" AS "WorkplaceName",
		"Establishment"."NmdsID" AS "WorkplaceID",
		"Worker".updated,
		"Worker"."ID" AS "WorkerID",
		"Worker"."NameOrIdValue",
		"Worker"."GenderValue",
		"Worker"."GenderSavedAt",
		"Worker"."DateOfBirthValue",
		"Worker"."DateOfBirthSavedAt",
		"Ethnicity"."Ethnicity" AS "Ethnicity",
		"Worker"."EthnicityFKValue",
		"Worker"."EthnicityFKSavedAt",
		"Job"."JobName" AS "MainJobRole",
		"Worker"."MainJobFKValue",
		"Worker"."MainJobFKSavedAt",
		"ContractValue",
		"ContractSavedAt",
		"WeeklyHoursContractedValue",
		"WeeklyHoursContractedHours",
		"WeeklyHoursContractedSavedAt",
		"WeeklyHoursAverageValue",
		"WeeklyHoursAverageHours",
		"WeeklyHoursAverageSavedAt",
		"ZeroHoursContractValue",
		"ZeroHoursContractSavedAt",
		"DaysSickValue",
		"DaysSickDays",
		"DaysSickSavedAt",
		"AnnualHourlyPayValue",
		"AnnualHourlyPayRate",
		"AnnualHourlyPaySavedAt",
		"QualificationInSocialCareValue",
		"QualificationInSocialCareSavedAt",
		"Qualification"."Level" AS "QualificationInSocialCare",
		"SocialCareQualificationFKValue",
		"SocialCareQualificationFKSavedAt",
		"OtherQualificationsValue",
		"OtherQualificationsSavedAt"
	FROM cqc."Worker"
		INNER JOIN cqc."Establishment" on "Establishment"."EstablishmentID" = "Worker"."EstablishmentFK" AND "Establishment"."Archived" = false AND ("Establishment"."EstablishmentID" = establishmentID OR "Establishment"."ParentID" = establishmentID)
		LEFT JOIN cqc."Ethnicity" on "Worker"."EthnicityFKValue" = "Ethnicity"."ID"
		LEFT JOIN cqc."Job" on "Worker"."MainJobFKValue" = "Job"."JobID"
		LEFT JOIN cqc."Qualification" on "Worker"."SocialCareQualificationFKValue" = "Qualification"."ID"
	WHERE
		"Worker"."Archived" = false;

	LOOP
		FETCH AllWorkers INTO CurrentWorker;
		EXIT WHEN NOT FOUND;
		
		-- RAISE NOTICE 'localAuthorityReportWorker: %, %, %, %, %, % %',
		-- 	CurrentWorker."NameOrIdValue",
		-- 	CurrentWorker."Ethnicity",
		-- 	CurrentWorker."GenderValue",
		-- 	CurrentWorker.updated,
		-- 	CurrentWorker."ContractValue",
		-- 	CurrentWorker."AnnualHourlyPayRate",
		-- 	CurrentWorker."AnnualHourlyPayRate";
		
		IF CurrentWorker."GenderSavedAt" IS NULL THEN
			CalculatedGender := 'Missing';
		ELSE
			CalculatedGender := CurrentWorker."GenderValue"::TEXT;
		END IF;
		
		IF CurrentWorker."DateOfBirthSavedAt" IS NULL THEN
			CalculatedDateOfBirth := 'Missing';
		ELSE
			CalculatedDateOfBirth := TO_CHAR(CurrentWorker."DateOfBirthValue", 'DD/MM/YYYY');
		END IF;

		IF CurrentWorker."EthnicityFKSavedAt" IS NULL THEN
			CalculatedEthnicity := 'Missing';
		ELSE
			CalculatedEthnicity := CurrentWorker."Ethnicity";
		END IF;
		
		IF CurrentWorker."MainJobFKSavedAt" IS NULL THEN
			CalculatedMainJobRole := 'Missing';
		ELSE
			CalculatedMainJobRole := CurrentWorker."MainJobRole";
		END IF;

		IF CurrentWorker."ContractValue" IS NULL THEN
			CalculatedEmploymentStatus := 'Missing';
		ELSE
			CalculatedEmploymentStatus := CurrentWorker."ContractValue";
		END IF;
		
		IF CurrentWorker."DaysSickValue" IS NULL THEN
			CalculatedSickDays := 'Missing';
		ELSE
			IF CurrentWorker."DaysSickValue" = 'Yes' THEN
				IF CurrentWorker."DaysSickDays" IS NOT NULL THEN
					CalculatedSickDays = CurrentWorker."DaysSickDays"::TEXT;
				ELSE
					CalculatedSickDays = 'Missing';
				END IF;
			ELSIF CurrentWorker."DaysSickValue" = 'No' THEN
				CalculatedSickDays := 'Don''t know';
			ELSE
				CalculatedSickDays := CurrentWorker."DaysSickValue";
			END IF;
		END IF;
		
		IF CurrentWorker."AnnualHourlyPayValue" IS NOT NULL THEN
			CalculatedPayInterval := CurrentWorker."AnnualHourlyPayValue";

			IF CurrentWorker."AnnualHourlyPayRate" IS NULL OR CurrentWorker."AnnualHourlyPayValue" = 'Don''t know' THEN
				CalculatedPayRate := 'Missing';
			ELSE
				CalculatedPayRate := CurrentWorker."AnnualHourlyPayRate";
			END IF;
		ELSE
			CalculatedPayRate := 'Missing';
			CalculatedPayInterval := 'Missing';
		END IF;
		
		IF CurrentWorker."QualificationInSocialCareValue" IS NOT NULL THEN
			CalculatedRelevantSocialCareQualification := CurrentWorker."QualificationInSocialCareValue";
		
			-- the highest social care qualification level is only relevant if knowing the qualification in social care
			IF CurrentWorker."QualificationInSocialCareValue" = 'Yes' THEN
				IF CurrentWorker."QualificationInSocialCare" IS NOT NULL THEN
					CalculatedHighestSocialCareQualification := CurrentWorker."QualificationInSocialCare";
				ELSE
					CalculatedHighestSocialCareQualification := 'Missing';
				END IF;
			ELSE
				CalculatedHighestSocialCareQualification := 'n/a';
			END IF;
		ELSE
			CalculatedRelevantSocialCareQualification := 'Missing';
			CalculatedHighestSocialCareQualification := 'Missing';
		END IF;

		-- a social worker (27) and an occupational therapist (18) must both have qualifications relevant to social care - override the default checks
		IF CurrentWorker."MainJobFKValue" IS NOT NULL and CurrentWorker."MainJobFKValue" in (18,27) THEN
			IF CurrentWorker."QualificationInSocialCareValue" IS NULL OR CurrentWorker."QualificationInSocialCareValue" <> 'Yes' THEN
				CalculatedRelevantSocialCareQualification := 'Must be yes';
			END IF;
			IF CurrentWorker."QualificationInSocialCare" IS NULL THEN
				CalculatedRelevantSocialCareQualification := 'Must be yes';
			END IF;
		END IF;
		
		IF CurrentWorker."OtherQualificationsSavedAt" IS NULL THEN
			CalculatedNonSocialCareQualification := 'Missing';
		ELSE
			CalculatedNonSocialCareQualification := CurrentWorker."OtherQualificationsValue";
		END IF;
		
		-- if contract type is perm/temp contracted hours else average hours
		IF CurrentWorker."ContractValue" in ('Permanent', 'Temporary') THEN
			-- if zero hours contractor, then use average hours not contracted hours
			IF CurrentWorker."ZeroHoursContractValue" IS NOT NULL AND CurrentWorker."ZeroHoursContractValue" = 'Yes' THEN
				IF  CurrentWorker."ZeroHoursContractValue" = 'Yes' AND CurrentWorker."WeeklyHoursAverageHours" IS NOT NULL THEN
					CalculatedContractedAverageHours := CurrentWorker."WeeklyHoursAverageHours"::TEXT;
				ELSIF CurrentWorker."ZeroHoursContractValue" = 'No' THEN
					CalculatedContractedAverageHours := 'Don''t know';
				ELSE
					CalculatedContractedAverageHours := 'Missing';
				END IF;
			ELSE
				IF CurrentWorker."WeeklyHoursContractedValue" = 'Yes' AND CurrentWorker."WeeklyHoursContractedHours" IS NOT NULL THEN
					CalculatedContractedAverageHours := CurrentWorker."WeeklyHoursContractedHours" ;
				ELSIF CurrentWorker."WeeklyHoursContractedValue" = 'No' THEN
					CalculatedContractedAverageHours := 'Don''t know';
				ELSE
					CalculatedContractedAverageHours := 'Missing';
				END IF;
			END IF;
		ELSE
				IF  CurrentWorker."WeeklyHoursAverageValue" = 'Yes' AND CurrentWorker."WeeklyHoursAverageHours" IS NOT NULL THEN
					CalculatedContractedAverageHours := CurrentWorker."WeeklyHoursAverageHours"::TEXT;
				ELSIF CurrentWorker."WeeklyHoursAverageValue" = 'No' THEN
					CalculatedContractedAverageHours := 'Don''t know';
				ELSE
					CalculatedContractedAverageHours := 'Missing';
				END IF;
		END IF;
		IF CalculatedContractedAverageHours IS NULL THEN
			CalculatedContractedAverageHours := 'Missing';
		END IF;
		
		-- now calculate worker completion - which for an agency worker only includes just contracted/average hours, main job and the two salary fields
		CalculatedStaffComplete := true;
		IF CurrentWorker.updated::DATE < reportFrom THEN
			-- RAISE NOTICE 'Worker record not been updated';
			CalculatedStaffComplete := false;
		END IF;
		IF CalculatedEmploymentStatus <> 'Agency' AND CalculatedGender in ('Missing')  THEN
			-- RAISE NOTICE 'calculated gender is NOT valid: %', CalculatedGender;
			CalculatedStaffComplete := false;
		END IF;

		IF CalculatedEmploymentStatus <> 'Agency' AND CalculatedDateOfBirth in ('Missing')  THEN
			-- RAISE NOTICE 'calculated date of birth is NOT valid: %', CalculatedDateOfBirth;
			CalculatedStaffComplete := false;
		END IF;
		
		IF CalculatedEmploymentStatus <> 'Agency' AND CalculatedEthnicity in ('Missing')  THEN
			-- RAISE NOTICE 'calculated ethnicity is NOT valid: %', CalculatedEthnicity;
			CalculatedStaffComplete := false;
		END IF;

		IF CalculatedMainJobRole in ('Missing')  THEN
			-- RAISE NOTICE 'calculated main job role is NOT valid: %', CalculatedMainJobRole;
			CalculatedStaffComplete := false;
		END IF;
		
		IF CalculatedEmploymentStatus in ('Missing')  THEN
			-- RAISE NOTICE 'calculated contract is NOT valid: %', CalculatedEmploymentStatus;
			CalculatedStaffComplete := false;
		END IF;

		IF CalculatedEmploymentStatus <> 'Agency' AND CalculatedSickDays in ('Missing')  THEN
			-- RAISE NOTICE 'calculated days sick is NOT valid: %', CalculatedSickDays;
			CalculatedStaffComplete := false;
		END IF;
		
		IF CalculatedPayInterval in ('Missing')  THEN
			-- RAISE NOTICE 'calculated pay interval is NOT valid: %', CalculatedPayInterval;
			CalculatedStaffComplete := false;
		END IF;
		
		IF CalculatedPayRate in ('Missing')  THEN
			-- RAISE NOTICE 'calculated pay rate is NOT valid: %', CalculatedPayRate;
			CalculatedStaffComplete := false;
		END IF;
		
		IF CalculatedEmploymentStatus <> 'Agency' AND CalculatedRelevantSocialCareQualification in ('Missing', 'Must be yes')  THEN
			-- RAISE NOTICE 'calculated relevant social care qualification is NOT valid: %', CalculatedRelevantSocialCareQualification;
			CalculatedStaffComplete := false;
		END IF;
		
		IF CalculatedEmploymentStatus <> 'Agency' AND CalculatedHighestSocialCareQualification in ('Missing', 'Must be yes')  THEN
			-- RAISE NOTICE 'calculated highest social care qualification is NOT valid: %', CalculatedHighestSocialCareQualification;
			CalculatedStaffComplete := false;
		END IF;
		
		IF CalculatedEmploymentStatus <> 'Agency' AND CalculatedNonSocialCareQualification in ('Missing')  THEN
			-- RAISE NOTICE 'calculated relevant non-social care qualification is NOT valid: %', CalculatedNonSocialCareQualification;
			CalculatedStaffComplete := false;
		END IF;
		
		IF CalculatedContractedAverageHours in ('Missing')  THEN
			-- RAISE NOTICE 'calculated contracted/average hours is NOT valid: %', CalculatedContractedAverageHours;
			CalculatedStaffComplete := false;
		END IF;
		
		INSERT INTO cqc."LocalAuthorityReportWorker" (
			"EstablishmentFK",
			"WorkplaceFK",
			"WorkerFK",
			"LocalID",
			"WorkplaceName",
			"WorkplaceID",
			"Gender",
			"DateOfBirth",
			"Ethnicity",
			"MainJob",
			"EmploymentStatus",
			"ContractedAverageHours",
			"SickDays",
			"PayInterval",
			"RateOfPay",
			"RelevantSocialCareQualification",
			"HighestSocialCareQualification",
			"NonSocialCareQualification",
			"LastUpdated",
			"StaffRecordComplete"
		) VALUES (
			EstablishmentID,
			CurrentWorker."WorkplaceFK",
			CurrentWorker."WorkerID",
			CurrentWorker."NameOrIdValue",
			CurrentWorker."WorkplaceName",
			CurrentWorker."WorkplaceID",
			CalculatedGender,
			CalculatedDateOfBirth,
			CalculatedEthnicity,
			CalculatedMainJobRole,
			CalculatedEmploymentStatus,
			CalculatedContractedAverageHours,
			CalculatedSickDays,
			CalculatedPayInterval,
			CalculatedPayRate,
			CalculatedRelevantSocialCareQualification,
			CalculatedHighestSocialCareQualification,
			CalculatedNonSocialCareQualification,
			CurrentWorker.updated,
			CalculatedStaffComplete
		);
		
	END LOOP;
	
	RETURN success;
	
	EXCEPTION WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS v_error_stack=PG_EXCEPTION_CONTEXT, v_error_msg=MESSAGE_TEXT;
		RAISE WARNING 'localAuthorityReportWorker: %: %', v_error_msg, v_error_stack;
		RETURN false;

END; $$
LANGUAGE 'plpgsql';



DROP FUNCTION IF EXISTS cqc.localAuthorityReport;
CREATE OR REPLACE FUNCTION cqc.localAuthorityReport(establishmentID INTEGER, reportFrom DATE, reportTo DATE)
 RETURNS BOOLEAN 
AS $$
DECLARE
	success BOOLEAN;
	v_error_msg TEXT;
	v_error_stack TEXT;
	establishmentReportStatus BOOLEAN;
	workerReportStatus BOOLEAN;
BEGIN
	success := true;
	
	RAISE NOTICE 'localAuthorityReport (%) from % to %', establishmentID, reportFrom, reportTo;
	
	-- first delete all Local Authority report data related to this establishment
	DELETE FROM cqc."LocalAuthorityReportWorker" WHERE "EstablishmentFK"=establishmentID;
	DELETE FROM cqc."LocalAuthorityReportEstablishment" WHERE "EstablishmentFK"=establishmentID;

	SELECT cqc.localAuthorityReportWorker(establishmentID, reportFrom, reportTo) INTO workerReportStatus;
	SELECT cqc.localAuthorityReportEstablishment(establishmentID, reportFrom, reportTo) INTO establishmentReportStatus;
	
	
	IF NOT (establishmentReportStatus AND workerReportStatus) THEN
		success := false;
	END IF;
	
	RETURN success;
	
	EXCEPTION WHEN OTHERS THEN
		GET STACKED DIAGNOSTICS v_error_stack=PG_EXCEPTION_CONTEXT, v_error_msg=MESSAGE_TEXT;
		RAISE WARNING 'localAuthorityReport: %: %', v_error_msg, v_error_stack;
		RETURN false;

END; $$
LANGUAGE 'plpgsql';


-- for sfcdevdb, sfctstdb
--ALTER FUNCTION cqc.localAuthorityReportWorker(integer, date, date) OWNER TO sfcadmin;
--ALTER FUNCTION cqc.localauthorityreportestablishment(integer, date, date) OWNER TO sfcadmin;
--ALTER FUNCTION cqc.localauthorityreport(integer, date, date) OWNER TO sfcadmin;

--select cqc.localAuthorityReport(1::INTEGER, '2019-09-09'::DATE, '2019-10-11'::DATE);
-- select * from cqc."LocalAuthorityReportEstablishment";
-- select * from cqc."LocalAuthorityReportWorker";
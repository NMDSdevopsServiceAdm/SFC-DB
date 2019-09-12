-- https://trello.com/c/DY3WEj3j - Establishment properties *SavedAt timestamp should be the establishment's or Worker's "updated" timestamp
-- https://trello.com/c/DY3WEj3j - Establishment's Employer Type and Main Service missing *SavedAt timestamp - should be Establishment::updated
-- https://trello.com/c/DY3WEj3j - Worker's Contract Type and Main Job missing *SavedAt timestamp - should be Worker::updated


update
	cqc."Establishment"
set
	"EmployerTypeSavedAt" = (case when "EmployerTypeSavedAt" is null then updated else "EmployerTypeSavedAt" end),
	"EmployerTypeSavedBy" = (case when "EmployerTypeSavedAt" is null then 'migration' else "EmployerTypeSavedBy" end),
	"MainServiceFKSavedAt" = (case when "MainServiceFKSavedAt" is null then updated else "EmployerTypeSavedAt" end),
	"MainServiceFKSavedBy" = (case when "MainServiceFKSavedAt" is null then 'migration' else "EmployerTypeSavedBy" end),
	"NumberOfStaffSavedAt" = (case when "NumberOfStaffSavedBy" = 'migration' then updated else "NumberOfStaffSavedAt" end),
	"OtherServicesSavedAt" = (case when "OtherServicesSavedBy" = 'migration' then updated else "OtherServicesSavedAt" end),
	"CapacityServicesSavedAt" = (case when "CapacityServicesSavedBy" = 'migration' then updated else "CapacityServicesSavedAt" end),
	"ShareDataSavedAt" = (case when "ShareDataSavedBy" = 'migration' then updated else "ShareDataSavedAt" end),
	"ShareWithLASavedAt" = (case when "ShareWithLASavedBy" = 'migration' then updated else "ShareWithLASavedAt" end),
	"VacanciesSavedAt" = (case when "VacanciesSavedBy" = 'migration' then updated else "VacanciesSavedAt" end),
	"StartersSavedAt" = (case when "StartersSavedBy" = 'migration' then updated else "StartersSavedAt" end),
	"LeaversSavedAt" = (case when "LeaversSavedBy" = 'migration' then updated else "LeaversSavedAt" end),
	"ServiceUsersSavedAt" = (case when "ServiceUsersSavedBy" = 'migration' then updated else "ServiceUsersSavedAt" end)
where "TribalID" is not null;

update
	cqc."Worker"
set
	"ContractSavedAt" = (case when "ContractSavedAt" is null then updated else "ContractSavedAt" end),
	"ContractSavedBy" = (case when "ContractSavedAt" is null then 'migration' else "ContractSavedBy" end),
	"MainJobFKSavedAt" = (case when "MainJobFKSavedAt" is null then updated else "MainJobFKSavedAt" end),
	"MainJobFKSavedBy" = (case when "MainJobFKSavedAt" is null then 'migration' else "MainJobFKSavedBy" end),
	"NameOrIdSavedAt" = (case when "NameOrIdSavedBy" = 'migration' then updated else "NameOrIdSavedAt" end),
	"ApprovedMentalHealthWorkerSavedAt" = (case when "ApprovedMentalHealthWorkerSavedBy" = 'migration' then updated else "ApprovedMentalHealthWorkerSavedAt" end),
	"MainJobStartDateSavedAt" = (case when "MainJobStartDateSavedBy" = 'migration' then updated else "MainJobStartDateSavedAt" end),
	"OtherJobsSavedAt" = (case when "OtherJobsSavedBy" = 'migration' then updated else "OtherJobsSavedAt" end),
	"NationalInsuranceNumberSavedAt" = (case when "NationalInsuranceNumberSavedBy" = 'migration' then updated else "NationalInsuranceNumberSavedAt" end),
	"PostcodeSavedAt" = (case when "PostcodeSavedBy" = 'migration' then updated else "PostcodeSavedAt" end),
	"DisabilitySavedAt" = (case when "DisabilitySavedBy" = 'migration' then updated else "DisabilitySavedAt" end),
	"GenderSavedAt" = (case when "GenderSavedBy" = 'migration' then updated else "GenderSavedAt" end),
	"EthnicityFKSavedAt" = (case when "EthnicityFKSavedBy" = 'migration' then updated else "EthnicityFKSavedAt" end),
	"NationalitySavedAt" = (case when "NationalitySavedBy" = 'migration' then updated else "NationalitySavedAt" end),
	"CountryOfBirthSavedAt" = (case when "CountryOfBirthSavedBy" = 'migration' then updated else "CountryOfBirthSavedAt" end),
	"RecruitedFromSavedAt" = (case when "RecruitedFromSavedBy" = 'migration' then updated else "RecruitedFromSavedAt" end),
	"BritishCitizenshipSavedAt" = (case when "BritishCitizenshipSavedBy" = 'migration' then updated else "BritishCitizenshipSavedAt" end),
	"YearArrivedSavedAt" = (case when "YearArrivedSavedBy" = 'migration' then updated else "YearArrivedSavedAt" end),
	"SocialCareStartDateSavedAt" = (case when "SocialCareStartDateSavedBy" = 'migration' then updated else "SocialCareStartDateSavedAt" end),
	"DaysSickSavedAt" = (case when "DaysSickSavedBy" = 'migration' then updated else "DaysSickSavedAt" end),
	"ZeroHoursContractSavedAt" = (case when "ZeroHoursContractSavedBy" = 'migration' then updated else "ZeroHoursContractSavedAt" end),
	"WeeklyHoursAverageSavedAt" = (case when "WeeklyHoursAverageSavedBy" = 'migration' then updated else "WeeklyHoursAverageSavedAt" end),
	"WeeklyHoursContractedSavedAt" = (case when "WeeklyHoursContractedSavedBy" = 'migration' then updated else "WeeklyHoursContractedSavedAt" end),
	"AnnualHourlyPaySavedAt" = (case when "AnnualHourlyPaySavedBy" = 'migration' then updated else "AnnualHourlyPaySavedAt" end),
	"CareCertificateSavedAt" = (case when "CareCertificateSavedBy" = 'migration' then updated else "CareCertificateSavedAt" end),
	"ApprenticeshipTrainingSavedAt" = (case when "ApprenticeshipTrainingSavedBy" = 'migration' then updated else "ApprenticeshipTrainingSavedAt" end),
	"CompletedSavedAt" = (case when "CompletedSavedBy" = 'migration' then updated else "CompletedSavedAt" end),
	"QualificationInSocialCareSavedAt" = (case when "QualificationInSocialCareSavedBy" = 'migration' then updated else "QualificationInSocialCareSavedAt" end),
	"SocialCareQualificationFKSavedAt" = (case when "SocialCareQualificationFKSavedBy" = 'migration' then updated else "SocialCareQualificationFKSavedAt" end),
	"OtherQualificationsSavedAt" = (case when "OtherQualificationsSavedBy" = 'migration' then updated else "OtherQualificationsSavedAt" end),
	"HighestQualificationFKSavedAt" = (case when "HighestQualificationFKSavedBy" = 'migration' then updated else "HighestQualificationFKSavedAt" end),
	"RegisteredNurseSavedAt" = (case when "RegisteredNurseSavedBy" = 'migration' then updated else "RegisteredNurseSavedAt" end),
	"NurseSpecialismFKSavedAt" = (case when "NurseSpecialismFKSavedBy" = 'migration' then updated else "NurseSpecialismFKSavedAt" end),
	"LocalIdentifierSavedAt" = (case when "LocalIdentifierSavedBy" = 'migration' then updated else "LocalIdentifierSavedAt" end),
	"DateOfBirthSavedAt" = (case when "DateOfBirthSavedBy" = 'migration' then updated else "DateOfBirthSavedAt" end)
where "TribalID" is not null;

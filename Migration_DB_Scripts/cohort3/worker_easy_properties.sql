-- FUNCTION: migration.worker_easy_properties(integer, integer, record)

-- DROP FUNCTION migration.worker_easy_properties(integer, integer, record);

CREATE OR REPLACE FUNCTION migration.worker_easy_properties(
	_tribalid integer,
	_sfcid integer,
	_workerrecord record)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$DECLARE
  PostCode VARCHAR(20);
  Gender VARCHAR(10);
  Disability VARCHAR(10);
  YearArrivedValue VARCHAR(5);
  YearArrivedYear INTEGER;
  SocialCareStartDateValue VARCHAR(5);
  SocialCareStartDateYear INTEGER;
  DaysSickValue VARCHAR(5);
  DaysSickDays NUMERIC(4,1);
  IsBritshCitizen VARCHAR(10);
  ZeroHourContract VARCHAR(10);
  SocialCareQualification VARCHAR(10);
  NonSocialCareQualification VARCHAR(10);
  SocialCareQualificationFK INTEGER;
  NonSocialCareQualificationFK INTEGER;
  MainJobStartDate DATE;
  CareCertificate VARCHAR(50);
  Apprenticeship VARCHAR(10);
  RecruitedFromValue VARCHAR(10);
  RecruitedFromOtherFK INTEGER;
  EthnicityFK INTEGER;
  NowTimestamp TIMESTAMP;
  CountryOfBirth VARCHAR(25);
  CountryOfBirthFK INTEGER;
  Nationality VARCHAR(25);
  NationalityFK INTEGER;
  WeeklyHoursContractedValue VARCHAR(5);
  WeeklyHoursContractedHours NUMERIC;
  WeeklyHoursAverageValue VARCHAR(5);
  WeeklyHoursAverageHours NUMERIC;
  AnnualHourlyPayValue VARCHAR(10);
  AnnualHourlyPayRate NUMERIC;
  DateOfBirth DATE;
  NiNumber VARCHAR(15);
  JobRoleCategory VARCHAR(30);
  LocalIdentifier VARCHAR(255);
  NurseSpecialismFK INTEGER;
  
BEGIN
  RAISE NOTICE '... mapping easy properties (Gender, Disability, British Citizenship....)';

  -- map postcode - a straight map
  PostCode = NULL;
  IF (_workerRecord.postcode IS NOT NULL) THEN
    PostCode = _workerRecord.postcode;
  END IF;

  YearArrivedValue = NULL;
  YearArrivedYear = NULL;
  IF (_workerRecord.yearofentry IS NOT NULL) THEN
    IF (_workerRecord.yearofentry = -1) THEN
      YearArrivedValue = 'No';
    ELSIF (_workerRecord.yearofentry > 1000) THEN
      YearArrivedValue = 'Yes';
      YearArrivedYear = _workerRecord.yearofentry;
    END IF;
  END IF;

  DaysSickValue = NULL;
  DaysSickDays = NULL;
  IF (_workerRecord.dayssick IS NOT NULL) THEN
    IF (_workerRecord.dayssick = -1) THEN
      DaysSickValue = 'No';
    ELSIF (_workerRecord.dayssick > -1) THEN
      DaysSickValue = 'Yes';
      DaysSickDays = _workerRecord.dayssick;
    END IF;
  END IF;

  SocialCareStartDateValue = NULL;
  SocialCareStartDateYear = NULL;
  IF (_workerRecord.startedinsector IS NOT NULL) THEN
    SocialCareStartDateValue = 'Yes';
    SocialCareStartDateYear = _workerRecord.startedinsector;
  END IF;
  
  Disability = NULL;
  IF (_workerRecord.disabled=0) THEN
    Disability = 'No';
  ELSIF (_workerRecord.disabled=1) THEN
    Disability = 'Yes';
  END IF;

  RAISE NOTICE 'Gender 3';
  Gender = NULL;
  IF (_workerRecord.gender=1) THEN
    Gender = 'Male';
  ELSIF (_workerRecord.gender=2) THEN
    Gender = 'Female';
  ELSIF (_workerRecord.gender=0) THEN
    Gender = NULL;
  ELSIF (_workerRecord.gender=3) THEN
    Gender = 'Don''t know';
  END IF;

  IsBritshCitizen = NULL;
  IF (_workerRecord.isbritishcitizen=1) THEN
    IsBritshCitizen = 'Yes';
  ELSIF (_workerRecord.isbritishcitizen=0) THEN
    IsBritshCitizen = 'No';
  ELSIF (_workerRecord.isbritishcitizen=-1) THEN
    IsBritshCitizen = 'Don''t know';
  END IF;
  
  ZeroHourContract = NULL;
  IF (_workerRecord.ZeroHourContract=1) THEN
    ZeroHourContract = 'Yes';
  ELSIF (_workerRecord.ZeroHourContract=0) THEN
    ZeroHourContract = 'No';
  ELSIF (_workerRecord.ZeroHourContract=-1) THEN
    ZeroHourContract = 'Don''t know';
  END IF;

  SocialCareQualification = NULL;
  IF (_workerRecord.socialcarequalification=1) THEN
    SocialCareQualification = 'Yes';
  ELSIF (_workerRecord.socialcarequalification=0) THEN
    SocialCareQualification = 'No';
  ELSIF (_workerRecord.socialcarequalification=-1) THEN
    SocialCareQualification = 'Don''t know';
  END IF;

  SocialCareQualificationFK = NULL;
  IF (_workerRecord.socialcarequallevel IS NOT NULL) THEN
    IF (_workerRecord.socialcarequallevel = -1) THEN
      SocialCareQualificationFK = 10;
    ELSIF (_workerRecord.socialcarequallevel = 621) THEN
      SocialCareQualificationFK = 1;
    ELSIF (_workerRecord.socialcarequallevel = 622) THEN
      SocialCareQualificationFK = 2;
    ELSIF (_workerRecord.socialcarequallevel = 623) THEN
      SocialCareQualificationFK = 3;
    ELSIF (_workerRecord.socialcarequallevel = 624) THEN
      SocialCareQualificationFK = 4;
    ELSIF (_workerRecord.socialcarequallevel = 625) THEN
      SocialCareQualificationFK = 5;
    ELSIF (_workerRecord.socialcarequallevel = 626) THEN
      SocialCareQualificationFK = 6;
    ELSIF (_workerRecord.socialcarequallevel = 627) THEN
      SocialCareQualificationFK = 8;
    ELSIF (_workerRecord.socialcarequallevel = 628) THEN
      SocialCareQualificationFK = 7;
    ELSIF (_workerRecord.socialcarequallevel = 629) THEN
      SocialCareQualificationFK = 9;
    END IF;
  END IF;

  NonSocialCareQualification = NULL;
  IF (_workerRecord.nonsocialcarequalification=1) THEN
    NonSocialCareQualification = 'Yes';
  ELSIF (_workerRecord.nonsocialcarequalification=0) THEN
    NonSocialCareQualification = 'No';
  ELSIF (_workerRecord.nonsocialcarequalification=-1) THEN
    NonSocialCareQualification = 'Don''t know';
  END IF;

  NonSocialCareQualificationFK = NULL;
  IF (_workerRecord.nonsocialcarequallevel IS NOT NULL) THEN
    IF (_workerRecord.nonsocialcarequallevel = -1) THEN
      NonSocialCareQualificationFK = 10;
    ELSIF (_workerRecord.nonsocialcarequallevel = 621) THEN
      NonSocialCareQualificationFK = 1;
    ELSIF (_workerRecord.nonsocialcarequallevel = 622) THEN
      NonSocialCareQualificationFK = 2;
    ELSIF (_workerRecord.nonsocialcarequallevel = 623) THEN
      NonSocialCareQualificationFK = 3;
    ELSIF (_workerRecord.nonsocialcarequallevel = 624) THEN
      NonSocialCareQualificationFK = 4;
    ELSIF (_workerRecord.nonsocialcarequallevel = 625) THEN
      NonSocialCareQualificationFK = 5;
    ELSIF (_workerRecord.nonsocialcarequallevel = 626) THEN
      NonSocialCareQualificationFK = 6;
    ELSIF (_workerRecord.nonsocialcarequallevel = 627) THEN
      NonSocialCareQualificationFK = 8;
    ELSIF (_workerRecord.nonsocialcarequallevel = 628) THEN
      NonSocialCareQualificationFK = 7;
    ELSIF (_workerRecord.nonsocialcarequallevel = 629) THEN
      NonSocialCareQualificationFK = 9;
    END IF;
  END IF;

  MainJobStartDate = NULL;
  IF (_workerRecord.startdate IS NOT NULL) THEN
    MainJobStartDate = _workerRecord.startdate::DATE;
  END IF;

  CareCertificate = NULL;
  IF (_workerRecord.carecertificate IS NOT NULL) THEN
    IF (_workerRecord.carecertificate = 802) THEN
      CareCertificate = 'Yes, completed';
    ELSIF (_workerRecord.carecertificate = 803) THEN
      CareCertificate = 'No';
    ELSIF (_workerRecord.carecertificate = 804) THEN
      CareCertificate = 'Yes, in progress or partially completed';
    END IF;
  END IF;

  Apprenticeship = NULL;
  IF (_workerRecord.isapprentice=1) THEN
    Apprenticeship = 'Yes';
  ELSIF (_workerRecord.isapprentice=0) THEN
    Apprenticeship = 'No';
  ELSIF (_workerRecord.isapprentice=-1) THEN
    Apprenticeship = 'Don''t know';
  END IF;

  RecruitedFromValue = NULL;
  RecruitedFromOtherFK = NULL;
  IF (_workerRecord.sourcerecruited IS NOT NULL) THEN
    IF (_workerRecord.sourcerecruited = 225) THEN
      RecruitedFromValue = 'No';
    ELSIF (_workerRecord.sourcerecruited = 210) THEN
      RecruitedFromValue = 'Yes';
      RecruitedFromOtherFK = 1;
    ELSIF (_workerRecord.sourcerecruited = 211) THEN
      RecruitedFromValue = 'Yes';
      RecruitedFromOtherFK = 2;
    ELSIF (_workerRecord.sourcerecruited = 212) THEN
      RecruitedFromValue = 'Yes';
      RecruitedFromOtherFK = 4;
    ELSIF (_workerRecord.sourcerecruited = 213) THEN
      RecruitedFromValue = 'Yes';
      RecruitedFromOtherFK = 4;
    ELSIF (_workerRecord.sourcerecruited = 214) THEN
      RecruitedFromValue = 'Yes';
      RecruitedFromOtherFK = 3;
    ELSIF (_workerRecord.sourcerecruited = 215) THEN
      RecruitedFromValue = 'Yes';
      RecruitedFromOtherFK = 5;
    ELSIF (_workerRecord.sourcerecruited = 216) THEN
      RecruitedFromValue = 'Yes';
      RecruitedFromOtherFK = 5;
    ELSIF (_workerRecord.sourcerecruited = 217) THEN
      RecruitedFromValue = 'Yes';
      RecruitedFromOtherFK = 6;
    ELSIF (_workerRecord.sourcerecruited = 218) THEN
      RecruitedFromValue = 'Yes';
      RecruitedFromOtherFK = 10;
    ELSIF (_workerRecord.sourcerecruited = 219) THEN
      RecruitedFromValue = 'Yes';
      RecruitedFromOtherFK = 7;
    ELSIF (_workerRecord.sourcerecruited = 220) THEN
      RecruitedFromValue = 'Yes';
      RecruitedFromOtherFK = 10;
    ELSIF (_workerRecord.sourcerecruited = 221) THEN
      RecruitedFromValue = 'Yes';
      RecruitedFromOtherFK = 8;
    ELSIF (_workerRecord.sourcerecruited = 222) THEN
      RecruitedFromValue = 'Yes';
      RecruitedFromOtherFK = 10;
    ELSIF (_workerRecord.sourcerecruited = 223) THEN
      RecruitedFromValue = 'Yes';
      RecruitedFromOtherFK = 10;
    ELSIF (_workerRecord.sourcerecruited = 224) THEN
      RecruitedFromValue = 'Yes';
      RecruitedFromOtherFK = 10;
    END IF;
  END IF;

  EthnicityFK = NULL;
  IF (_workerRecord.ethnicity IS NOT NULL) THEN
    IF (_workerRecord.ethnicity = 31) THEN
      EthnicityFK = 1;
    ELSIF (_workerRecord.ethnicity = 99) THEN
      EthnicityFK = 2;
    ELSIF (_workerRecord.ethnicity = 32) THEN
      EthnicityFK = 3;
    ELSIF (_workerRecord.ethnicity = 33) THEN
      EthnicityFK = 4;
    ELSIF (_workerRecord.ethnicity = 34) THEN
      EthnicityFK = 5;
    ELSIF (_workerRecord.ethnicity = 35) THEN
      EthnicityFK = 6;
    ELSIF (_workerRecord.ethnicity = 36) THEN
      EthnicityFK = 7;
    ELSIF (_workerRecord.ethnicity = 37) THEN
      EthnicityFK = 8;
    ELSIF (_workerRecord.ethnicity = 38) THEN
      EthnicityFK = 9;
    ELSIF (_workerRecord.ethnicity = 39) THEN
      EthnicityFK = 10;
    ELSIF (_workerRecord.ethnicity = 40) THEN
      EthnicityFK = 11;
    ELSIF (_workerRecord.ethnicity = 41) THEN
      EthnicityFK = 12;
    ELSIF (_workerRecord.ethnicity = 42) THEN
      EthnicityFK = 13;
    ELSIF (_workerRecord.ethnicity = 43) THEN
      EthnicityFK = 14;
    ELSIF (_workerRecord.ethnicity = 44) THEN
      EthnicityFK = 15;
    ELSIF (_workerRecord.ethnicity = 45) THEN
      EthnicityFK = 16;
    ELSIF (_workerRecord.ethnicity = 46) THEN
      EthnicityFK = 17;
    ELSIF (_workerRecord.ethnicity = 47) THEN
      EthnicityFK = 18;
    ELSIF (_workerRecord.ethnicity = 48) THEN
      EthnicityFK = 19;
    ELSIF (_workerRecord.ethnicity = -1) THEN
      EthnicityFK = NULL;
    END IF;
  END IF;

  -- country of birth mapping - the source, although they look like numbers they are strings
  CountryOfBirth = NULL;
  CountryOfBirthFK = NULL;
  IF (_workerRecord.countryofbirth IS NOT NULL) THEN
    IF (_workerRecord.countryofbirth = '826') THEN
      CountryOfBirth = 'United Kingdom';
      CountryOfBirthFK = NULL;
    ELSIF (_workerRecord.countryofbirth = '999') THEN
      CountryOfBirth = 'Other';
      CountryOfBirthFK = NULL;
    ELSIF (_workerRecord.countryofbirth = '998') THEN
      CountryOfBirth = 'Don''t know';
      CountryOfBirthFK = NULL;
    ELSE
      CountryOfBirth = 'Other';
      CountryOfBirthFK = _workerRecord.targetcountryid;
    END IF;
  END IF;

  -- nationality mapping - the source, although they look like numbers they are strings
  Nationality = NULL;
  NationalityFK = NULL;
  IF (_workerRecord.nationality IS NOT NULL) THEN
    IF (_workerRecord.nationality in ('826', '833', '86', '612', '831', '832', '238', '92')) THEN
      Nationality = 'British';
      NationalityFK = NULL;
    ELSIF (_workerRecord.nationality = '999') THEN
      Nationality = 'Other';
      NationalityFK = NULL;
    ELSIF (_workerRecord.nationality = '998') THEN
      Nationality = 'Don''t know';
      NationalityFK = NULL;
    ELSE
      Nationality = 'Other';
      NationalityFK = _workerRecord.targetnationalityid;
    END IF;
  END IF;

  -- contracted/average hours - special handling for zero contract hour workers
  WeeklyHoursContractedValue = NULL;
  WeeklyHoursContractedHours = NULL;
  IF (_workerRecord.ZeroHourContract=1) THEN
    -- on zero hour contracts, contracted hours are always 0
    WeeklyHoursContractedValue = 'Yes';
    WeeklyHoursContractedHours = 0;

    -- on zero hour contracts, typically, the average hours comes from worker.additionalhours
    --  BUT - the additionalhours can be null, 0 or -1 - in which case try to use the contracted hours
    IF (_workerRecord.additionalhours IS NULL or _workerRecord.additionalhours <= 0) THEN
      -- try contracted hours
      IF (_workerRecord.contractedhours > 0) THEN
        WeeklyHoursAverageValue = 'Yes';
        WeeklyHoursAverageHours = _workerRecord.contractedhours;
      ELSE
        -- neither additional nor contracted hours
        WeeklyHoursAverageValue = NULL;
        WeeklyHoursAverageHours = NULL;
      END IF;
    ELSE
      WeeklyHoursAverageValue = 'Yes';
      WeeklyHoursAverageHours = _workerRecord.additionalhours;
    END IF;
    
  ELSE
    IF (_workerRecord.contractedhours IS NOT NULL) THEN

      -- 190 = permanent, 191 = temp
      IF (_workerRecord.employmentstatus IS NULL OR _workerRecord.employmentstatus = 190 OR _workerRecord.employmentstatus = 191) THEN
        IF (_workerRecord.contractedhours = -1) THEN
          WeeklyHoursContractedValue = NULL;
          WeeklyHoursContractedHours = NULL;
        ELSIF (_workerRecord.contractedhours = 0) THEN
          WeeklyHoursContractedValue = 'No';
          WeeklyHoursContractedHours = NULL;
        ELSIF (_workerRecord.contractedhours > 0) THEN
          WeeklyHoursContractedValue = 'Yes';
          WeeklyHoursContractedHours = _workerRecord.contractedhours;
        END IF;
      ELSE
        IF (_workerRecord.contractedhours = -1) THEN
          WeeklyHoursAverageValue = NULL;
          WeeklyHoursAverageHours = NULL;
        ELSIF (_workerRecord.contractedhours = 0) THEN
          WeeklyHoursAverageValue = 'No';
          WeeklyHoursAverageHours = NULL;
        ELSIF (_workerRecord.contractedhours > 0) THEN
          WeeklyHoursAverageValue = 'Yes';
          WeeklyHoursAverageHours = _workerRecord.contractedhours;
        END IF;
      END IF; -- end _workerRecord.employmentstatus
    END IF; -- end _workerRecord.contractedhours

  END IF;   -- end ZeroHourContract=1

  -- annual/hourly pay rate
  AnnualHourlyPayValue = NULL;
  AnnualHourlyPayRate = NULL;
  IF (_workerRecord.salaryinterval IS NOT NULL) THEN
    IF (_workerRecord.salaryinterval = 253) THEN    -- unpaid
      AnnualHourlyPayValue = NULL;
      AnnualHourlyPayRate = NULL;
    ELSIF (_workerRecord.salaryinterval = 250 AND _workerRecord.salary IS NOT NULL) THEN
      AnnualHourlyPayValue = 'Annually';
      AnnualHourlyPayRate = _workerRecord.salary;
    ELSIF (_workerRecord.salaryinterval = 252 AND _workerRecord.hourlyrate IS NOT NULL) THEN
      AnnualHourlyPayValue = 'Hourly';
      AnnualHourlyPayRate = _workerRecord.hourlyrate;
    ELSIF (_workerRecord.salaryinterval = 251 AND _workerRecord.hourlyrate IS NOT NULL) THEN
      AnnualHourlyPayValue = 'Annually';
      AnnualHourlyPayRate = _workerRecord.hourlyrate*12;
    END IF;
  END IF;

  -- date of birth
  DateOfBirth = NULL;
  IF (_workerRecord.target_dob IS NOT NULL) THEN
    DateOfBirth = _workerRecord.target_dob::DATE;
  END IF;

  -- National Insurance (NI) Number
  NiNumber = NULL;
  IF (_workerRecord.target_ni IS NOT NULL) THEN
    NiNumber = _workerRecord.target_ni;
  END IF;

  LocalIdentifier = NULL;
  IF (_workerRecord.bulkuploadidentifier IS NOT NULL) THEN
    LocalIdentifier = _workerRecord.bulkuploadidentifier;
  END IF;
  
  JobRoleCategory = NULL;
  IF (_workerRecord.jobrolecategory IS NOT NULL) THEN
  
    IF (_workerRecord.jobrolecategory = 1) THEN
      JobRoleCategory = 'Adult Nurse';
    ELSIF (_workerRecord.jobrolecategory = 2) THEN
	  JobRoleCategory = 'Mental Health Nurse';
    ELSIF (_workerRecord.jobrolecategory = 3) THEN
	  JobRoleCategory = 'Learning Disabilities Nurse';
    ELSIF (_workerRecord.jobrolecategory = 4) THEN
	  JobRoleCategory = 'Children''s Nurse';
	ELSE
	  JobRoleCategory = 'Enrolled Nurse';
    END IF;

  END IF;
  
  NurseSpecialismFK = NULL;
  IF (_workerRecord.nursefirstspecialism) IS NOT NULL THEN
	NurseSpecialismFK = _workerRecord.nursefirstspecialism;
  END IF;

  -- update the Worker record
  select now() INTO NowTimestamp;

  UPDATE
    cqc."Worker"
  SET
    "QualificationInSocialCareValue" = CASE WHEN SocialCareQualification IS NOT NULL THEN SocialCareQualification::cqc."WorkerQualificationInSocialCare" ELSE NULL END,
    "QualificationInSocialCareSavedAt" = CASE WHEN SocialCareQualification IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "QualificationInSocialCareSavedBy" = CASE WHEN SocialCareQualification IS NOT NULL THEN 'migration' ELSE NULL END,
    "SocialCareQualificationFKValue" = CASE WHEN SocialCareQualificationFK IS NOT NULL THEN SocialCareQualificationFK ELSE NULL END,
    "SocialCareQualificationFKSavedAt" = CASE WHEN SocialCareQualificationFK IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "SocialCareQualificationFKSavedBy" = CASE WHEN SocialCareQualificationFK IS NOT NULL THEN 'migration' ELSE NULL END,
    "OtherQualificationsValue" = CASE WHEN NonSocialCareQualification IS NOT NULL THEN NonSocialCareQualification::cqc."WorkerOtherQualifications" ELSE NULL END,
    "OtherQualificationsSavedAt" = CASE WHEN NonSocialCareQualification IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "OtherQualificationsSavedBy" = CASE WHEN NonSocialCareQualification IS NOT NULL THEN 'migration' ELSE NULL END,
    "HighestQualificationFKValue" = CASE WHEN NonSocialCareQualificationFK IS NOT NULL THEN NonSocialCareQualificationFK ELSE NULL END,
    "HighestQualificationFKSavedAt" = CASE WHEN NonSocialCareQualificationFK IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "HighestQualificationFKSavedBy" = CASE WHEN NonSocialCareQualificationFK IS NOT NULL THEN 'migration' ELSE NULL END,
    "ZeroHoursContractValue" = CASE WHEN ZeroHourContract IS NOT NULL THEN ZeroHourContract::cqc."WorkerZeroHoursContract" ELSE NULL END,
    "ZeroHoursContractSavedAt" = CASE WHEN ZeroHourContract IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "ZeroHoursContractSavedBy" = CASE WHEN ZeroHourContract IS NOT NULL THEN 'migration' ELSE NULL END,
    "BritishCitizenshipValue" = CASE WHEN IsBritshCitizen IS NOT NULL THEN IsBritshCitizen::cqc."WorkerBritishCitizenship" ELSE NULL END,
    "BritishCitizenshipSavedAt" = CASE WHEN IsBritshCitizen IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "BritishCitizenshipSavedBy" = CASE WHEN IsBritshCitizen IS NOT NULL THEN 'migration' ELSE NULL END,
    "YearArrivedValue" = CASE WHEN YearArrivedValue IS NOT NULL THEN YearArrivedValue::cqc."WorkerYearArrived" ELSE NULL END,
    "YearArrivedYear" = CASE WHEN YearArrivedYear IS NOT NULL THEN YearArrivedYear ELSE NULL END,
    "YearArrivedSavedAt" = CASE WHEN YearArrivedValue IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "YearArrivedSavedBy" = CASE WHEN YearArrivedValue IS NOT NULL THEN 'migration' ELSE NULL END,
    "SocialCareStartDateValue" = CASE WHEN SocialCareStartDateValue IS NOT NULL THEN SocialCareStartDateValue::cqc."WorkerSocialCareStartDate" ELSE NULL END,
    "SocialCareStartDateYear" = CASE WHEN SocialCareStartDateYear IS NOT NULL THEN SocialCareStartDateYear ELSE NULL END,
    "SocialCareStartDateSavedAt" = CASE WHEN SocialCareStartDateValue IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "SocialCareStartDateSavedBy" = CASE WHEN SocialCareStartDateValue IS NOT NULL THEN 'migration' ELSE NULL END,
    "DaysSickValue" = CASE WHEN DaysSickValue IS NOT NULL THEN DaysSickValue::cqc."WorkerDaysSick" ELSE NULL END,
    "DaysSickDays" = CASE WHEN DaysSickDays IS NOT NULL THEN DaysSickDays ELSE NULL END,
    "DaysSickSavedAt" = CASE WHEN DaysSickValue IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "DaysSickSavedBy" = CASE WHEN DaysSickValue IS NOT NULL THEN 'migration' ELSE NULL END,
    "PostcodeValue" = CASE WHEN PostCode IS NOT NULL THEN PostCode ELSE NULL END,
    "PostcodeSavedAt" = CASE WHEN PostCode IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "PostcodeSavedBy" = CASE WHEN PostCode IS NOT NULL THEN 'migration' ELSE NULL END,
    "DisabilityValue" = CASE WHEN Disability IS NOT NULL THEN Disability::cqc."WorkerDisability" ELSE NULL END,
    "DisabilitySavedAt" = CASE WHEN Disability IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "DisabilitySavedBy" = CASE WHEN Disability IS NOT NULL THEN 'migration' ELSE NULL END,
    "GenderValue" = CASE WHEN Gender IS NOT NULL THEN Gender::cqc."WorkerGender" ELSE NULL END,
    "GenderSavedAt" = CASE WHEN Gender IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "GenderSavedBy" = CASE WHEN Gender IS NOT NULL THEN 'migration' ELSE NULL END,
    "MainJobStartDateValue" = CASE WHEN MainJobStartDate IS NOT NULL THEN MainJobStartDate ELSE NULL END,
    "MainJobStartDateSavedAt" = CASE WHEN MainJobStartDate IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "MainJobStartDateSavedBy" = CASE WHEN MainJobStartDate IS NOT NULL THEN 'migration' ELSE NULL END,
    "CareCertificateValue" = CASE WHEN CareCertificate IS NOT NULL THEN CareCertificate::cqc."WorkerCareCertificate" ELSE NULL END,
    "CareCertificateSavedAt" = CASE WHEN CareCertificate IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "CareCertificateSavedBy" = CASE WHEN CareCertificate IS NOT NULL THEN 'migration' ELSE NULL END,
    "ApprenticeshipTrainingValue" = CASE WHEN Apprenticeship IS NOT NULL THEN Apprenticeship::cqc."WorkerApprenticeshipTraining" ELSE NULL END,
    "ApprenticeshipTrainingSavedAt" = CASE WHEN Apprenticeship IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "ApprenticeshipTrainingSavedBy" = CASE WHEN Apprenticeship IS NOT NULL THEN 'migration' ELSE NULL END,
    "RecruitedFromValue" = CASE WHEN RecruitedFromValue IS NOT NULL THEN RecruitedFromValue::cqc."WorkerRecruitedFrom" ELSE NULL END,
    "RecruitedFromOtherFK" = CASE WHEN RecruitedFromOtherFK IS NOT NULL THEN RecruitedFromOtherFK ELSE NULL END,
    "RecruitedFromSavedAt" = CASE WHEN RecruitedFromValue IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "RecruitedFromSavedBy" = CASE WHEN RecruitedFromValue IS NOT NULL THEN 'migration' ELSE NULL END,
    "EthnicityFKValue" = CASE WHEN EthnicityFK IS NOT NULL THEN EthnicityFK ELSE NULL END,
    "EthnicityFKSavedAt" = CASE WHEN EthnicityFK IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "EthnicityFKSavedBy" = CASE WHEN EthnicityFK IS NOT NULL THEN 'migration' ELSE NULL END,
    "CountryOfBirthValue" = CASE WHEN CountryOfBirth IS NOT NULL THEN CountryOfBirth::cqc."WorkerCountryOfBirth" ELSE NULL END,
    "CountryOfBirthOtherFK" = CASE WHEN CountryOfBirthFK IS NOT NULL THEN CountryOfBirthFK ELSE NULL END,
    "CountryOfBirthSavedAt" = CASE WHEN CountryOfBirth IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "CountryOfBirthSavedBy" = CASE WHEN CountryOfBirth IS NOT NULL THEN 'migration' ELSE NULL END,
    "NationalityValue" = CASE WHEN Nationality IS NOT NULL THEN Nationality::cqc."WorkerNationality" ELSE NULL END,
    "NationalityOtherFK" = CASE WHEN Nationality IS NOT NULL THEN NationalityFK ELSE NULL END,
    "NationalitySavedAt" = CASE WHEN Nationality IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "NationalitySavedBy" = CASE WHEN Nationality IS NOT NULL THEN 'migration' ELSE NULL END,
    "WeeklyHoursContractedValue" = CASE WHEN WeeklyHoursContractedValue IS NOT NULL THEN WeeklyHoursContractedValue::cqc."WorkerWeeklyHoursContracted" ELSE NULL END,
    "WeeklyHoursContractedHours" = CASE WHEN WeeklyHoursContractedHours IS NOT NULL THEN WeeklyHoursContractedHours::NUMERIC(4,1) ELSE NULL END,
    "WeeklyHoursContractedSavedAt" = CASE WHEN WeeklyHoursContractedValue IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "WeeklyHoursContractedSavedBy" = CASE WHEN WeeklyHoursContractedValue IS NOT NULL THEN 'migration' ELSE NULL END,
    "WeeklyHoursAverageValue" = CASE WHEN WeeklyHoursAverageValue IS NOT NULL THEN WeeklyHoursAverageValue::cqc."WorkerWeeklyHoursAverage" ELSE NULL END,
    "WeeklyHoursAverageHours" = CASE WHEN WeeklyHoursAverageHours IS NOT NULL THEN WeeklyHoursAverageHours::NUMERIC(4,1) ELSE NULL END,
    "WeeklyHoursAverageSavedAt" = CASE WHEN WeeklyHoursAverageValue IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "WeeklyHoursAverageSavedBy" = CASE WHEN WeeklyHoursAverageValue IS NOT NULL THEN 'migration' ELSE NULL END,
    "AnnualHourlyPayValue" = CASE WHEN AnnualHourlyPayValue IS NOT NULL THEN AnnualHourlyPayValue::cqc."WorkerAnnualHourlyPay" ELSE NULL END,
    "AnnualHourlyPayRate" = CASE WHEN AnnualHourlyPayRate IS NOT NULL THEN AnnualHourlyPayRate::NUMERIC(9,2) ELSE NULL END,
    "AnnualHourlyPaySavedAt" = CASE WHEN AnnualHourlyPayValue IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "AnnualHourlyPaySavedBy" = CASE WHEN AnnualHourlyPayValue IS NOT NULL THEN 'migration' ELSE NULL END,
    "DateOfBirthValue" = CASE WHEN DateOfBirth IS NOT NULL THEN DateOfBirth ELSE NULL END,
    "DateOfBirthSavedAt" = CASE WHEN DateOfBirth IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "DateOfBirthSavedBy" = CASE WHEN DateOfBirth IS NOT NULL THEN 'migration' ELSE NULL END,
    "NationalInsuranceNumberValue" = CASE WHEN NiNumber IS NOT NULL THEN NiNumber ELSE NULL END,
    "NationalInsuranceNumberSavedAt" = CASE WHEN NiNumber IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "NationalInsuranceNumberSavedBy" = CASE WHEN NiNumber IS NOT NULL THEN 'migration' ELSE NULL END,
	"DataSource" = NULL,
    "RegisteredNurseValue" = CASE WHEN JobRoleCategory IS NOT NULL THEN JobRoleCategory::cqc.worker_registerednurses_enum ELSE NULL END,
    "RegisteredNurseSavedAt" = CASE WHEN JobRoleCategory IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "RegisteredNurseSavedBy" = CASE WHEN JobRoleCategory IS NOT NULL THEN 'migration' ELSE NULL END,
    "NurseSpecialismFKValue" = CASE WHEN NurseSpecialismFK IS NOT NULL THEN NurseSpecialismFK ELSE NULL END,
    "NurseSpecialismFKOther" = NULL,
    "NurseSpecialismFKSavedAt" = CASE WHEN NurseSpecialismFK IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "NurseSpecialismFKSavedBy" = CASE WHEN NurseSpecialismFK IS NOT NULL THEN 'migration' ELSE NULL END,
    "LocalIdentifierValue" = LocalIdentifier,
    "LocalIdentifierSavedAt" = CASE WHEN LocalIdentifier IS NOT NULL THEN NowTimestamp ELSE NULL END,
    "LocalIdentifierSavedBy" = CASE WHEN LocalIdentifier IS NOT NULL THEN 'migration' ELSE NULL END,
    "CompletedValue" = true,
	"CompletedSavedBy" = 'migration',
	"CompletedSavedAt" = NowTimestamp
	
  WHERE
    "ID" = _sfcid;

END;
$BODY$;

ALTER FUNCTION migration.worker_easy_properties(integer, integer, record)
    OWNER TO postgres;

BEGIN;
SELECT COUNT(*)
FROM cqc."Worker"
WHERE "WdfEligible" = false;

SELECT COUNT(*)
FROM cqc."Worker"
WHERE "WdfEligible" = true;

UPDATE cqc."Worker"
SET "WdfEligible" = true
WHERE "GenderValue" IS NOT NULL
    AND "GenderSavedAt" IS NOT NULL
    AND ("DateOfBirthValue" IS NOT NULL OR "DateOfBirthEncryptedValue" IS NOT NULL)
    AND "DateOfBirthSavedAt" IS NOT NULL
    AND "NationalityValue" IS NOT NULL
    AND "NationalitySavedAt" IS NOT NULL
    AND "MainJobFKValue" IS NOT NULL
    AND "MainJobFKSavedAt" IS NOT NULL
    AND "MainJobStartDateValue" IS NOT NULL
    AND "MainJobStartDateSavedAt" IS NOT NULL
    AND "RecruitedFromValue" IS NOT NULL
    AND "RecruitedFromSavedAt" IS NOT NULL
    AND "ContractValue" IS NOT NULL
    AND "ContractSavedAt" IS NOT NULL
    AND "ZeroHoursContractValue" IS NOT NULL
    AND "ZeroHoursContractSavedAt" IS NOT NULL
    AND (
        (
            "ZeroHoursContractValue" IN ('No', 'Don''t know')
            AND (
                (
                    "ContractValue" IN ('Permanent', 'Temporary')
                    AND "WeeklyHoursContractedValue" IS NOT NULL
                )
                OR (
                    "ContractValue" IN ('Pool/Bank', 'Agency', 'Other')
                    AND "WeeklyHoursAverageValue" IS NOT NULL
                )
            )
        )
        OR (
            "ZeroHoursContractValue" = 'Yes'
            AND "WeeklyHoursAverageValue" IS NOT NULL
        )
    )
    AND "WeeklyHoursContractedSavedAt" IS NOT NULL
    AND "WeeklyHoursAverageSavedAt" IS NOT NULL
    AND "AnnualHourlyPayValue" IS NOT NULL
    AND "AnnualHourlyPaySavedAt" IS NOT NULL
    AND ((
      "ContractValue" IN ('Permanent', 'Temporary')
      AND "DaysSickValue" IS NOT NULL
    )
      OR "ContractValue" IN ('Pool/Bank', 'Agency', 'Other')
    )
    AND "DaysSickSavedAt" IS NOT NULL
    AND "CareCertificateValue" IS NOT NULL
    AND "CareCertificateSavedAt" IS NOT NULL
    AND "QualificationInSocialCareValue" IS NOT NULL
    AND "QualificationInSocialCareSavedAt" IS NOT NULL
    AND (
      (
        "QualificationInSocialCareValue" = 'Yes'
        AND "SocialCareQualificationFKValue" IS NOT NULL
      )
      OR "QualificationInSocialCareValue" = 'No'
      OR "QualificationInSocialCareValue" = 'Don''t know'
    )
    AND "SocialCareQualificationFKSavedAt" IS NOT NULL
    AND "OtherQualificationsValue" IS NOT NULL
    AND "OtherQualificationsSavedAt" IS NOT NULL
    AND (
      (
        "OtherQualificationsValue" = 'Yes'
        AND "HighestQualificationFKValue" IS NOT NULL
      )
      OR "OtherQualificationsValue" = 'No'
      OR "OtherQualificationsValue" = 'Don''t know'
    )
    AND "HighestQualificationFKSavedAt" IS NOT NULL;

SELECT COUNT(*)
FROM cqc."Worker"
WHERE "WdfEligible" = false;

SELECT COUNT(*)
FROM cqc."Worker"
WHERE "WdfEligible" = true;
ROLLBACK;

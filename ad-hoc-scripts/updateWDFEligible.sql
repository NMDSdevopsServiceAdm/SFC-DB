BEGIN;

SELECT
    "WorkerUID",
    "NameOrIdValue",
    "WdfEligible"
FROM
    cqc."Worker"
WHERE
    "WorkerUID" IN (
        'af9d7738-9739-4330-bdec-a0a1120ac22f',
        '6b24de31-e560-42ee-b826-d5552ad1deb9',
        '6f494cab-7597-438e-bed6-33adace32c90'
    );

UPDATE
    cqc."Worker"
SET
    "WdfEligible" = true
WHERE
    "GenderValue" IS NOT NULL
    AND "GenderSavedAt" IS NOT NULL
    AND (
        "DateOfBirthValue" IS NOT NULL
        OR "DateOfBirthEncryptedValue" IS NOT NULL
    )
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
            "ZeroHoursContractValue" = 'No'
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
        OR "ZeroHoursContractValue" = 'Don''t know'
    )
    AND "WeeklyHoursContractedSavedAt" IS NOT NULL
    AND "WeeklyHoursAverageSavedAt" IS NOT NULL
    AND "AnnualHourlyPayValue" IS NOT NULL
    AND "AnnualHourlyPaySavedAt" IS NOT NULL
    AND (
        (
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
    AND "HighestQualificationFKSavedAt" IS NOT NULL
    AND "WorkerUID" IN (
        'af9d7738-9739-4330-bdec-a0a1120ac22f',
        '6b24de31-e560-42ee-b826-d5552ad1deb9',
        '6f494cab-7597-438e-bed6-33adace32c90'
    );

SELECT
    "WorkerUID",
    "NameOrIdValue",
    "WdfEligible"
FROM
    cqc."Worker"
WHERE
    "WorkerUID" IN (
        'af9d7738-9739-4330-bdec-a0a1120ac22f',
        '6b24de31-e560-42ee-b826-d5552ad1deb9',
        '6f494cab-7597-438e-bed6-33adace32c90'
    );

ROLLBACK;
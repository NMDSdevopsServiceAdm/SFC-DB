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
        '6b24de31-e560-42ee-b826-d5552ad1deb9'
    );

UPDATE
    cqc."Worker"
SET
    "WdfEligible" = true
WHERE
    "GenderValue" IS NOT NULL
    AND "GenderSavedAt" IS NOT NULL -- AND "DateOfBirthValue" IS NOT NULL
    -- AND "DateOfBirthSavedAt" IS NOT NULL
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
    AND "WorkerUID" IN (
        'af9d7738-9739-4330-bdec-a0a1120ac22f',
        '6b24de31-e560-42ee-b826-d5552ad1deb9'
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
        '6b24de31-e560-42ee-b826-d5552ad1deb9'
    );

ROLLBACK;
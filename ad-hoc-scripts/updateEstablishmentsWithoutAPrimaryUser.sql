BEGIN;

-- Count of Establishments that don't have a primary user
SELECT
        COUNT(*)
FROM
        (
                SELECT
                        DISTINCT ON (u."EstablishmentID") u."EstablishmentID"
                FROM
                        cqc."User" u
                        JOIN cqc."Login" l ON l."RegistrationID" = u."RegistrationID"
                WHERE
                        u."IsPrimary" = false
                        AND (
                                SELECT
                                        count(*)
                                FROM
                                        cqc."User"
                                WHERE
                                        "IsPrimary" = true
                                        AND "EstablishmentID" = u."EstablishmentID"
                        ) = 0
                        AND u."EstablishmentID" IS NOT NULL
                        AND u."UserRoleValue" = 'Edit'
        ) as accountsWithoutPrimary;

-- List the affected establishment ID's
SELECT
        DISTINCT ON (u."EstablishmentID") u."EstablishmentID",
        l."Username"
FROM
        cqc."User" u
        JOIN cqc."Login" l ON l."RegistrationID" = u."RegistrationID"
WHERE
        u."IsPrimary" = false
        AND u."EstablishmentID" IS NOT NULL
        AND u."UserRoleValue" = 'Edit'
        AND (
                SELECT
                        COUNT(*)
                FROM
                        cqc."User"
                WHERE
                        "IsPrimary" = true
                        AND "EstablishmentID" = u."EstablishmentID"
        ) = 0;

-- List oldest active registration ID for the affected establishments
SELECT
        l2."RegistrationID"
FROM
        cqc."User" u2
        JOIN cqc."Login" l2 ON l2."RegistrationID" = u2."RegistrationID"
WHERE
        (
                u2."EstablishmentID",
                u2."RegistrationID"
        ) IN (
                SELECT
                        u."EstablishmentID",
                        MIN(u."RegistrationID") userRegistrationID
                FROM
                        cqc."User" u
                        JOIN cqc."Login" l ON l."RegistrationID" = u."RegistrationID"
                WHERE
                        u."IsPrimary" = false
                        AND (
                                SELECT
                                        count(*)
                                FROM
                                        cqc."User"
                                WHERE
                                        "IsPrimary" = true
                                        AND "EstablishmentID" = u."EstablishmentID"
                        ) = 0
                        AND u."EstablishmentID" IS NOT NULL
                        AND u."UserRoleValue" = 'Edit'
                GROUP BY
                        (u."EstablishmentID")
        );

-- Update oldest active Edit user on account to be the Primary user
UPDATE
        cqc."User"
SET
        "IsPrimary" = true
WHERE
        "RegistrationID" IN (
                SELECT
                        l2."RegistrationID"
                FROM
                        cqc."User" u2
                        JOIN cqc."Login" l2 ON l2."RegistrationID" = u2."RegistrationID"
                WHERE
                        (
                                u2."EstablishmentID",
                                u2."RegistrationID"
                        ) IN (
                                SELECT
                                        u."EstablishmentID",
                                        MIN(u."RegistrationID") userRegistrationID
                                FROM
                                        cqc."User" u
                                        JOIN cqc."Login" l ON l."RegistrationID" = u."RegistrationID"
                                WHERE
                                        u."IsPrimary" = false
                                        AND (
                                                SELECT
                                                        count(*)
                                                FROM
                                                        cqc."User"
                                                WHERE
                                                        "IsPrimary" = true
                                                        AND "EstablishmentID" = u."EstablishmentID"
                                        ) = 0
                                        AND u."EstablishmentID" IS NOT NULL
                                        AND u."UserRoleValue" = 'Edit'
                                GROUP BY
                                        (u."EstablishmentID")
                        )
        );

-- Repeat count - should equal to zero
SELECT
        COUNT(*)
FROM
        (
                SELECT
                        DISTINCT ON (u."EstablishmentID") u."EstablishmentID"
                FROM
                        cqc."User" u
                        JOIN cqc."Login" l ON l."RegistrationID" = u."RegistrationID"
                WHERE
                        u."IsPrimary" = false
                        AND (
                                SELECT
                                        count(*)
                                FROM
                                        cqc."User"
                                WHERE
                                        "IsPrimary" = true
                                        AND "EstablishmentID" = u."EstablishmentID"
                        ) = 0
                        AND u."EstablishmentID" IS NOT NULL
                        AND u."UserRoleValue" = 'Edit'
        ) as accountsWithoutPrimary;

SELECT
        DISTINCT ON (u."EstablishmentID") u."EstablishmentID",
        l."Username"
FROM
        cqc."User" u
        JOIN cqc."Login" l ON l."RegistrationID" = u."RegistrationID"
WHERE
        u."IsPrimary" = false
        AND (
                SELECT
                        count(*)
                FROM
                        cqc."User"
                WHERE
                        "IsPrimary" = true
                        AND "EstablishmentID" = u."EstablishmentID"
        ) = 0
        AND u."EstablishmentID" IS NOT NULL
        AND u."UserRoleValue" = 'Edit';

COMMIT;
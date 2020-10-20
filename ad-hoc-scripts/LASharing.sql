BEGIN;

CREATE OR REPLACE TEMPORARY VIEW LASHARING AS
SELECT
    LA."EstablishmentID"
FROM
    cqc."EstablishmentLocalAuthority" LA
INNER JOIN
    cqc."Establishment" Est ON Est."EstablishmentID" = LA."EstablishmentID"
WHERE
    Est."ShareDataWithLA" <> TRUE;

DELETE FROM
    cqc."EstablishmentLocalAuthority" LA
USING LASHARING
WHERE
    LASHARING."EstablishmentID" = LA."EstablishmentID"

COMMIT;

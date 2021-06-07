BEGIN;

SELECT
    COUNT(0)
FROM
    cqc."Establishment"
WHERE
    "DataOwner" = 'Parent'
    AND "IsParent" = true;

UPDATE
    cqc."Establishment"
SET
    "DataOwner" = 'Workplace'
WHERE
    "DataOwner" = 'Parent'
    AND "IsParent" = true;

SELECT
    COUNT(0)
FROM
    cqc."Establishment"
WHERE
    "DataOwner" = 'Parent'
    AND "IsParent" = true;

COMMIT;
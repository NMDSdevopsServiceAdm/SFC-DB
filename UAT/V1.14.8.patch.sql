BEGIN TRANSACTION;

SELECT id,name,iscqcregistered FROM cqc.services WHERE id = 16;

UPDATE cqc.services SET
iscqcregistered = NULL::boolean WHERE
id = 16;

SELECT id,name,iscqcregistered FROM cqc.services WHERE id = 16;

END TRANSACTION;
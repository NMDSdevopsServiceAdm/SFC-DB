BEGIN TRANSACTION;

UPDATE cqc.services SET
iscqcregistered = NULL::boolean WHERE
id = 16;

END TRANSACTION;
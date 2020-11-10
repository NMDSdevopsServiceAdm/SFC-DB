BEGIN;
    CREATE TEMPORARY VIEW dw AS 
    SELECT DISTINCT
        a."ID" 
    FROM 
        cqc."Worker" a,
        cqc."Worker" b 
    WHERE
        a."ID" > b."ID"
        AND a."LocalIdentifierValue" = b."LocalIdentifierValue"
        AND a."EstablishmentFK" = b."EstablishmentFK"
        AND a."EstablishmentFK" IN (SELECT "EstablishmentID" FROM cqc."Establishment" WHERE "ParentID" = '479') 
    ;
	SELECT COUNT(0) FROM cqc."WorkerAudit";
	DELETE FROM 
		cqc."WorkerAudit" audit
	USING dw 
    WHERE 
        dw."ID" = audit."WorkerFK"
    ;
    SELECT COUNT(0) FROM cqc."WorkerAudit";
    SELECT COUNT(0) FROM cqc."WorkerQualifications";
	DELETE FROM 
		cqc."WorkerQualifications" quals
	USING dw 
    WHERE 
        dw."ID" = quals."WorkerFK"
    ;
    SELECT COUNT(0) FROM cqc."WorkerQualifications";
    SELECT COUNT(0) FROM cqc."WorkerJobs";
	DELETE FROM 
		cqc."WorkerJobs" jobs
	USING dw 
    WHERE 
        dw."ID" = jobs."WorkerFK"
    ;
    SELECT COUNT(0) FROM cqc."WorkerJobs";
    SELECT COUNT(0) FROM cqc."WorkerTraining";
	DELETE FROM 
		cqc."WorkerTraining" training
    USING dw 
    WHERE 
        dw."ID" = training."WorkerFK"
    ;
	SELECT COUNT(0) FROM cqc."WorkerTraining";
	SELECT COUNT(0) FROM cqc."Worker";
	DELETE FROM 
	    cqc."Worker" a
    USING dw
    WHERE
        dw."ID" = a."ID"
  	;
	SELECT COUNT(0) FROM cqc."Worker";
COMMIT;
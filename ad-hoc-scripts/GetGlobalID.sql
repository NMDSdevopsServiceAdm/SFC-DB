SET SEARCH_PATH TO cqc;
Copy (
    SELECT 
        e."EstablishmentID" establishmentid,
        e."TribalID" tribalid,
        w."TribalID" tribalid_worker,
        w."ID" workerid, 
        UPPER(MD5(REPLACE("NationalInsuranceNumberValue",' ','') || TO_CHAR("DateOfBirthValue", 'YYYYMMDD'))) AS wrkglbid
    FROM "Establishment" e
        JOIN "Worker" w ON e."EstablishmentID" = w."EstablishmentFK" AND w."Archived" = false
    WHERE e."Archived" = false
) TO '/efs/sfc-db/marchgid.csv' With CSV DELIMITER ',' HEADER;

-- You can then run `aws s3 cp /efs/sfc-db/marchgid.csv s3://sfcreports` and download the file from S3
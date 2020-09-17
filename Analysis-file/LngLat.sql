BEGIN TRANSACTION;

-------------------
-- Turn timing on so we can see how long it took
-------------------
\timing

DROP TABLE IF EXISTS cqcref.postcodes;

SELECT 'Creating new postcodes table';

CREATE TABLE cqcref.postcodes (
    postcode character varying(10) COLLATE pg_catalog."C",
    longitude double precision,
    latitude double precision
);

SELECT 'Copy from CSV to the table';

\COPY cqcref.postcodes (postcode, longitude, latitude) FROM '/mnt/c/Users/arussell/Documents/Repos/SFC-DB/Analysis-file/postcodes.csv' WITH (FORMAT csv, ENCODING 'UTF8');

SELECT 'Update the workers lat and long depending on their postcode';

UPDATE cqc."Worker"  wrk
SET 
    (
        "Longitude",
        "Latitude"
    ) = (
        lnglat.longitude,
        lnglat.latitude
    )
FROM cqcref.postcodes lnglat
WHERE lnglat.postcode = wrk."PostcodeValue";

SELECT 'Update the workplaces lat and long depending on their postcode';

UPDATE cqc."Establishment"  est
SET 
    (
        "Longitude",
        "Latitude"
    ) = (
        lnglat.longitude,
        lnglat.latitude
    )
FROM cqcref.postcodes lnglat
WHERE lnglat.postcode = est."PostCode";

----------------
END TRANSACTION;
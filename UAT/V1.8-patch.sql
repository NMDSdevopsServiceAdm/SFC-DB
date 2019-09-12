-- V1.8 is post WDF Report and Revised Skeleton Record

-- identified during migration two missing countries in target database
-- LAOS and Isle of Man additional counties, but in alphabetical sequence
-- [Ilse of Man] increase sequence number after 117 (Ireland) but before (Israel)
update cqc."Country" set "Seq" = "Seq" + 1 where "ID" > 117;

-- [Laos] increase sequence number after ID=130 (Kyrgyzstan) but before (Latvia)
update cqc."Country" set "Seq" = "Seq" + 1 where "ID" > 130;

INSERT INTO cqc."Country" ("ID", "Seq", "Country") VALUES
	(260,118, 'Isle of Man'),
	(261,132, 'Lao People''s Democratic People');

-- https://trello.com/c/c0mR47WJ - Bulk Upload - Country of birth and Nationality mappings

-- additional countries
-- Bonaire, Sint Eustatius and Saba
-- Kosovo
-- Sint Maarten


-- Bonaire, Sint Eustatius and Saba (after current sequence 27)
update cqc."Country" set "Seq" = "Seq" + 1 where "Seq" >= 28;
INSERT INTO cqc."Country" ("ID", "Seq", "Country") VALUES
	(262,28, 'Bonaire, Sint Eustatius and Saba');


-- Kosovo (after new sequence 130)
update cqc."Country" set "Seq" = "Seq" + 1 where "Seq" >= 131;
INSERT INTO cqc."Country" ("ID", "Seq", "Country") VALUES
	(263,131, 'Kosovo');


-- Sint Maarten (after new sequence 215)
update cqc."Country" set "Seq" = "Seq" + 1 where "Seq" >= 214;
INSERT INTO cqc."Country" ("ID", "Seq", "Country") VALUES
	(264,214, 'Sint Maarten ');

-- https://trello.com/c/hJTONzW2 - Additional countries to be added in

-- correction to remove space at the end of Sint Maarten
update cqc."Country" set "Country"='Sint Maarten' where "ID"=264;

update cqc."Country" set "Seq" = "Seq" + 1 where "Seq" >= 58;
INSERT INTO cqc."Country" ("ID", "Seq", "Country") VALUES
	(265,58, 'Curacao');

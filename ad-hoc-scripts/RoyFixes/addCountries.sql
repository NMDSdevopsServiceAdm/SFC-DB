BEGIN;

SELECT COUNT(0) FROM cqc."Country";

insert into cqc."Country" ("ID", "Seq", "Country") values (267, 434, 'Libya');
insert into cqc."Country" ("ID", "Seq", "Country") values (268, 474, 'Matrinique');
insert into cqc."Country" ("ID", "Seq", "Country") values (269, 654, 'St Helena & Tristan da Cunha');

SELECT COUNT(0) FROM cqc."Country";

COMMIT;
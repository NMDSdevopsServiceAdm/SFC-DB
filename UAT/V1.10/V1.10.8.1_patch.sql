-- This is an optional patch only for those that ran the older version of the 1.10_8 patch which contained spelling errors in the enum

CREATE TYPE cqc."worker_registerednurses_enum" AS ENUM (
    'Adult Nurse',
    'Mental Health Nurse',
    'Learning Disabilities Nurse',
    'Children''s Nurse',
    'Enrolled Nurse'
);

ALTER TABLE cqc."Worker" DROP COLUMN "RegisteredNurseValue";
ALTER TABLE cqc."Worker" ADD COLUMN "RegisteredNurseValue" cqc."worker_registerednurses_enum" NULL;
DROP TYPE IF EXISTS cqc."worker_registerednurse_enum";

DELETE FROM cqc."NurseSpecialism";

insert into cqc."NurseSpecialism" ("ID", "Seq", "Specialism", "Other") values (1, 1, 'Older people (including dementia, elderly care and end of life care)', false);
insert into cqc."NurseSpecialism" ("ID", "Seq", "Specialism", "Other") values (2, 2, 'Adults', false);
insert into cqc."NurseSpecialism" ("ID", "Seq", "Specialism", "Other") values (3, 3, 'Learning Disability', false);
insert into cqc."NurseSpecialism" ("ID", "Seq", "Specialism", "Other") values (4, 4, 'Mental Health', false);
insert into cqc."NurseSpecialism" ("ID", "Seq", "Specialism", "Other") values (5, 5, 'Community Care', false);
insert into cqc."NurseSpecialism" ("ID", "Seq", "Specialism", "Other") values (6, 6, 'Others', true);
insert into cqc."NurseSpecialism" ("ID", "Seq", "Specialism", "Other") values (7, 7, 'Not applicable', false);
insert into cqc."NurseSpecialism" ("ID", "Seq", "Specialism", "Other") values (8, 8, 'Don''t know', false);
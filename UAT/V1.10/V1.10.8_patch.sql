-- https://trello.com/c/PkupZnCs/51-10-staff-records-2-nurse-specialism-question
-- https://trello.com/c/ZfLqpOJV/50-10-staff-records-1-nurse-category-question


CREATE TYPE cqc."worker_registerednurses_enum" AS ENUM (
    'Adult Nurse',
    'Mental Health Nurse',
    'Learning Disabilities Nurse',
    'Children''s Nurse',
    'Enrolled Nurse'
);

CREATE TABLE IF NOT EXISTS cqc."NurseSpecialism" (
	"ID" INTEGER NOT NULL PRIMARY KEY,
	"Seq" INTEGER NOT NULL, 	
	"Specialism" TEXT NOT NULL,
        "Other" BOOLEAN DEFAULT FALSE
);

ALTER TABLE cqc."Worker"   ADD COLUMN "RegisteredNurseValue" cqc."worker_registerednurses_enum" NULL;
ALTER TABLE cqc."Worker"   ADD COLUMN "RegisteredNurseSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Worker"   ADD COLUMN "RegisteredNurseChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Worker"   ADD COLUMN "RegisteredNurseSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."Worker"   ADD COLUMN "RegisteredNurseChangedBy" VARCHAR(120) NULL;

ALTER TABLE cqc."Worker"   ADD COLUMN "NurseSpecialismFKValue" INTEGER NULL;
ALTER TABLE cqc."Worker"   ADD COLUMN "NurseSpecialismFKOther" TEXT NULL;
ALTER TABLE cqc."Worker"   ADD COLUMN "NurseSpecialismFKSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Worker"   ADD COLUMN "NurseSpecialismFKChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."Worker"   ADD COLUMN "NurseSpecialismFKSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."Worker"   ADD COLUMN "NurseSpecialismFKChangedBy" VARCHAR(120) NULL;

insert into cqc."NurseSpecialism" ("ID", "Seq", "Specialism", "Other") values (1, 1, 'Older people (including dementia, elderly care and end of life care)', false);
insert into cqc."NurseSpecialism" ("ID", "Seq", "Specialism", "Other") values (2, 2, 'Adults', false);
insert into cqc."NurseSpecialism" ("ID", "Seq", "Specialism", "Other") values (3, 3, 'Learning Disability', false);
insert into cqc."NurseSpecialism" ("ID", "Seq", "Specialism", "Other") values (4, 4, 'Mental Health', false);
insert into cqc."NurseSpecialism" ("ID", "Seq", "Specialism", "Other") values (5, 5, 'Community Care', false);
insert into cqc."NurseSpecialism" ("ID", "Seq", "Specialism", "Other") values (6, 6, 'Others', true);
insert into cqc."NurseSpecialism" ("ID", "Seq", "Specialism", "Other") values (7, 7, 'Not applicable', false);
insert into cqc."NurseSpecialism" ("ID", "Seq", "Specialism", "Other") values (8, 8, 'Don''t know', false);
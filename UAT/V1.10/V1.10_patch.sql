-- https://trello.com/c/ikScd2O3 - parents & subs - view my workplaces

DROP TYPE IF EXISTS cqc.establishment_owner;
CREATE TYPE cqc.establishment_owner AS ENUM (
    'Workplace',
    'Parent'
);

DROP TYPE IF EXISTS cqc.establishment_parent_access_permission;
CREATE TYPE cqc.establishment_parent_access_permission AS ENUM (
    'Workplace',
    'Workplace and Staff'
);

ALTER TABLE cqc."Establishment" ADD COLUMN "Owner" cqc.establishment_owner NOT NULL DEFAULT 'Workplace';
ALTER TABLE cqc."Establishment" ADD COLUMN "ParentAccess" cqc.establishment_parent_access_permission NULL;

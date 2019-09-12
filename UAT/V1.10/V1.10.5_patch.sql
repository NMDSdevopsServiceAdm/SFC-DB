-- https://trello.com/c/QAzbzesV - Bulk Upload - Complete Upload/Import


--DROP TYPE IF EXISTS cqc."DataSource";
CREATE TYPE cqc."DataSource" AS ENUM (
    'Online',
    'Bulk'
);

ALTER TABLE cqc."Establishment" ADD COLUMN "DataSource" cqc."DataSource" DEFAULT 'Online';
ALTER TABLE cqc."Worker" ADD COLUMN "DataSource" cqc."DataSource" DEFAULT 'Online';
ALTER TABLE cqc."WorkerQualifications" ADD COLUMN "DataSource" cqc."DataSource" DEFAULT 'Online';
ALTER TABLE cqc."WorkerTraining" ADD COLUMN "DataSource" cqc."DataSource" DEFAULT 'Online';


ALTER TABLE cqc."Login" ADD COLUMN "TribalHash" VARCHAR(128) NULL;
ALTER TABLE cqc."Login" ADD COLUMN "TribalSalt" VARCHAR(50) NULL;
ALTER TABLE cqc."User" ADD COLUMN "TribalPasswordAnswer" VARCHAR(255) NULL;

ALTER TABLE cqc."Establishment" DROP CONSTRAINT estloc_fk;

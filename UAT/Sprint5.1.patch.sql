ALTER TABLE "cqc"."Establishment" ADD COLUMN "IsRegulatedSavedAt" TIMESTAMP WITH TIME ZONE;
ALTER TABLE "cqc"."Establishment" ADD COLUMN "IsRegulatedChangedAt" TIMESTAMP WITH TIME ZONE;
ALTER TABLE "cqc"."Establishment" ADD COLUMN "IsRegulatedSavedBy" TEXT;
ALTER TABLE "cqc"."Establishment" ADD COLUMN "IsRegulatedChangedBy" TEXT;
-- patch for Parent WDF Report - https://trello.com/c/A7jvk52i
ALTER TABLE cqc."Establishment" ADD COLUMN "CurrentWdfEligibility" boolean NULL;
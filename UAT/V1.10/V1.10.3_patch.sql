-- https://trello.com/c/Aykp0AHW - Bulk Upload - Load Data with backend validation - Back End

DROP TYPE IF EXISTS cqc."ServicesCapacityType";
CREATE TYPE cqc."ServicesCapacityType" AS ENUM (
    'Capacity',
    'Utilisation'
);
ALTER TABLE cqc."ServicesCapacity" ADD COLUMN "Type" cqc."ServicesCapacityType" default 'Capacity';

-- first update the default utilisation = question sequence=2
UPDATE 
	cqc."ServicesCapacity"
SET
	"Type"='Utilisation'
WHERE
	"Sequence" = 2;

-- now update the special case utilisations - where sequence number=1
UPDATE 
	cqc."ServicesCapacity"
SET
	"Type"='Utilisation'
WHERE
	"ServiceID" in (11, 13, 20, 23);

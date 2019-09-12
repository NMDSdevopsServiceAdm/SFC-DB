-- Allows update of Address1,2,3,Town and ProvID on existing migrated table
-- creates a new table for comparison then renames

drop table cqc."EstablishmentNew";

select eold.*,COALESCE(address1,eold."Address") as "Address1",address2 as "Address2",
address3 as "Address3",town as "Town",registrationid as "ProvID", null as "ReasonsForLeaving"
into table cqc."EstablishmentNew"
from cqc."Establishment" eold
left join establishment eorig on eold."TribalID"=eorig.id
left join provision p on p.establishment_id = eorig.id

alter table cqc."EstablishmentNew" drop column "Address";

alter table cqc."Establishment" rename to "EstablishmentOld"
alter table cqc."EstablishmentNew" rename to "Establishment"

Update cqc."Establishment" inse
set "MainServiceFKValue"=18 where inse."EstablishmentID" in (
SELECT newe."EstablishmentID",ms.sfcid,e.id,newe."NmdsID",newe."MainServiceFKValue",e.nmdsid,s.name,pst.servicetype_id
    FROM establishment e
left join cqc."Establishment" newe on e.id=newe."TribalID"
      INNER JOIN provision p
        INNER JOIN provision_servicetype pst
		  INNER JOIN migration.services ms ON pst.servicetype_id = ms.tribalid
          ON pst.provision_id = p.id and pst.ismainservice = 1
        ON p.establishment_id = e.id
join cqc."services" s on s.id=ms.sfcid
		WHERE servicetype_id IN (9,11,23,40,50,57,65))
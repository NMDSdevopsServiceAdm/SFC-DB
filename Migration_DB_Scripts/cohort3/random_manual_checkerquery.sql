select e."NmdsID",e."Address1",e."Address2",e."Address3",e."Town",e."County",e."PostCode",
a."CssR",c."LocalCustodianCode",c."Region",
e."LastBulkUploaded",e."updated",
(select max("SocialCareQualificationFKSavedAt")
 from cqc."Worker" w where w."EstablishmentFK"=e."EstablishmentID") as "Max SC SavedAt",
(select max("SocialCareQualificationFKChangedAt")
 from cqc."Worker" w where w."EstablishmentFK"=e."EstablishmentID") as "Max SC ChangedAt",
(select max("OtherQualificationsSavedAt")
 from cqc."Worker" w where w."EstablishmentFK"=e."EstablishmentID") as "Max Other SavedAt",
(select max("OtherQualificationsChangedAt")
 from cqc."Worker" w where w."EstablishmentFK"=e."EstablishmentID") as "Max Other ChangedAt"

from cqc."Establishment" e
join cqc."EstablishmentLocalAuthority" a on e."EstablishmentID"=a."EstablishmentID"
join cqc."Cssr" c on c."CssrID"=a."CssrID"
order by random()
limit 1000

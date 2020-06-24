insert into cqc."Approvals" values()

INSERT INTO cqc."Approvals"(
"ID", "UUID", "EstablishmentID", "UserID", "ApprovalType", "Status", "RejectionReason", "Data", "createdAt", "updatedAt")
VALUES 
(0001, 'b9059590-cec8-4b83-9c97-700f64b5a4fa', 1635, 1249, 'BecomeAParent', 'Pending', '', null, '2020-05-21 09:25:12.896+01', null);


INSERT INTO cqc."Approvals"(
"UUID", "EstablishmentID", "UserID", "ApprovalType", "Status", "RejectionReason", "Data", "createdAt", "updatedAt")
VALUES 
('bbd54f18-f0bd-4fc2-893d-e492faa9b278', 508,   1011, 'BecomeAParent', 'Pending', '', null, '2020-05-21 09:25:12.896+01', null),
('ad1c2f50-3d13-4832-8773-648ee4ddb73d', 1636,  1052, 'BecomeAParent', 'Pending', '', null, '2020-05-20 09:25:12.896+01', null),
('360c62a1-2e20-410d-a72b-9d4100a11f4e', 530,   618, 'BecomeAParent', 'Pending', '', null, '2020-05-19 09:25:12.896+01', null),
('f61696f7-30fe-441c-9c59-e25dfcb51f59', 1637,  619, 'BecomeAParent', 'Pending', '', null, '2020-05-18 09:25:12.896+01', null),
('749f062d-afea-4ab5-b266-63d9568ce604', 850,   620, 'BecomeAParent', 'Pending', '', null, '2020-05-17 09:25:12.896+01', null),
('1bf4c5ef-b3a3-4d73-8b24-5df35475ed2c', 1639,  621, 'BecomeAParent', 'Pending', '', null, '2020-05-16 09:25:12.896+01', null),
('a2c43c23-861d-4848-b80b-05854093d18c', 644,   622, 'BecomeAParent', 'Pending', '', null, '2020-05-15 09:25:12.896+01', null),
('9efce151-6167-4e99-9cbf-0b9f8ab987fa', 1640,  623, 'BecomeAParent', 'Pending', '', null, '2020-05-14 09:25:12.896+01', null),
('86410d52-0440-4225-947a-b7a2dad54cd8', 1641,  624, 'BecomeAParent', 'Pending', '', null, '2020-05-13 09:25:12.896+01', null),
('1d8dbb76-c924-4bde-95df-88a592dac6b2', 1642,  625, 'BecomeAParent', 'Pending', '', null, '2020-05-12 09:25:12.896+01', null);

update cqc."Approvals" set "Status" = 'Pending'
where "UUID" = 'bbd54f18-f0bd-4fc2-893d-e492faa9b278'

update cqc."Approvals" set "EstablishmentID" = 508
where "UUID" = 'bbd54f18-f0bd-4fc2-893d-e492faa9b278'

select 
	app."ID",
	app."UUID",
	app."ApprovalType",
	app."Status",
	estab."NameValue",
	estab."IsParent",
	usr."FullNameValue",
	estab."NmdsID"
from 
	cqc."Approvals" app
inner join
	cqc."Establishment" estab on estab."EstablishmentID" = app."EstablishmentID"
inner join
	cqc."User" usr on usr."RegistrationID" = app."UserID"

----------------------------
-- autem maiores occaecati expedita
-- Hanna Gerhold
-- approved
----------------------------
-- omnis voluptatem deleniti aliquam
-- Sabina Crooks
-- rejected
----------------------------

INSERT INTO cqc."Approvals"(
"UUID", "EstablishmentID", "UserID", "ApprovalType", "Status", "RejectionReason", "Data", "createdAt", "updatedAt")
VALUES 
('579efbc4-d8cb-4432-8bf9-447cc951f2e4', 2470,   2124, 'CqcStatusChange', 'Pending', '', null, '2020-05-21 09:25:12.896+01', null);
--------------------
UPDATE cqc."Approvals" SET "Status" = 'Pending' WHERE "UUID" = '579efbc4-d8cb-4432-8bf9-447cc951f2e4';
--------------------
select 
	login."Username" as LoginName,
	usr."FullNameValue" as UserName,
	usr."RegistrationID",
	estab."NameValue" as EstabName,
	usr."EstablishmentID",
    estab."NmdsID" as WorkplaceId
from 
	cqc."Login" login
inner join
	cqc."User" usr on usr."RegistrationID" = login."RegistrationID"
inner join
	cqc."Establishment" estab on usr."EstablishmentID" = estab."EstablishmentID"
where
	estab."NmdsID" = 'I1003138'
----------------------
SELECT * FROM cqc."Approvals" WHERE "EstablishmentID" = '2470';


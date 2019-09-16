-- this is an accummulative patch sql file that will be built up on each successive deployment in to sfctstdb
--  making it easier to apply patches to UAT DB after multiple deploys into sfctstdb

-- correct bad data in the UAT target database
delete from cqc."Login" where "RegistrationID" in (select "RegistrationID" from cqc."User" where "EstablishmentID" in (select "EstablishmentID" from cqc."Establishment" where "PostCode" = 'MK18 2LB'));


delete from cqc."User" where "EstablishmentID" in (select "EstablishmentID" from cqc."Establishment" where "PostCode" = 'MK18 2LB');
delete from cqc."EstablishmentCapacity" where "EstablishmentID" in (select "EstablishmentID" from cqc."Establishment" where "PostCode" = 'MK18 2LB');
delete from cqc."EstablishmentJobs" where "EstablishmentID" in (select "EstablishmentID" from cqc."Establishment" where "PostCode" = 'MK18 2LB');
delete from cqc."EstablishmentLocalAuthority" where "EstablishmentID" in (select "EstablishmentID" from cqc."Establishment" where "PostCode" = 'MK18 2LB');
delete from cqc."EstablishmentServices" where "EstablishmentID" in (select "EstablishmentID" from cqc."Establishment" where "PostCode" = 'MK18 2LB');
delete from cqc."Establishment" where "PostCode" = 'MK18 2LB';


delete from cqc."Login" where "RegistrationID"=351;
delete from cqc."User" where "EstablishmentID"=371;
delete from cqc."EstablishmentCapacity" where "EstablishmentID"=371;
delete from cqc."EstablishmentJobs" where "EstablishmentID"=371;
delete from cqc."EstablishmentLocalAuthority" where "EstablishmentID"=371;
delete from cqc."EstablishmentServices" where "EstablishmentID"=371;
delete from cqc."Establishment" where "EstablishmentID"=371;

delete from cqc."Login" where "RegistrationID"=343;
delete from cqc."User" where "EstablishmentID"=363;
delete from cqc."EstablishmentCapacity" where "EstablishmentID"=363;
delete from cqc."EstablishmentJobs" where "EstablishmentID"=363;
delete from cqc."EstablishmentLocalAuthority" where "EstablishmentID"=363;
delete from cqc."EstablishmentServices" where "EstablishmentID"=363;
delete from cqc."Establishment" where "EstablishmentID"=363;

update cqc."Establishment" set "PostCode" = 'DN4 6HB' where "EstablishmentID"=309;

--- to apply DB patach for https://trello.com/c/BqSXEWI5
ALTER TABLE cqc."EstablishmentLocalAuthority" DROP CONSTRAINT localauthrity_establishmentlocalauthority_fk;
DROP TABLE cqc."LocalAuthority";

---CSSR TABLE CREATION
CREATE TABLE cqc."Cssr"
(
    "CssrID" INTEGER NOT NULL,
    "CssR" TEXT COLLATE pg_catalog."default" NOT NULL,
    "LocalAuthority" TEXT NOT NULL,
    "LocalCustodianCode" integer NOT NULL,
    "Region" TEXT COLLATE pg_catalog."default" NOT NULL,
    "RegionID" INTEGER NOT NULL,
    "NmdsIDLetter" CHARACTER(1) COLLATE pg_catalog."default" NOT NULL,
    PRIMARY KEY ("CssrID", "LocalCustodianCode")
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;
--ALTER TABLE cqc."Cssr" OWNER TO sfcadmin;

INSERT INTO cqc."Cssr" ("CssrID", "CssR", "LocalAuthority", "LocalCustodianCode", "Region", "RegionID", "NmdsIDLetter") VALUES
(807, 'West Sussex', 'Adur', 3805, 'South East', 6, 'H'),
(102, 'Cumbria', 'Allerdale', 905, 'North West', 5, 'F'),
(506, 'Derbyshire', 'Amber Valley', 1005, 'East Midlands', 2, 'C'),
(807, 'West Sussex', 'Arun', 3810, 'South East', 6, 'H'),
(511, 'Nottinghamshire', 'Ashfield', 3005, 'East Midlands', 2, 'C'),
(820, 'Kent', 'Ashford', 2205, 'South East', 6, 'H'),
(612, 'Buckinghamshire', 'Aylesbury Vale', 405, 'South East', 6, 'H'),
(609, 'Suffolk', 'Babergh', 3505, 'Eastern', 1, 'I'),
(716, 'Barking & Dagenham', 'Barking and Dagenham', 5060, 'London', 3, 'G'),
(717, 'Barnet', 'Barnet', 5090, 'London', 3, 'G'),
(204, 'Barnsley', 'Barnsley', 4405, 'Yorkshire and the Humber', 9, 'J'),
(102, 'Cumbria', 'Barrow-in-Furness', 910, 'North West', 5, 'F'),
(620, 'Essex', 'Basildon', 1505, 'Eastern', 1, 'I'),
(812, 'Hampshire', 'Basingstoke and Deane', 1705, 'South East', 6, 'H'),
(511, 'Nottinghamshire', 'Bassetlaw', 3010, 'East Midlands', 2, 'C'),
(908, 'Bath and North East Somerset', 'Bath and North East Somerset', 114, 'South West', 7, 'D'),
(996, 'Bedford', 'Bedford', 235, 'Eastern', 1, 'I'),
(718, 'Bexley', 'Bexley', 5120, 'London', 3, 'G'),
(406, 'Birmingham', 'Birmingham', 4605, 'West Midlands', 8, 'E'),
(508, 'Leicestershire', 'Blaby', 2405, 'East Midlands', 2, 'C'),
(324, 'Blackburn with Darwen', 'Blackburn with Darwen', 2372, 'North West', 5, 'F'),
(325, 'Blackpool', 'Blackpool', 2373, 'North West', 5, 'F'),
(506, 'Derbyshire', 'Bolsover', 1010, 'East Midlands', 2, 'C'),
(304, 'Bolton', 'Bolton', 4205, 'North West', 5, 'F'),
(503, 'Lincolnshire', 'Boston', 2505, 'East Midlands', 2, 'C'),
(810, 'Bournemouth', 'Bournemouth', 1250, 'South West', 7, 'D'),
(614, 'Bracknell Forest', 'Bracknell Forest', 335, 'South East', 6, 'H'),
(209, 'Bradford', 'Bradford', 4705, 'Yorkshire and the Humber', 9, 'J'),
(620, 'Essex', 'Braintree', 1510, 'Eastern', 1, 'I'),
(607, 'Norfolk', 'Breckland', 2605, 'Eastern', 1, 'I'),
(719, 'Brent', 'Brent', 5150, 'London', 3, 'G'),
(620, 'Essex', 'Brentwood', 1515, 'Eastern', 1, 'I'),
(816, 'Brighton & Hove', 'Brighton and Hove', 1445, 'South East', 6, 'H'),
(607, 'Norfolk', 'Broadland', 2610, 'Eastern', 1, 'I'),
(720, 'Bromley', 'Bromley', 5180, 'London', 3, 'G'),
(416, 'Worcestershire', 'Bromsgrove', 1805, 'West Midlands', 8, 'E'),
(606, 'Hertfordshire', 'Broxbourne', 1905, 'Eastern', 1, 'I'),
(511, 'Nottinghamshire', 'Broxtowe', 3015, 'East Midlands', 2, 'C'),
(323, 'Lancashire', 'Burnley', 2315, 'North West', 5, 'F'),
(305, 'Bury', 'Bury', 4210, 'North West', 5, 'F'),
(210, 'Calderdale', 'Calderdale', 4710, 'Yorkshire and the Humber', 9, 'J'),
(623, 'Cambridgeshire', 'Cambridge', 505, 'Eastern', 1, 'I'),
(702, 'Camden', 'Camden', 5210, 'London', 3, 'G'),
(413, 'Staffordshire', 'Cannock Chase', 3405, 'West Midlands', 8, 'E'),
(820, 'Kent', 'Canterbury', 2210, 'South East', 6, 'H'),
(102, 'Cumbria', 'Carlisle', 915, 'North West', 5, 'F'),
(620, 'Essex', 'Castle Point', 1520, 'Eastern', 1, 'I'),
(997, 'Central Bedfordshire', 'Central Bedfordshire', 240, 'Eastern', 1, 'I'),
(508, 'Leicestershire', 'Charnwood', 2410, 'East Midlands', 2, 'C'),
(620, 'Essex', 'Chelmsford', 1525, 'Eastern', 1, 'I'),
(904, 'Gloucestershire', 'Cheltenham', 1605, 'South West', 7, 'D'),
(608, 'Oxfordshire', 'Cherwell', 3105, 'South East', 6, 'H'),
(998, 'Cheshire East', 'Cheshire East', 660, 'North West', 5, 'F'),
(999, 'Cheshire West & Chester', 'Cheshire West and Chester', 665, 'North West', 5, 'F'),
(506, 'Derbyshire', 'Chesterfield', 1015, 'East Midlands', 2, 'C'),
(807, 'West Sussex', 'Chichester', 3815, 'South East', 6, 'H'),
(612, 'Buckinghamshire', 'Chiltern', 415, 'South East', 6, 'H'),
(323, 'Lancashire', 'Chorley', 2320, 'North West', 5, 'F'),
(809, 'Dorset', 'Christchurch', 1210, 'South West', 7, 'D'),
(909, 'Bristol', 'City of Bristol', 116, 'South West', 7, 'D'),
(714, 'City of London', 'City of London', 5030, 'London', 3, 'G'),
(620, 'Essex', 'Colchester', 1530, 'Eastern', 1, 'I'),
(102, 'Cumbria', 'Copeland', 920, 'North West', 5, 'F'),
(504, 'Northamptonshire', 'Corby', 2805, 'East Midlands', 2, 'C'),
(902, 'Cornwall', 'Cornwall', 840, 'South West', 7, 'D'),
(904, 'Gloucestershire', 'Cotswold', 1610, 'South West', 7, 'D'),
(116, 'Durham', 'County Durham', 1355, 'North East', 4, 'B'),
(407, 'Coventry', 'Coventry', 4610, 'West Midlands', 8, 'E'),
(218, 'North Yorkshire', 'Craven', 2705, 'Yorkshire and the Humber', 9, 'J'),
(807, 'West Sussex', 'Crawley', 3820, 'South East', 6, 'H'),
(721, 'Croydon', 'Croydon', 5240, 'London', 3, 'G'),
(606, 'Hertfordshire', 'Dacorum', 1910, 'Eastern', 1, 'I'),
(117, 'Darlington', 'Darlington', 1350, 'North East', 4, 'B'),
(820, 'Kent', 'Dartford', 2215, 'South East', 6, 'H'),
(504, 'Northamptonshire', 'Daventry', 2810, 'East Midlands', 2, 'C'),
(507, 'Derby', 'Derby', 1055, 'East Midlands', 2, 'C'),
(506, 'Derbyshire', 'Derbyshire Dales', 1045, 'East Midlands', 2, 'C'),
(205, 'Doncaster', 'Doncaster', 4410, 'Yorkshire and the Humber', 9, 'J'),
(820, 'Kent', 'Dover', 2220, 'South East', 6, 'H'),
(408, 'Dudley', 'Dudley', 4615, 'West Midlands', 8, 'E'),
(722, 'Ealing', 'Ealing', 5270, 'London', 3, 'G'),
(623, 'Cambridgeshire', 'East Cambridgeshire', 510, 'Eastern', 1, 'I'),
(912, 'Devon', 'East Devon', 1105, 'South West', 7, 'D'),
(809, 'Dorset', 'East Dorset', 1240, 'South West', 7, 'D'),
(812, 'Hampshire', 'East Hampshire', 1710, 'South East', 6, 'H'),
(606, 'Hertfordshire', 'East Hertfordshire', 1915, 'Eastern', 1, 'I'),
(503, 'Lincolnshire', 'East Lindsey', 2510, 'East Midlands', 2, 'C'),
(504, 'Northamptonshire', 'East Northamptonshire', 2815, 'East Midlands', 2, 'C'),
(214, 'East Riding of Yorkshire', 'East Riding of Yorkshire', 2001, 'Yorkshire and the Humber', 9, 'J'),
(413, 'Staffordshire', 'East Staffordshire', 3410, 'West Midlands', 8, 'E'),
(815, 'East Sussex', 'Eastbourne', 1410, 'South East', 6, 'H'),
(812, 'Hampshire', 'Eastleigh', 1715, 'South East', 6, 'H'),
(102, 'Cumbria', 'Eden', 925, 'North West', 5, 'F'),
(805, 'Surrey', 'Elmbridge', 3605, 'South East', 6, 'H'),
(723, 'Enfield', 'Enfield', 5300, 'London', 3, 'G'),
(620, 'Essex', 'Epping Forest', 1535, 'Eastern', 1, 'I'),
(805, 'Surrey', 'Epsom and Ewell', 3610, 'South East', 6, 'H'),
(506, 'Derbyshire', 'Erewash', 1025, 'East Midlands', 2, 'C'),
(912, 'Devon', 'Exeter', 1110, 'South West', 7, 'D'),
(812, 'Hampshire', 'Fareham', 1720, 'South East', 6, 'H'),
(623, 'Cambridgeshire', 'Fenland', 515, 'Eastern', 1, 'I'),
(609, 'Suffolk', 'Forest Heath', 3510, 'Eastern', 1, 'I'),
(904, 'Gloucestershire', 'Forest of Dean', 1615, 'South West', 7, 'D'),
(323, 'Lancashire', 'Fylde', 2325, 'North West', 5, 'F'),
(106, 'Gateshead', 'Gateshead', 4505, 'North East', 4, 'B'),
(511, 'Nottinghamshire', 'Gedling', 3020, 'East Midlands', 2, 'C'),
(904, 'Gloucestershire', 'Gloucester', 1620, 'South West', 7, 'D'),
(812, 'Hampshire', 'Gosport', 1725, 'South East', 6, 'H'),
(820, 'Kent', 'Gravesham', 2230, 'South East', 6, 'H'),
(607, 'Norfolk', 'Great Yarmouth', 2615, 'Eastern', 1, 'I'),
(703, 'Greenwich', 'Greenwich', 5330, 'London', 3, 'G'),
(805, 'Surrey', 'Guildford', 3615, 'South East', 6, 'H'),
(704, 'Hackney', 'Hackney', 5360, 'London', 3, 'G'),
(321, 'Halton', 'Halton', 650, 'North West', 5, 'F'),
(218, 'North Yorkshire', 'Hambleton', 2710, 'Yorkshire and the Humber', 9, 'J'),
(705, 'Hammersmith & Fulham', 'Hammersmith and Fulham', 5390, 'London', 3, 'G'),
(508, 'Leicestershire', 'Harborough', 2415, 'East Midlands', 2, 'C'),
(724, 'Haringey', 'Haringey', 5420, 'London', 3, 'G'),
(620, 'Essex', 'Harlow', 1540, 'Eastern', 1, 'I'),
(218, 'North Yorkshire', 'Harrogate', 2715, 'Yorkshire and the Humber', 9, 'J'),
(725, 'Harrow', 'Harrow', 5450, 'London', 3, 'G'),
(812, 'Hampshire', 'Hart', 1730, 'South East', 6, 'H'),
(111, 'Hartlepool', 'Hartlepool', 724, 'North East', 4, 'B'),
(815, 'East Sussex', 'Hastings', 1415, 'South East', 6, 'H'),
(812, 'Hampshire', 'Havant', 1735, 'South East', 6, 'H'),
(726, 'Havering', 'Havering', 5480, 'London', 3, 'G'),
(415, 'Herefordshire', 'Herefordshire', 1850, 'West Midlands', 8, 'E'),
(606, 'Hertfordshire', 'Hertsmere', 1920, 'Eastern', 1, 'I'),
(506, 'Derbyshire', 'High Peak', 1030, 'East Midlands', 2, 'C'),
(727, 'Hillingdon', 'Hillingdon', 5510, 'London', 3, 'G'),
(508, 'Leicestershire', 'Hinckley and Bosworth', 2420, 'East Midlands', 2, 'C'),
(807, 'West Sussex', 'Horsham', 3825, 'South East', 6, 'H'),
(728, 'Hounslow', 'Hounslow', 5540, 'London', 3, 'G'),
(623, 'Cambridgeshire', 'Huntingdonshire', 520, 'Eastern', 1, 'I'),
(323, 'Lancashire', 'Hyndburn', 2330, 'North West', 5, 'F'),
(609, 'Suffolk', 'Ipswich', 3515, 'Eastern', 1, 'I'),
(803, 'Isle of Wight', 'Isle of Wight', 2114, 'South East', 6, 'H'),
(906, 'Isles of Scilly', 'Isles of Scilly', 835, 'South West', 7, 'D'),
(706, 'Islington', 'Islington', 5570, 'London', 3, 'G'),
(707, 'Kensington & Chelsea', 'Kensington and Chelsea', 5600, 'London', 3, 'G'),
(504, 'Northamptonshire', 'Kettering', 2820, 'East Midlands', 2, 'C'),
(607, 'Norfolk', 'King`s Lynn and West Norfolk', 2635, 'Eastern', 1, 'I'),
(215, 'Kingston upon Hull', 'Kingston upon Hull', 2004, 'Yorkshire and the Humber', 9, 'J'),
(729, 'Kingston upon Thames', 'Kingston upon Thames', 5630, 'London', 3, 'G'),
(211, 'Kirklees', 'Kirklees', 4715, 'Yorkshire and the Humber', 9, 'J'),
(315, 'Knowsley', 'Knowsley', 4305, 'North West', 5, 'F'),
(708, 'Lambeth', 'Lambeth', 5660, 'London', 3, 'G'),
(323, 'Lancashire', 'Lancaster', 2335, 'North West', 5, 'F'),
(212, 'Leeds', 'Leeds', 4720, 'Yorkshire and the Humber', 9, 'J'),
(509, 'Leicester', 'Leicester', 2465, 'East Midlands', 2, 'C'),
(815, 'East Sussex', 'Lewes', 1425, 'South East', 6, 'H'),
(709, 'Lewisham', 'Lewisham', 5690, 'London', 3, 'G'),
(413, 'Staffordshire', 'Lichfield', 3415, 'West Midlands', 8, 'E'),
(503, 'Lincolnshire', 'Lincoln', 2515, 'East Midlands', 2, 'C'),
(316, 'Liverpool', 'Liverpool', 4310, 'North West', 5, 'F'),
(611, 'Luton', 'Luton', 230, 'Eastern', 1, 'I'),
(820, 'Kent', 'Maidstone', 2235, 'South East', 6, 'H'),
(620, 'Essex', 'Maldon', 1545, 'Eastern', 1, 'I'),
(416, 'Worcestershire', 'Malvern Hills', 1820, 'West Midlands', 8, 'E'),
(306, 'Manchester', 'Manchester', 4215, 'North West', 5, 'F'),
(511, 'Nottinghamshire', 'Mansfield', 3025, 'East Midlands', 2, 'C'),
(821, 'Medway', 'Medway', 2280, 'South East', 6, 'H'),
(508, 'Leicestershire', 'Melton', 2430, 'East Midlands', 2, 'C'),
(905, 'Somerset', 'Mendip', 3305, 'South West', 7, 'D'),
(730, 'Merton', 'Merton', 5720, 'London', 3, 'G'),
(912, 'Devon', 'Mid Devon', 1135, 'South West', 7, 'D'),
(609, 'Suffolk', 'Mid Suffolk', 3520, 'Eastern', 1, 'I'),
(807, 'West Sussex', 'Mid Sussex', 3830, 'South East', 6, 'H'),
(112, 'Middlesbrough', 'Middlesbrough', 734, 'North East', 4, 'B'),
(613, 'Milton Keynes', 'Milton Keynes', 435, 'South East', 6, 'H'),
(805, 'Surrey', 'Mole Valley', 3620, 'South East', 6, 'H'),
(812, 'Hampshire', 'New Forest', 1740, 'South East', 6, 'H'),
(511, 'Nottinghamshire', 'Newark and Sherwood', 3030, 'East Midlands', 2, 'C'),
(107, 'Newcastle upon Tyne', 'Newcastle upon Tyne', 4510, 'North East', 4, 'B'),
(413, 'Staffordshire', 'Newcastle-under-Lyme', 3420, 'West Midlands', 8, 'E'),
(731, 'Newham', 'Newham', 5750, 'London', 3, 'G'),
(912, 'Devon', 'North Devon', 1115, 'South West', 7, 'D'),
(809, 'Dorset', 'North Dorset', 1215, 'South West', 7, 'D'),
(506, 'Derbyshire', 'North East Derbyshire', 1035, 'East Midlands', 2, 'C'),
(216, 'North East Lincolnshire', 'North East Lincolnshire', 2002, 'Yorkshire and the Humber', 9, 'J'),
(606, 'Hertfordshire', 'North Hertfordshire', 1925, 'Eastern', 1, 'I'),
(503, 'Lincolnshire', 'North Kesteven', 2520, 'East Midlands', 2, 'C'),
(217, 'North Lincolnshire', 'North Lincolnshire', 2003, 'Yorkshire and the Humber', 9, 'J'),
(607, 'Norfolk', 'North Norfolk', 2620, 'Eastern', 1, 'I'),
(910, 'North Somerset', 'North Somerset', 121, 'South West', 7, 'D'),
(108, 'North Tyneside', 'North Tyneside', 4515, 'North East', 4, 'B'),
(404, 'Warwickshire', 'North Warwickshire', 3705, 'West Midlands', 8, 'E'),
(508, 'Leicestershire', 'North West Leicestershire', 2435, 'East Midlands', 2, 'C'),
(504, 'Northamptonshire', 'Northampton', 2825, 'East Midlands', 2, 'C'),
(104, 'Northumberland', 'Northumberland', 2935, 'North East', 4, 'B'),
(607, 'Norfolk', 'Norwich', 2625, 'Eastern', 1, 'I'),
(512, 'Nottingham', 'Nottingham', 3060, 'East Midlands', 2, 'C'),
(404, 'Warwickshire', 'Nuneaton and Bedworth', 3710, 'West Midlands', 8, 'E'),
(508, 'Leicestershire', 'Oadby and Wigston', 2440, 'East Midlands', 2, 'C'),
(307, 'Oldham', 'Oldham', 4220, 'North West', 5, 'F'),
(608, 'Oxfordshire', 'Oxford', 3110, 'South East', 6, 'H'),
(323, 'Lancashire', 'Pendle', 2340, 'North West', 5, 'F'),
(624, 'Peterborough', 'Peterborough', 540, 'Eastern', 1, 'I'),
(913, 'Plymouth', 'Plymouth', 1160, 'South West', 7, 'D'),
(811, 'Poole', 'Poole', 1255, 'South West', 7, 'D'),
(813, 'Portsmouth', 'Portsmouth', 1775, 'South East', 6, 'H'),
(323, 'Lancashire', 'Preston', 2345, 'North West', 5, 'F'),
(809, 'Dorset', 'Purbeck', 1225, 'South West', 7, 'D'),
(616, 'Reading', 'Reading', 345, 'South East', 6, 'H'),
(732, 'Redbridge', 'Redbridge', 5780, 'London', 3, 'G'),
(113, 'Redcar & Cleveland', 'Redcar and Cleveland', 728, 'North East', 4, 'B'),
(416, 'Worcestershire', 'Redditch', 1825, 'West Midlands', 8, 'E'),
(805, 'Surrey', 'Reigate and Banstead', 3625, 'South East', 6, 'H'),
(323, 'Lancashire', 'Ribble Valley', 2350, 'North West', 5, 'F'),
(733, 'Richmond upon Thames', 'Richmond upon Thames', 5810, 'London', 3, 'G'),
(218, 'North Yorkshire', 'Richmondshire', 2720, 'Yorkshire and the Humber', 9, 'J'),
(308, 'Rochdale', 'Rochdale', 4225, 'North West', 5, 'F'),
(620, 'Essex', 'Rochford', 1550, 'Eastern', 1, 'I'),
(323, 'Lancashire', 'Rossendale', 2355, 'North West', 5, 'F'),
(815, 'East Sussex', 'Rother', 1430, 'South East', 6, 'H'),
(206, 'Rotherham', 'Rotherham', 4415, 'Yorkshire and the Humber', 9, 'J'),
(404, 'Warwickshire', 'Rugby', 3715, 'West Midlands', 8, 'E'),
(805, 'Surrey', 'Runnymede', 3630, 'South East', 6, 'H'),
(511, 'Nottinghamshire', 'Rushcliffe', 3040, 'East Midlands', 2, 'C'),
(812, 'Hampshire', 'Rushmoor', 1750, 'South East', 6, 'H'),
(510, 'Rutland', 'Rutland', 2470, 'East Midlands', 2, 'C'),
(218, 'North Yorkshire', 'Ryedale', 2725, 'Yorkshire and the Humber', 9, 'J'),
(309, 'Salford', 'Salford', 4230, 'North West', 5, 'F'),
(409, 'Sandwell', 'Sandwell', 4620, 'West Midlands', 8, 'E'),
(218, 'North Yorkshire', 'Scarborough', 2730, 'Yorkshire and the Humber', 9, 'J'),
(905, 'Somerset', 'Sedgemoor', 3310, 'South West', 7, 'D'),
(317, 'Sefton', 'Sefton', 4320, 'North West', 5, 'F'),
(218, 'North Yorkshire', 'Selby', 2735, 'Yorkshire and the Humber', 9, 'J'),
(820, 'Kent', 'Sevenoaks', 2245, 'South East', 6, 'H'),
(207, 'Sheffield', 'Sheffield', 4420, 'Yorkshire and the Humber', 9, 'J'),
(820, 'Kent', 'Shepway', 2250, 'South East', 6, 'H'),
(417, 'Shropshire', 'Shropshire', 3245, 'West Midlands', 8, 'E'),
(617, 'Slough', 'Slough', 350, 'South East', 6, 'H'),
(410, 'Solihull', 'Solihull', 4625, 'West Midlands', 8, 'E'),
(612, 'Buckinghamshire', 'South Bucks', 410, 'South East', 6, 'H'),
(623, 'Cambridgeshire', 'South Cambridgeshire', 530, 'Eastern', 1, 'I'),
(506, 'Derbyshire', 'South Derbyshire', 1040, 'East Midlands', 2, 'C'),
(911, 'South Gloucestershire', 'South Gloucestershire', 119, 'South West', 7, 'D'),
(912, 'Devon', 'South Hams', 1125, 'South West', 7, 'D'),
(503, 'Lincolnshire', 'South Holland', 2525, 'East Midlands', 2, 'C'),
(503, 'Lincolnshire', 'South Kesteven', 2530, 'East Midlands', 2, 'C'),
(102, 'Cumbria', 'South Lakeland', 930, 'North West', 5, 'F'),
(607, 'Norfolk', 'South Norfolk', 2630, 'Eastern', 1, 'I'),
(504, 'Northamptonshire', 'South Northamptonshire', 2830, 'East Midlands', 2, 'C'),
(608, 'Oxfordshire', 'South Oxfordshire', 3115, 'South East', 6, 'H'),
(323, 'Lancashire', 'South Ribble', 2360, 'North West', 5, 'F'),
(905, 'Somerset', 'South Somerset', 3325, 'South West', 7, 'D'),
(413, 'Staffordshire', 'South Staffordshire', 3430, 'West Midlands', 8, 'E'),
(109, 'South Tyneside', 'South Tyneside', 4520, 'North East', 4, 'B'),
(814, 'Southampton', 'Southampton', 1780, 'South East', 6, 'H'),
(621, 'Southend on Sea', 'Southend-on-Sea', 1590, 'Eastern', 1, 'I'),
(710, 'Southwark', 'Southwark', 5840, 'London', 3, 'G'),
(805, 'Surrey', 'Spelthorne', 3635, 'South East', 6, 'H'),
(606, 'Hertfordshire', 'St Albans', 1930, 'Eastern', 1, 'I'),
(609, 'Suffolk', 'St. Edmundsbury', 3525, 'Eastern', 1, 'I'),
(318, 'St Helens', 'St. Helens', 4315, 'North West', 5, 'F'),
(413, 'Staffordshire', 'Stafford', 3425, 'West Midlands', 8, 'E'),
(413, 'Staffordshire', 'Staffordshire Moorlands', 3435, 'West Midlands', 8, 'E'),
(606, 'Hertfordshire', 'Stevenage', 1935, 'Eastern', 1, 'I'),
(310, 'Stockport', 'Stockport', 4235, 'North West', 5, 'F'),
(114, 'Stockton on Tees', 'Stockton-on-Tees', 738, 'North East', 4, 'B'),
(414, 'Stoke on Trent', 'Stoke-on-Trent', 3455, 'West Midlands', 8, 'E'),
(404, 'Warwickshire', 'Stratford-on-Avon', 3720, 'West Midlands', 8, 'E'),
(904, 'Gloucestershire', 'Stroud', 1625, 'South West', 7, 'D'),
(609, 'Suffolk', 'Suffolk Coastal', 3530, 'Eastern', 1, 'I'),
(110, 'Sunderland', 'Sunderland', 4525, 'North East', 4, 'B'),
(805, 'Surrey', 'Surrey Heath', 3640, 'South East', 6, 'H'),
(734, 'Sutton', 'Sutton', 5870, 'London', 3, 'G'),
(820, 'Kent', 'Swale', 2255, 'South East', 6, 'H'),
(819, 'Swindon', 'Swindon', 3935, 'South West', 7, 'D'),
(311, 'Tameside', 'Tameside', 4240, 'North West', 5, 'F'),
(413, 'Staffordshire', 'Tamworth', 3445, 'West Midlands', 8, 'E'),
(805, 'Surrey', 'Tandridge', 3645, 'South East', 6, 'H'),
(905, 'Somerset', 'Taunton Deane', 3315, 'South West', 7, 'D'),
(912, 'Devon', 'Teignbridge', 1130, 'South West', 7, 'D'),
(418, 'Telford & Wrekin', 'Telford and Wrekin', 3240, 'West Midlands', 8, 'E'),
(620, 'Essex', 'Tendring', 1560, 'Eastern', 1, 'I'),
(812, 'Hampshire', 'Test Valley', 1760, 'South East', 6, 'H'),
(904, 'Gloucestershire', 'Tewkesbury', 1630, 'South West', 7, 'D'),
(820, 'Kent', 'Thanet', 2260, 'South East', 6, 'H'),
(606, 'Hertfordshire', 'Three Rivers', 1940, 'Eastern', 1, 'I'),
(622, 'Thurrock', 'Thurrock', 1595, 'Eastern', 1, 'I'),
(820, 'Kent', 'Tonbridge and Malling', 2265, 'South East', 6, 'H'),
(914, 'Torbay', 'Torbay', 1165, 'South West', 7, 'D'),
(912, 'Devon', 'Torridge', 1145, 'South West', 7, 'D'),
(711, 'Tower Hamlets', 'Tower Hamlets', 5900, 'London', 3, 'G'),
(312, 'Trafford', 'Trafford', 4245, 'North West', 5, 'F'),
(820, 'Kent', 'Tunbridge Wells', 2270, 'South East', 6, 'H'),
(620, 'Essex', 'Uttlesford', 1570, 'Eastern', 1, 'I'),
(608, 'Oxfordshire', 'Vale of White Horse', 3120, 'South East', 6, 'H'),
(213, 'Wakefield', 'Wakefield', 4725, 'Yorkshire and the Humber', 9, 'J'),
(411, 'Walsall', 'Walsall', 4630, 'West Midlands', 8, 'E'),
(735, 'Waltham Forest', 'Waltham Forest', 5930, 'London', 3, 'G'),
(712, 'Wandsworth', 'Wandsworth', 5960, 'London', 3, 'G'),
(322, 'Warrington', 'Warrington', 655, 'North West', 5, 'F'),
(404, 'Warwickshire', 'Warwick', 3725, 'West Midlands', 8, 'E'),
(606, 'Hertfordshire', 'Watford', 1945, 'Eastern', 1, 'I'),
(609, 'Suffolk', 'Waveney', 3535, 'Eastern', 1, 'I'),
(805, 'Surrey', 'Waverley', 3650, 'South East', 6, 'H'),
(815, 'East Sussex', 'Wealden', 1435, 'South East', 6, 'H'),
(504, 'Northamptonshire', 'Wellingborough', 2835, 'East Midlands', 2, 'C'),
(606, 'Hertfordshire', 'Welwyn Hatfield', 1950, 'Eastern', 1, 'I'),
(615, 'West Berkshire', 'West Berkshire', 340, 'South East', 6, 'H'),
(912, 'Devon', 'West Devon', 1150, 'South West', 7, 'D'),
(809, 'Dorset', 'West Dorset', 1230, 'South West', 7, 'D'),
(323, 'Lancashire', 'West Lancashire', 2365, 'North West', 5, 'F'),
(503, 'Lincolnshire', 'West Lindsey', 2535, 'East Midlands', 2, 'C'),
(608, 'Oxfordshire', 'West Oxfordshire', 3125, 'South East', 6, 'H'),
(905, 'Somerset', 'West Somerset', 3320, 'South West', 7, 'D'),
(713, 'Westminster', 'Westminster', 5990, 'London', 3, 'G'),
(809, 'Dorset', 'Weymouth and Portland', 1235, 'South West', 7, 'D'),
(313, 'Wigan', 'Wigan', 4250, 'North West', 5, 'F'),
(817, 'Wiltshire', 'Wiltshire', 3940, 'South West', 7, 'D'),
(812, 'Hampshire', 'Winchester', 1765, 'South East', 6, 'H'),
(618, 'Windsor & Maidenhead', 'Windsor and Maidenhead', 355, 'South East', 6, 'H'),
(319, 'Wirral', 'Wirral', 4325, 'North West', 5, 'F'),
(805, 'Surrey', 'Woking', 3655, 'South East', 6, 'H'),
(619, 'Wokingham', 'Wokingham', 360, 'South East', 6, 'H'),
(412, 'Wolverhampton', 'Wolverhampton', 4635, 'West Midlands', 8, 'E'),
(416, 'Worcestershire', 'Worcester', 1835, 'West Midlands', 8, 'E'),
(807, 'West Sussex', 'Worthing', 3835, 'South East', 6, 'H'),
(416, 'Worcestershire', 'Wychavon', 1840, 'West Midlands', 8, 'E'),
(612, 'Buckinghamshire', 'Wycombe', 425, 'South East', 6, 'H'),
(323, 'Lancashire', 'Wyre', 2370, 'North West', 5, 'F'),
(416, 'Worcestershire', 'Wyre Forest', 1845, 'West Midlands', 8, 'E'),
(219, 'York', 'York', 2741, 'Yorkshire and the Humber', 9, 'J');

CREATE SEQUENCE IF NOT EXISTS cqc."NmdsID_seq"
    AS integer
    START WITH 1001000
    INCREMENT BY 1
    MINVALUE 1001000
    MAXVALUE 9999999
    CACHE 1;

ALTER TABLE cqc."Establishment" ADD COLUMN "NmdsID" character(8);
ALTER TABLE cqc."EstablishmentLocalAuthority" ADD COLUMN "CssrID" INTEGER NULL;
ALTER TABLE cqc."EstablishmentLocalAuthority" ADD COLUMN "CssR" TEXT COLLATE pg_catalog."default" NULL;

-- The EstablishmentLocalAuthority.Cssr column is ideally NOT NULL, but if there are already records in
--   EstablishmentLocalAuthority table, then we need to do a bulk update against that and the Cssr table
--   to get the CssrID - use a "bulk update"
update cqc."EstablishmentLocalAuthority" set "CssrID" = "Cssr"."CssrID", "CssR" = "Cssr"."CssR"
    from cqc."Cssr" where "Cssr"."LocalCustodianCode" = "EstablishmentLocalAuthority"."LocalCustodianCode";

ALTER TABLE cqc."EstablishmentLocalAuthority" ALTER COLUMN "CssrID" SET NOT NULL;
ALTER TABLE cqc."EstablishmentLocalAuthority" ALTER COLUMN "CssR" SET NOT NULL;
ALTER TABLE cqc."EstablishmentLocalAuthority" DROP COLUMN "LocalCustodianCode";

-- and now update
update cqc."Establishment"
set "NmdsID" = "CssrNmdsLetter"."NmdsIDLetter" || nextval('cqc."NmdsID_seq"')
from (
    select distinct pcodedata.postcode,
            pcodedata.local_custodian_code,
            "Cssr"."NmdsIDLetter",
            "Establishment"."EstablishmentID"
    from cqc."Establishment"
    inner join cqcref.pcodedata
            inner join cqc."Cssr" on pcodedata.local_custodian_code = "Cssr"."LocalCustodianCode"
        on pcodedata.postcode = "Establishment"."PostCode"
) as "CssrNmdsLetter"
where "CssrNmdsLetter"."EstablishmentID" = "Establishment"."EstablishmentID"
and "Establishment"."NmdsID" is null;
update
    cqc."Establishment"
set
    "NmdsID" = 'F1000999'
where
    "EstablishmentID"=331;

update
    cqc."Establishment"
set
    "NmdsID" = 'H1000999',
    "PostCode" = 'ME7 4QE'
where
    "EstablishmentID"=318;

update
    cqc."Establishment"
set
    "NmdsID" = 'E1000999'
where
    "EstablishmentID"=320;

update
    cqc."Establishment"
set
    "NmdsID" = 'E1000998',
    "PostCode" = 'TF4 2SG'
where
    "EstablishmentID"=403;
ALTER TABLE cqc."Establishment" ALTER COLUMN "NmdsID" SET NOT NULL;


ALTER TABLE cqc."Login" ADD COLUMN "PasswdLastChanged" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW();

CREATE SEQUENCE IF NOT EXISTS cqc."PasswdResetTracking_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE IF NOT EXISTS cqc."PasswdResetTracking" (
    "ID" INTEGER NOT NULL PRIMARY KEY,
    "UserFK" INTEGER NOT NULL,
    "Created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    "Expires" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW() + INTERVAL '24 hour',
    "ResetUuid"  UUID NOT NULL,
    "Completed" TIMESTAMP NULL,
    CONSTRAINT "PasswdResetTracking_User_fk" FOREIGN KEY ("UserFK") REFERENCES cqc."User" ("RegistrationID") MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
);
ALTER TABLE cqc."PasswdResetTracking" ALTER COLUMN "ID" SET DEFAULT nextval('cqc."PasswdResetTracking_seq"');

ALTER TABLE cqc."User" ADD COLUMN "SecurityQuestion" character varying(255) NULL;
ALTER TABLE cqc."User" ADD COLUMN "SecurityQuestionAnswer" character varying(255) NULL;
-- migrate security question/answer from Login to User
UPDATE
    cqc."User"
SET
    "SecurityQuestion" = login."SecurityQuestion",
    "SecurityQuestionAnswer" = login."SecurityQuestionAnswer"
FROM
    cqc."Login" as login
WHERE
    login."RegistrationID" = "User"."RegistrationID";
-- note - the security question/answer are not mandatory (later task to add users means they must be left null) so leave them nullable
-- and now drop the columns from Login
ALTER TABLE cqc."Login" DROP COLUMN "SecurityQuestion";
ALTER TABLE cqc."Login" DROP COLUMN "SecurityQuestionAnswer";

-- and now rename the User columns ready for Extended Change Properties
ALTER TABLE cqc."User" RENAME "FullName" TO "FullNameValue";
ALTER TABLE cqc."User" RENAME "JobTitle" TO "JobTitleValue";
ALTER TABLE cqc."User" RENAME "Email" TO "EmailValue";
ALTER TABLE cqc."User" RENAME "Phone" TO "PhoneValue";
ALTER TABLE cqc."User" RENAME "SecurityQuestion" TO "SecurityQuestionValue";
ALTER TABLE cqc."User" RENAME "SecurityQuestionAnswer" TO "SecurityQuestionAnswerValue";

-- and now add the additional the User columns ready for Extended Change Properties
ALTER TABLE cqc."User" ADD COLUMN "FullNameSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."User" ADD COLUMN "FullNameChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."User" ADD COLUMN "FullNameSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."User" ADD COLUMN "FullNameChangedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."User" ADD COLUMN "JobTitleSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."User" ADD COLUMN "JobTitleChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."User" ADD COLUMN "JobTitleSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."User" ADD COLUMN "JobTitleChangedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."User" ADD COLUMN "EmailSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."User" ADD COLUMN "EmailChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."User" ADD COLUMN "EmailSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."User" ADD COLUMN "EmailChangedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."User" ADD COLUMN "PhoneSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."User" ADD COLUMN "PhoneChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."User" ADD COLUMN "PhoneSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."User" ADD COLUMN "PhoneChangedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."User" ADD COLUMN "SecurityQuestionSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."User" ADD COLUMN "SecurityQuestionChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."User" ADD COLUMN "SecurityQuestionSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."User" ADD COLUMN "SecurityQuestionChangedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."User" ADD COLUMN "SecurityQuestionAnswerSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."User" ADD COLUMN "SecurityQuestionAnswerChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."User" ADD COLUMN "SecurityQuestionAnswerSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."User" ADD COLUMN "SecurityQuestionAnswerChangedBy" VARCHAR(120) NULL;


-- add the created/updated/updatedBy columns
ALTER TABLE cqc."User" ADD COLUMN created TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW();
ALTER TABLE cqc."User" ADD COLUMN updated TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW();
ALTER TABLE cqc."User" ADD COLUMN updatedby VARCHAR(120) NULL;
UPDATE cqc."User" set updatedby='admin';                            -- cannot be null, so setting a default value on apply patch
ALTER TABLE cqc."User" ALTER COLUMN updatedby SET NOT NULL;

-- and drop the now unused "DateCreated" column
ALTER TABLE cqc."User" DROP COLUMN "DateCreated";

CREATE TYPE cqc."UserAuditChangeType" AS ENUM (
    'created',
    'updated',
    'saved',
    'changed',
    'passwdReset',
    'loginSuccess',
    'loginFailed',
    'loginWhileLocked'
);
CREATE TABLE IF NOT EXISTS cqc."UserAudit" (
    "ID" SERIAL NOT NULL PRIMARY KEY,
    "UserFK" INTEGER NOT NULL,
    "Username" VARCHAR(120) NOT NULL,
    "When" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    "EventType" cqc."UserAuditChangeType" NOT NULL,
    "PropertyName" VARCHAR(100) NULL,
    "ChangeEvents" JSONB NULL,
    CONSTRAINT "WorkerAudit_User_fk" FOREIGN KEY ("UserFK") REFERENCES cqc."User" ("RegistrationID") MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
);
CREATE INDEX "UserAudit_UserFK" on cqc."UserAudit" ("UserFK");

-- hotfix - UserAudit "created" event https://trello.com/c/EUf96Enj
 ALTER TABLE cqc."User" ADD COLUMN "Archived" BOOLEAN DEFAULT false;
insert into
        cqc."UserAudit" ("UserFK", "Username", "When", "EventType")
select "User"."RegistrationID", 'admin', now(), 'created'
from cqc."User", cqc."Login"
where "User"."RegistrationID" not in (
                select distinct "UserFK"
                from cqc."UserAudit"
                where "EventType" = 'created'
        )
  and "Archived"=false
  and "User"."RegistrationID" = "Login"."RegistrationID";

-- DB Patch Schema - https://trello.com/c/pByUKSW3 - add UUID to User
--ALTER TABLE cqc."User" ADD COLUMN "UserUID" UUID NULL;

ALTER  TABLE  cqc."User" ADD COLUMN  "UserUID"  UUID  NULL;

-- unfortunately, without the postgres extension "uuid-ossp", need an alternative method to
--  update existing User records with UUID
UPDATE
    cqc."User"
SET
    "UserUID" = "USER_UUID"."UIDv4"
FROM (
    SELECT CAST(substr(CAST(myuuids."UID" AS TEXT), 0, 15) || '4' || substr(CAST(myuuids."UID" AS TEXT), 16, 3) || '-89' || substr(CAST(myuuids."UID" AS TEXT), 22, 36) AS UUID) "UIDv4", "RegID"
    FROM (
        SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) "UID",
                "User"."RegistrationID" "RegID"
        FROM cqc."User", cqc."Login"
        WHERE "User"."RegistrationID" = "Login"."RegistrationID"
    ) AS MyUUIDs
) AS "USER_UUID"
WHERE "USER_UUID"."RegID" = "User"."RegistrationID";

ALTER TABLE cqc."User" ALTER COLUMN "UserUID" SET NOT NULL;

-- https://trello.com/c/1f4RSnlu defect fix
--DROP INDEX IF EXISTS cqc."Establishment_unique_registration";
--DROP INDEX IF EXISTS cqc."Establishment_unique_registration_with_locationid";
CREATE UNIQUE INDEX IF NOT EXISTS "Establishment_unique_registration" ON cqc."Establishment" ("Name", "PostCode", "LocationID");
CREATE UNIQUE INDEX IF NOT EXISTS "Establishment_unique_registration_with_locationid" ON cqc."Establishment" ("Name", "PostCode") WHERE "LocationID" IS NULL;


-- correcting reference data
update cqc."Job"
set "JobName" = 'Technician'
where "JobID" = 29;

-- Establishment location id must exist
ALTER TABLE ONLY cqc."Establishment"
    ADD CONSTRAINT estloc_fk FOREIGN KEY ("LocationID") REFERENCES cqcref.location(locationid);

-- DB Patch Schema - https://trello.com/c/MtKBV9EP - can't be done inside a transaction
--ALTER TYPE cqc.est_employertype_enum ADD VALUE 'Local Authority (generic/other)';
--ALTER TYPE cqc.est_employertype_enum ADD VALUE 'Local Authority (adult services)';

-- patch for https://trello.com/c/HzYGVltp - add/edit user
-- An Establishment's User can take one of two roles: Edit or Read Only
CREATE TYPE cqc.user_role AS ENUM (
    'Read',
    'Edit'
);

ALTER TABLE cqc."User" ADD COLUMN "UserRoleValue" cqc.user_role NOT NULL DEFAULT 'Edit';
ALTER TABLE cqc."User" ADD COLUMN "UserRoleSavedAt" TIMESTAMP NULL;
ALTER TABLE cqc."User" ADD COLUMN "UserRoleChangedAt" TIMESTAMP NULL;
ALTER TABLE cqc."User" ADD COLUMN "UserRoleSavedBy" VARCHAR(120) NULL;
ALTER TABLE cqc."User" ADD COLUMN "UserRoleChangedBy" VARCHAR(120) NULL;

update cqc."User" set "UserRoleSavedAt"=NOW(), "UserRoleChangedAt"=NOW(), "UserRoleSavedBy"='admin', "UserRoleChangedBy"='admin';
update cqc."User" set "AdminUser"=false;

ALTER TABLE cqc."Login" ADD COLUMN "LastLoggedIn" TIMESTAMP WITHOUT TIME ZONE NULL;

CREATE SEQUENCE IF NOT EXISTS cqc."AddUserTracking_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE IF NOT EXISTS cqc."AddUserTracking" (
    "ID" INTEGER NOT NULL PRIMARY KEY,
        "UserFK" INTEGER NOT NULL,
    "Created" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    "Expires" TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW() + INTERVAL '3 days',
    "AddUuid"  UUID NOT NULL,
    "RegisteredBy" VARCHAR(120) NOT NULL,
    "Completed" TIMESTAMP NULL,
        CONSTRAINT "AddUserTracking_User_fk" FOREIGN KEY ("UserFK") REFERENCES cqc."User" ("RegistrationID") MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
);
ALTER TABLE cqc."AddUserTracking" ALTER COLUMN "ID" SET DEFAULT nextval('cqc."AddUserTracking_seq"');

ALTER TABLE cqc."User" ADD COLUMN "Archived" BOOLEAN DEFAULT false;

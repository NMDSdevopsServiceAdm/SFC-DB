-- https://trello.com/c/tUZYsxWk
update cqc."ServicesCapacity"
set "Question" = 'Number of people using the service on the completion date'
where "ServiceCapacityID" in (15,16);


-- https://trello.com/c/N6RQcRuF/77-nothing-displayed-in-worker-and-staff-tabs-for-account-with-capacity-data-for-shared-lives
update cqc."ServicesCapacity"
set "Question" = 'Number of people using the service on the completion date', "Sequence"=2
where "ServiceCapacityID"=19;
INSERT INTO cqc."ServicesCapacity" ("ServiceCapacityID", "ServiceID", "Question", "Sequence", "Type") values (20, 19, 'How many places do you currently have?', 1, 'Capacity');
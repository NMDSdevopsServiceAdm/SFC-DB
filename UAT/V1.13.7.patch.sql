BEGIN TRANSACTION;

-- Adding new value to enumeration for the establishment_data_access_permission
ALTER TYPE cqc."establishment_data_access_permission" ADD VALUE 'No access to data, linked only';

END TRANSACTION;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

--NOTE: YOU NEED TO EXCHANGE ::PUBLICKEY WITH BASE64 ENCODED PUBLIC KEY
update cqc."Worker"
set "DateOfBirthEncryptedValue" = pgp_pub_encrypt("DateOfBirthValue" :: text, dearmor(convert_from(decode('::PUBLICKEY','base64'),'UTF8')));

update cqc."Worker"
set "NationalInsuranceNumberEncryptedValue" = pgp_pub_encrypt("NationalInsuranceNumberValue" :: text, dearmor(convert_from(decode('::PUBLIC KEY','base64'),'UTF8')));

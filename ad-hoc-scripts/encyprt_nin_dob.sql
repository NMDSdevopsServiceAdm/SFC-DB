CREATE EXTENSION IF NOT EXISTS pgcrypto;

--NOTE: YOU NEED TO EXCHANGE ::PUBLICKEY WITH BASE64 ENCODED PUBLIC KEY
update cqc."Worker"
set "DateOfBirthEncryptedValue" = armor(pgp_pub_encrypt("DateOfBirthValue" :: text, dearmor(convert_from(decode(
'::PUBLICKEY'
,'base64'),'UTF8'))));

update cqc."Worker"
set "NationalInsuranceNumberEncryptedValue" = armor(pgp_pub_encrypt("NationalInsuranceNumberValue" :: text, dearmor(convert_from(decode(
'::PUBLIC KEY'
,'base64'),'UTF8'))));

-- OR BOTH TOGETHER

update cqc."Worker"
set "NationalInsuranceNumberEncryptedValue" = armor(pgp_pub_encrypt("NationalInsuranceNumberValue" :: text, dearmor(convert_from(decode(
'::PUBLIC KEY'
,'base64'),'UTF8')))),
"DateOfBirthEncryptedValue" = armor(pgp_pub_encrypt("DateOfBirthValue" :: text, dearmor(convert_from(decode(
'::PUBLICKEY'
,'base64'),'UTF8'))));


-- TO TEST THE CHANGES:

SELECT "DateOfBirthValue","DateOfBirthEncryptedValue",pgp_pub_decrypt(dearmor("DateOfBirthEncryptedValue") :: bytea, dearmor(convert_from(decode(
        '::PRIVATE'
    ,'base64'),'UTF8')),
    '::PASSPHRASE')
FROM cqc."Worker"
WHERE "DateOfBirthValue" IS NOT Null
LIMIT 1;

SELECT "NationalInsuranceNumberValue","NationalInsuranceNumberEncryptedValue",pgp_pub_decrypt(dearmor("NationalInsuranceNumberEncryptedValue") :: bytea, dearmor(convert_from(decode(
    '::PRIVATE'
    ,'base64'),'UTF8')),
    '::PASSPHRASE')
FROM cqc."Worker"
WHERE "NationalInsuranceNumberValue" IS NOT Null
LIMIT 1;

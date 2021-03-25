BEGIN;

SELECT COUNT(1) FROM cqc."Worker" WHERE "SocialCareQualificationFKValue" IS NOT NULL AND "QualificationInSocialCareValue" <> 'Yes';

SELECT COUNT(1) FROM cqc."Worker" WHERE "HighestQualificationFKValue" IS NOT NULL AND "OtherQualificationsValue" <> 'Yes';

UPDATE cqc."Worker" SET
"SocialCareQualificationFKValue" = NULL
WHERE "QualificationInSocialCareValue" <> 'Yes'
AND "SocialCareQualificationFKValue" IS NOT NULL;

UPDATE cqc."Worker" SET
"HighestQualificationFKValue" = NULL
WHERE "OtherQualificationsValue" <> 'Yes'
AND "HighestQualificationFKValue" IS NOT NULL;

SELECT COUNT(1) FROM cqc."Worker" WHERE "SocialCareQualificationFKValue" IS NOT NULL AND "QualificationInSocialCareValue" <> 'Yes';

SELECT COUNT(1) FROM cqc."Worker" WHERE "HighestQualificationFKValue" IS NOT NULL AND "OtherQualificationsValue" <> 'Yes';

COMMIT;

CREATE OR REPLACE VIEW cqc."AllEstablishmentAndWorkersVW" AS
 SELECT "Login"."Username",
    "Login"."Active" AS "IsActive",
    "Login"."LastLoggedIn",
    "Login"."PasswdLastChanged",
    "User"."RegistrationID" AS "UserID",
    "User"."UserUID",
    "User"."FullNameValue" AS "FullName",
    "User"."EmailValue" AS "Email",
    "User"."PhoneValue" AS "Phone",
    "User"."SecurityQuestionValue" AS "SecurityQuestion",
    "User"."SecurityQuestionAnswerValue" AS "SecurityAnswer",
    "User"."UserRoleValue" AS "UserRole",
    "User"."IsPrimary",
    "User".updated AS "LastUpdated",
    "Establishment"."EstablishmentUID",
    "Establishment"."PostCode" AS "EstablishmentPostcode",
    "Establishment"."NmdsID" AS "EstablishmentNDMSID",
    "Establishment"."NameValue" AS "EstablishmentName"
   FROM cqc."User"
     JOIN cqc."Login" ON "User"."RegistrationID" = "Login"."RegistrationID"
     JOIN cqc."Establishment" ON "Establishment"."EstablishmentID" = "User"."EstablishmentID"
  WHERE "User"."Archived" = false AND "Establishment"."Archived" = false;

ALTER TABLE cqc."AllEstablishmentAndWorkersVW"
    OWNER TO sfcadmin;


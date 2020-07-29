#!/usr/bin/sh
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Created By  : Tikaram Choudhury
# Date Created: 16th Oct, 2019
# Script Name : analysis_file_report.sh
# Purpose     : Create a view to generate a csv report for workspace,worker & leaver analysis for Skills for Care Analysis Team.
# Trello Card#: https://trello.com/c/iSkAi0mo/41-8-us80-analysis-analysis-files-33-interim
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
alias echo='echo -e'
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function usage_note
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
   echo "\nUsage: \033[48;5;105m`basename $0` <Database-Name> <[1]/[2]/[3] for workspace/worker/leaver respectively> <GlobalID-Encryption-Key>\033[0m\n"
   echo " \033[48;5;120mNote: Database-Name could be as follow:\033[0m\n"
   echo "   \033[48;5;200m      sfcdevdb - for Development.\033[0m"
   echo "   \033[48;5;205m      sfctstdb - for Test/Staging.\033[0m\n"
   echo "   \033[48;5;205m      sfcafrdb - for Test/Staging.\033[0m\n"
   echo "   \033[48;5;215m   sfc201911db - for Clone of Production for 30th Nov, 2019.\033[0m"
   echo "   \033[48;5;220m   sfc201912db - for Clone of Production for 31th Dec, 2019.\033[0m"
   echo "   \033[48;5;220m   sfc202001db - for Clone of Production for 31th Jan, 2020.\033[0m\n"
   echo "   \033[48;5;212m    sfcuatdb01 - for Production.\033[0m"
   echo "   \033[48;5;203m    sfcuatdb02 - for Pre-production.\033[0m\n"
   exit 1

# \\033[38;5;${color}mhello\\033[48;5;${color}mworld\\033[0m
}
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
db_name=$1; rpt_id=$2; gid_enc_key=$3; [[ $# -ne 3 ]] && usage_note && exit 1

working_dir="/efs/sfc-db/report"; sql_filename="`basename $0 .sh`_${rpt_id}.sql"
[[ ! -d ${working_dir} ]] && (mkdir ${working_dir}; chmod 777 ${working_dir})
[[ "`which cf7`" = "/usr/bin/cf7" ]] && _mycf="cf7" || _mycf="cf"
run_date=`date "+%d-%m-%Y"` # This has to be the 1st day of following month.

run_date="01-04-2020" # for report of March, 2020.
echo "\nPlease note that the variable assignment i.e., [ \033[0;105mrun_date=${run_date}\033[0m ] is hard-coded at the moment. That need removing.\n"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
case "${rpt_id}" in
   1) sql_stmt_01='SELECT "BatchNo" FROM cqc."Afr1BatchiSkAi0mo" GROUP BY 1 ORDER BY 1;'
      sql_stmt_02='DROP TABLE IF EXISTS cqc."Afr1BatchiSkAi0mo" CASCADE;'; postfix="workspace" ;;
   2) sql_stmt_01='SELECT "BatchNo" FROM cqc."Afr2BatchiSkAi0mo" GROUP BY 1 ORDER BY 1;'
      sql_stmt_02='DROP TABLE IF EXISTS cqc."Afr2BatchiSkAi0mo" CASCADE;'; postfix="worker" ;;
   3) sql_stmt_01='SELECT "BatchNo" FROM cqc."Afr3BatchiSkAi0mo" GROUP BY 1 ORDER BY 1;'
      sql_stmt_02='DROP TABLE IF EXISTS cqc."Afr3BatchiSkAi0mo" CASCADE;'; postfix="leaver" ;;
   *) echo "\nInvalid option - please check and try again.\n"; exit 1 ;;
esac
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
mycmd="sed -n '/^SeQueL${rpt_id}0/,/^SeQueL${rpt_id}0/p' $0|sed 's#<run_date>#${run_date}#g'|grep -v SeQueL${rpt_id}0 > ${sql_filename}";eval "${mycmd}"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
case "${db_name}" in
   sfc2*|sfc???db) cat "${sql_filename}" | sudo su postgres -c "psql -d ${db_name}"
                   batch_list=`echo ${sql_stmt_01} | sudo su postgres -c "psql -t -d ${db_name}"` ;;
    sfcuatdb0[12]) mycmd="sed -i '1i \\\\\! cf scale ${db_name}-psql -m 8G -k 4G -f' ${sql_filename}"; eval "${mycmd}"
                   cat "${sql_filename}" | ${_mycf} conduit ${db_name} --app-name ${db_name}-psql -- psql; sleep 10
                   batch_list=`echo ${sql_stmt_01} | ${_mycf} conduit ${db_name} --app-name ${db_name}-psql -- psql -t` ;;
                *) usage_note ;;
esac
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
for batch_id in ${batch_list} # seq -f "%02g" -s " " 1 80
do
   batch_id="`echo ${batch_id} | awk '{printf "%02d\n",$0}'`"
   echo "`date`: Analysis report for Batch ID [ ${batch_id} ] started."

   csv_filename="${working_dir}/`date +%Y%m%d`_`basename $0 .sh`_${postfix}_${batch_id}.csv"

   mycmd="sed -n '/^SeQueL${rpt_id}1/,/^SeQueL${rpt_id}1/p' $0|grep -v SeQueL${rpt_id}1|sed 's#<batch_id>#${batch_id}#g'|sed 's#<csv_filename>#${csv_filename}#g'|sed 's#<gidek>#${gid_enc_key}#g' > ${sql_filename}"
   eval "${mycmd}"

   case "${db_name}" in
      sfc2*|sfc???db) cat "${sql_filename}" | sudo su postgres -c "psql -d ${db_name}" ;;
       sfcuatdb0[12]) mycmd="sed -i '1i \\\\\! cf scale ${db_name}-psql -m 8G -k 4G -f' ${sql_filename}"; eval "${mycmd}"; sleep 10
                      cat "${sql_filename}" | ${_mycf} conduit ${db_name} --app-name ${db_name}-psql -- psql ;;
   esac

   echo "`date`: Analysis report for Batch ID [ ${batch_id} ] completed.\n"
done
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Drop the batch table at the end of producing all the reports.

case "${db_name}" in
   sfc2*|sfc???db) echo "${sql_stmt_02}" | sudo su postgres -c "psql -d ${db_name}" ;;
    sfcuatdb0[12]) echo "${sql_stmt_02}" | ${_mycf} conduit ${db_name} --app-name ${db_name}-psql -- psql ;;
esac

echo "`date`: Batch table < Afr${rpt_id}BatchiSkAi0mo > dropped from the database as it is no longer needed.\n"
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[[ -s ${sql_filename} ]] && rm -f ${sql_filename}; exit 0
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SeQueL10 -- SQL for creating batch for workspace analysis file report BEGINs.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SET SEARCH_PATH TO cqc;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT CURRENT_DATABASE(), NOW(), 'Started creating batch table.' status;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DROP TABLE IF EXISTS cqc."Afr1BatchiSkAi0mo" CASCADE; -- afr stands for Analysis File Report.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CREATE TABLE "Afr1BatchiSkAi0mo" AS
SELECT "EstablishmentID",
       ROW_NUMBER() OVER (ORDER BY "EstablishmentID") "SerialNo",
       NULL::INT "BatchNo",
       TO_DATE('<run_date>','DD-MM-YYYY')::DATE AS "RunDate"
FROM   "Establishment"
WHERE  "Archived" = false
AND    "Status" IS NULL;

CREATE INDEX "Afr1BatchiSkAi0mo_idx" ON "Afr1BatchiSkAi0mo"("BatchNo");

CREATE OR REPLACE FUNCTION create_batch_4_workspace(p_no_of_workspace integer) RETURNS VOID AS $$
DECLARE
   current_status INT := 1;
   no_of_batch_created INT := 0;
BEGIN
   LOOP
      current_status := (SELECT COUNT(1) FROM "Afr1BatchiSkAi0mo" WHERE "BatchNo" IS NULL);
      IF current_status <> 0 THEN
         no_of_batch_created := no_of_batch_created + 1;
      END IF;

      EXIT WHEN current_status = 0;

      UPDATE "Afr1BatchiSkAi0mo"
      SET    "BatchNo" = (SELECT MAX(COALESCE("BatchNo",0)) + 1 FROM "Afr1BatchiSkAi0mo")
      WHERE  "SerialNo" <= p_no_of_workspace
      AND    "BatchNo" IS NULL;

      UPDATE "Afr1BatchiSkAi0mo"
      SET    "SerialNo" = "SerialNo" - p_no_of_workspace
      WHERE  "BatchNo" IS NULL;
   END LOOP;

   RAISE NOTICE 'Created: [ % ] batch.', (SELECT COUNT(DISTINCT "BatchNo") FROM "Afr1BatchiSkAi0mo");
END;
$$ LANGUAGE plpgsql;

SELECT create_batch_4_workspace(2000);
DROP FUNCTION create_batch_4_workspace(integer);
SELECT "BatchNo",COUNT(1) "NoOfWorkspaces" FROM "Afr1BatchiSkAi0mo" GROUP BY 1 ORDER BY 1;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SeQueL10 -- SQL for creating batch for Workspace analysis file report END.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SeQueL11 -- SQL for Workspace / Establishment analysis file report BEGINs.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SET SEARCH_PATH TO cqc;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT CURRENT_DATABASE(), NOW(), 'Started creating database view.' status;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CREATE OR REPLACE TEMPORARY VIEW v_afr_workspace_<batch_id> AS
SELECT 'M' || DATE_PART('year',(b."RunDate" - INTERVAL '1 day')) || LPAD(DATE_PART('month',(b."RunDate" - INTERVAL '1 day'))::TEXT,2,'0') period, -- 001
       e."EstablishmentID" establishmentid, -- 002
       "TribalID" tribalid, -- 003
       "ParentID" parentid, -- 004
       CASE WHEN e."IsParent" THEN e."EstablishmentID" ELSE CASE WHEN e."ParentID" IS NOT NULL THEN e."ParentID" ELSE e."EstablishmentID" END END orgid, -- 005
       "NmdsID" nmdsid, -- 006
       1 wkplacestat, -- 007
       TO_CHAR("created",'DD/MM/YYYY') estabcreateddate, -- 008
       (
          SELECT COUNT(1)
          FROM   "User" u JOIN "UserAudit" a ON u."RegistrationID" = a."UserFK" AND
                 a."When" >= b."RunDate" - INTERVAL '1 month' AND a."EventType" = 'loginSuccess'
          WHERE  u."EstablishmentID" = e."EstablishmentID"
          AND    u."Archived" = false
       ) logincount_month, -- 009
       (
          SELECT COUNT(1)
          FROM   "User" u JOIN "UserAudit" a ON u."RegistrationID" = a."UserFK" AND
                 a."When" >= b."RunDate" - INTERVAL '1 year' AND a."EventType" = 'loginSuccess'
          WHERE  u."EstablishmentID" = e."EstablishmentID"
          AND    u."Archived" = false
       ) logincount_year, -- 010
       (
          SELECT TO_CHAR(MAX(a."When"),'DD/MM/YYYY')
          FROM   "User" u JOIN "UserAudit" a ON u."RegistrationID" = a."UserFK" AND a."EventType" = 'loginSuccess'
          WHERE  u."EstablishmentID" = e."EstablishmentID"
          AND    u."Archived" = false
       ) lastloggedin, -- 011
       TO_CHAR((
       SELECT "When"
       FROM   (
                 SELECT a."When"
                 FROM   "User" u JOIN "UserAudit" a ON u."RegistrationID" = a."UserFK" AND a."EventType" = 'loginSuccess'
                 WHERE  u."EstablishmentID" = e."EstablishmentID"
                 AND    u."Archived" = false
                 ORDER  BY 1 DESC LIMIT 2
              ) x
       ORDER BY 1 LIMIT 1),'DD/MM/YYYY'
       ) previous_logindate, -- 012
       (
          SELECT COUNT(1)
          FROM   "EstablishmentAudit"
          WHERE  "EstablishmentFK" = e."EstablishmentID" AND "EventType" = 'changed' AND "When" >= b."RunDate" - INTERVAL '1 month'
       ) +
       (
          SELECT COUNT(DISTINCT a."WorkerFK")
          FROM   "WorkerAudit" a JOIN "Worker" w ON a."WorkerFK" = w."ID" AND a."EventType" = 'changed' AND a."When" >= b."RunDate" - INTERVAL '1 month'
          WHERE  w."EstablishmentFK" = e."EstablishmentID"
          AND    w."Archived" = false
       ) updatecount_month, -- 013
       (
          SELECT COUNT(DISTINCT "EstablishmentFK")
          FROM   "EstablishmentAudit"
          WHERE  "EstablishmentFK" = e."EstablishmentID"
          AND    "EventType" = 'changed'
          AND    "When" >= b."RunDate" - INTERVAL '1 year'
       ) +
       (
          SELECT COUNT(DISTINCT a."WorkerFK")
          FROM   "WorkerAudit" a JOIN "Worker" w ON a."WorkerFK" = w."ID" AND a."EventType" = 'changed' AND a."When" >= b."RunDate" - INTERVAL '1 year'
          WHERE  w."EstablishmentFK" = e."EstablishmentID"
          AND    w."Archived" = false
       ) updatecount_year, -- 014
       -- TO_CHAR(GREATEST(created,updated),'DD/MM/YYYY') estabupdateddate, -- 015 -- To be removed later. qwerty
       TO_CHAR(GREATEST(
       e."EmployerTypeChangedAt",
       e."NumberOfStaffChangedAt",
       e."OtherServicesChangedAt",
       e."CapacityServicesChangedAt",
       e."ShareDataChangedAt",
       e."ShareWithLAChangedAt",
       e."VacanciesChangedAt",
       e."StartersChangedAt",
       e."LeaversChangedAt",
       e."ServiceUsersChangedAt",
       e."NameChangedAt",
       e."MainServiceFKChangedAt",
       e."LocalIdentifierChangedAt",
       e."LocationIdChangedAt",
       e."Address1ChangedAt",
       e."Address2ChangedAt",
       e."Address3ChangedAt",
       e."TownChangedAt",
       e."CountyChangedAt",
       e."PostcodeChangedAt"),'DD/MM/YYYY') estabupdateddate, -- 015
       TO_CHAR(GREATEST(
       e."EmployerTypeSavedAt",
       e."NumberOfStaffSavedAt",
       e."OtherServicesSavedAt",
       e."CapacityServicesSavedAt",
       e."ShareDataSavedAt",
       e."ShareWithLASavedAt",
       e."VacanciesSavedAt",
       e."StartersSavedAt",
       e."LeaversSavedAt",
       e."ServiceUsersSavedAt",
       e."NameSavedAt",
       e."MainServiceFKSavedAt",
       e."LocalIdentifierSavedAt",
       e."LocationIdSavedAt",
       e."Address1SavedAt",
       e."Address2SavedAt",
       e."Address3SavedAt",
       e."TownSavedAt",
       e."CountySavedAt",
       e."PostcodeSavedAt"),'DD/MM/YYYY') estabsavedate, -- 015a
       (SELECT TO_CHAR(MAX(GREATEST(
              "NameOrIdChangedAt",
              "ContractChangedAt",
              "MainJobFKChangedAt",
              "ApprovedMentalHealthWorkerChangedAt",
              "MainJobStartDateChangedAt",
              "OtherJobsChangedAt",
              "NationalInsuranceNumberChangedAt",
              "DateOfBirthChangedAt",
              "PostcodeChangedAt",
              "DisabilityChangedAt",
              "GenderChangedAt",
              "EthnicityFKChangedAt",
              "NationalityChangedAt",
              "CountryOfBirthChangedAt",
              "RecruitedFromChangedAt",
              "BritishCitizenshipChangedAt",
              "YearArrivedChangedAt",
              "SocialCareStartDateChangedAt",
              "DaysSickChangedAt",
              "ZeroHoursContractChangedAt",
              "WeeklyHoursAverageChangedAt",
              "WeeklyHoursContractedChangedAt",
              "AnnualHourlyPayChangedAt",
              "CareCertificateChangedAt",
              "ApprenticeshipTrainingChangedAt",
              "QualificationInSocialCareChangedAt",
              "SocialCareQualificationFKChangedAt",
              "OtherQualificationsChangedAt",
              "HighestQualificationFKChangedAt",
              "CompletedChangedAt",
              "RegisteredNurseChangedAt",
              "NurseSpecialismFKChangedAt",
              "LocalIdentifierChangedAt",
              "EstablishmentFkChangedAt")),'DD/MM/YYYY')
       FROM   "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "Archived" = false) workerupdate, -- 016
       TO_CHAR(GREATEST(e.updated,(SELECT MAX(updated) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "Archived" = false)),'DD/MM/YYYY') mupddate, -- 017
       TO_CHAR(GREATEST((CASE WHEN e.updated < GREATEST(e.updated,(SELECT MAX(updated) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "Archived" = false)) THEN e.updated ELSE NULL END),(SELECT MAX(updated) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "Archived" = false AND updated < GREATEST(e.updated,(SELECT MAX(updated) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "Archived" = false)))),'DD/MM/YYYY') previous_mupddate, -- 018
       CASE WHEN "LastBulkUploaded" IS NULL THEN 0 ELSE 1 END derivedfrom_hasbulkuploaded, -- 019a
       CASE WHEN "LastBulkUploaded" IS NULL THEN 0 ELSE 1 END isbulkuploader, -- 019
       TO_CHAR("LastBulkUploaded",'DD/MM/YYYY') lastbulkuploaddate, -- 020
       CASE "IsParent" WHEN true THEN 1 ELSE 0 END isparent, -- 021
       CASE "DataOwner" WHEN 'Parent' THEN 1 WHEN 'Workplace' THEN 2 ELSE 3 END parentpermission, -- 022
       (SELECT TO_CHAR(MAX(GREATEST(
              "NameOrIdSavedAt",
              "ContractSavedAt",
              "MainJobFKSavedAt",
              "ApprovedMentalHealthWorkerSavedAt",
              "MainJobStartDateSavedAt",
              "OtherJobsSavedAt",
              "NationalInsuranceNumberSavedAt",
              "DateOfBirthSavedAt",
              "PostcodeSavedAt",
              "DisabilitySavedAt",
              "GenderSavedAt",
              "EthnicityFKSavedAt",
              "NationalitySavedAt",
              "CountryOfBirthSavedAt",
              "RecruitedFromSavedAt",
              "BritishCitizenshipSavedAt",
              "YearArrivedSavedAt",
              "SocialCareStartDateSavedAt",
              "DaysSickSavedAt",
              "ZeroHoursContractSavedAt",
              "WeeklyHoursAverageSavedAt",
              "WeeklyHoursContractedSavedAt",
              "AnnualHourlyPaySavedAt",
              "CareCertificateSavedAt",
              "ApprenticeshipTrainingSavedAt",
              "QualificationInSocialCareSavedAt",
              "SocialCareQualificationFKSavedAt",
              "OtherQualificationsSavedAt",
              "HighestQualificationFKSavedAt",
              "CompletedSavedAt",
              "RegisteredNurseSavedAt",
              "NurseSpecialismFKSavedAt",
              "LocalIdentifierSavedAt",
              "EstablishmentFkSavedAt")),'DD/MM/YYYY')
       FROM   "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "Archived" = false) workersavedate, -- 022a
       CASE "ShareDataWithCQC" WHEN true THEN 1 ELSE 0 END cqcpermission, -- 023
       CASE "ShareDataWithLA" WHEN true THEN 1 ELSE 0 END lapermission, -- 024
       CASE WHEN "IsRegulated" is true THEN 2 ELSE 0 END regtype, -- 025
       "ProvID" providerid, -- 026
       "LocationID" locationid, -- 027
       CASE "EmployerTypeValue"
          WHEN 'Local Authority (adult services)' THEN 1
          WHEN 'Local Authority (generic/other)' THEN 3
          WHEN 'Private Sector' THEN 6
          WHEN 'Voluntary / Charity' THEN 7
          WHEN 'Other' THEN 8
       END esttype, -- 028
       TO_CHAR("EmployerTypeChangedAt",'DD/MM/YYYY') esttype_changedate, -- 029
       TO_CHAR("EmployerTypeSavedAt",'DD/MM/YYYY') esttype_savedate, -- 030
       "NameValue" establishmentname, -- 031
       "Address1" address, -- 032
       "PostCode" postcode, -- 033
       COALESCE((SELECT "RegionID" FROM "Cssr" WHERE "NmdsIDLetter" = SUBSTRING(e."NmdsID",1,1) LIMIT 1),NULL,-1) regionid, -- 034
       COALESCE((SELECT "CssrID" FROM "Cssr" WHERE "NmdsIDLetter" = SUBSTRING(e."NmdsID",1,1) AND "LocalCustodianCode" IN (SELECT local_custodian_code FROM cqcref.pcodedata WHERE postcode = e."PostCode") LIMIT 1),NULL,-1) cssr, -- 035
       (
          SELECT CASE "LocalAuthority"
                    WHEN 'Mid Bedfordshire' THEN 1              -- Does not exists in database.
                    WHEN 'Bedford' THEN 2
                    WHEN 'South Bedfordshire' THEN 3            -- Does not exists in database.
                    WHEN 'Cambridge' THEN 4
                    WHEN 'East Cambridgeshire' THEN 5
                    WHEN 'Fenland' THEN 6
                    WHEN 'Huntingdonshire' THEN 7
                    WHEN 'South Cambridgeshire' THEN 8
                    WHEN 'Basildon' THEN 9
                    WHEN 'Braintree' THEN 10
                    WHEN 'Brentwood' THEN 11
                    WHEN 'Castle Point' THEN 12
                    WHEN 'Chelmsford' THEN 13
                    WHEN 'Colchester' THEN 14
                    WHEN 'Epping Forest' THEN 15
                    WHEN 'Harlow' THEN 16
                    WHEN 'Maldon' THEN 17
                    WHEN 'Rochford' THEN 18
                    WHEN 'Tendring' THEN 19
                    WHEN 'Uttlesford' THEN 20
                    WHEN 'Broxbourne' THEN 21
                    WHEN 'Dacorum' THEN 22
                    WHEN 'East Hertfordshire' THEN 23
                    WHEN 'Hertsmere' THEN 24
                    WHEN 'North Hertfordshire' THEN 25
                    WHEN 'St Albans' THEN 26
                    WHEN 'Stevenage' THEN 27
                    WHEN 'Three Rivers' THEN 28
                    WHEN 'Watford' THEN 29
                    WHEN 'Welwyn Hatfield' THEN 30
                    WHEN 'Luton' THEN 31
                    WHEN 'Breckland' THEN 32
                    WHEN 'Broadland' THEN 33
                    WHEN 'Great Yarmouth' THEN 34
                    WHEN 'King`s Lynn and West Norfolk' THEN 35
                    WHEN 'North Norfolk' THEN 36
                    WHEN 'Norwich' THEN 37
                    WHEN 'South Norfolk' THEN 38
                    WHEN 'Peterborough' THEN 39
                    WHEN 'Southend-on-Sea' THEN 40
                    WHEN 'Babergh' THEN 41
                    WHEN 'Forest Heath' THEN 42
                    WHEN 'Ipswich' THEN 43
                    WHEN 'Mid Suffolk' THEN 44
                    WHEN 'St. Edmundsbury' THEN 45
                    WHEN 'Suffolk Coastal' THEN 46
                    WHEN 'Waveney' THEN 47
                    WHEN 'Thurrock' THEN 48
                    WHEN 'Derby' THEN 49
                    WHEN 'Amber Valley' THEN 50
                    WHEN 'Bolsover' THEN 51
                    WHEN 'Chesterfield' THEN 52
                    WHEN 'Derbyshire Dales' THEN 53
                    WHEN 'Erewash' THEN 54
                    WHEN 'High Peak' THEN 55
                    WHEN 'North East Derbyshire' THEN 56
                    WHEN 'South Derbyshire' THEN 57
                    WHEN 'Leicester' THEN 58
                    WHEN 'Blaby' THEN 59
                    WHEN 'Charnwood' THEN 60
                    WHEN 'Harborough' THEN 61
                    WHEN 'Hinckley and Bosworth' THEN 62
                    WHEN 'Melton' THEN 63
                    WHEN 'North West Leicestershire' THEN 64
                    WHEN 'Oadby and Wigston' THEN 65
                    WHEN 'Boston' THEN 66
                    WHEN 'East Lindsey' THEN 67
                    WHEN 'Lincoln' THEN 68
                    WHEN 'North Kesteven' THEN 69
                    WHEN 'South Holland' THEN 70
                    WHEN 'South Kesteven' THEN 71
                    WHEN 'West Lindsey' THEN 72
                    WHEN 'Corby' THEN 73
                    WHEN 'Daventry' THEN 74
                    WHEN 'East Northamptonshire' THEN 75
                    WHEN 'Kettering' THEN 76
                    WHEN 'Northampton' THEN 77
                    WHEN 'South Northamptonshire' THEN 78
                    WHEN 'Wellingborough' THEN 79
                    WHEN 'Nottingham' THEN 80
                    WHEN 'Ashfield' THEN 81
                    WHEN 'Bassetlaw' THEN 82
                    WHEN 'Broxtowe' THEN 83
                    WHEN 'Gedling' THEN 84
                    WHEN 'Mansfield' THEN 85
                    WHEN 'Newark and Sherwood' THEN 86
                    WHEN 'Rushcliffe' THEN 87
                    WHEN 'Rutland' THEN 88
                    WHEN 'Barking and Dagenham' THEN 89
                    WHEN 'Barnet' THEN 90
                    WHEN 'Bexley' THEN 91
                    WHEN 'Brent' THEN 92
                    WHEN 'Bromley' THEN 93
                    WHEN 'Camden' THEN 94
                    WHEN 'City of London' THEN 95
                    WHEN 'Croydon' THEN 96
                    WHEN 'Ealing' THEN 97
                    WHEN 'Enfield' THEN 98
                    WHEN 'Greenwich' THEN 99
                    WHEN 'Hackney' THEN 100
                    WHEN 'Hammersmith and Fulham' THEN 101
                    WHEN 'Haringey' THEN 102
                    WHEN 'Harrow' THEN 103
                    WHEN 'Havering' THEN 104
                    WHEN 'Hillingdon' THEN 105
                    WHEN 'Hounslow' THEN 106
                    WHEN 'Islington' THEN 107
                    WHEN 'Kensington and Chelsea' THEN 108
                    WHEN 'Kingston upon Thames' THEN 109
                    WHEN 'Lambeth' THEN 110
                    WHEN 'Lewisham' THEN 111
                    WHEN 'Merton' THEN 112
                    WHEN 'Newham' THEN 113
                    WHEN 'Redbridge' THEN 114
                    WHEN 'Richmond upon Thames' THEN 115
                    WHEN 'Southwark' THEN 116
                    WHEN 'Sutton' THEN 117
                    WHEN 'Tower Hamlets' THEN 118
                    WHEN 'Waltham Forest' THEN 119
                    WHEN 'Wandsworth' THEN 120
                    WHEN 'Westminster' THEN 121
                    WHEN 'Darlington' THEN 122
                    WHEN 'Chester-le-Street' THEN 123           -- Does not exists in database.
                    WHEN 'Derwentside' THEN 124                 -- Does not exists in database.
                    WHEN 'Durham' THEN 125                      -- Does not exists in database.
                    WHEN 'Easington' THEN 126                   -- Does not exists in database.
                    WHEN 'Sedgefield' THEN 127                  -- Does not exists in database.
                    WHEN 'Teesdale' THEN 128                    -- Does not exists in database.
                    WHEN 'Wear Valley' THEN 129                 -- Does not exists in database.
                    WHEN 'Gateshead' THEN 130
                    WHEN 'Hartlepool' THEN 131
                    WHEN 'Middlesbrough' THEN 132
                    WHEN 'Newcastle upon Tyne' THEN 133
                    WHEN 'North Tyneside' THEN 134
                    WHEN 'Alnwick' THEN 135                     -- Does not exists in database.
                    WHEN 'Berwick-upon-Tweed' THEN 136          -- Does not exists in database.
                    WHEN 'Blyth Valley' THEN 137                -- Does not exists in database.
                    WHEN 'Castle Morpeth' THEN 138              -- Does not exists in database.
                    WHEN 'Tynedale' THEN 139                    -- Does not exists in database.
                    WHEN 'Wansbeck' THEN 140                    -- Does not exists in database.
                    WHEN 'Redcar and Cleveland' THEN 141
                    WHEN 'South Tyneside' THEN 142
                    WHEN 'Stockton-on-Tees' THEN 143
                    WHEN 'Sunderland' THEN 144
                    WHEN 'Blackburn with Darwen' THEN 145
                    WHEN 'Blackpool' THEN 146
                    WHEN 'Bolton' THEN 147
                    WHEN 'Bury' THEN 148
                    WHEN 'Chester' THEN 149                     -- Does not exists in database.
                    WHEN 'Congleton' THEN 150                   -- Does not exists in database.
                    WHEN 'Crewe and Nantwich' THEN 151          -- Does not exists in database.
                    WHEN 'Ellesmere Port & Neston' THEN 152     -- Does not exists in database.
                    WHEN 'Macclesfield' THEN 153                -- Does not exists in database.
                    WHEN 'Vale Royal' THEN 154                  -- Does not exists in database.
                    WHEN 'Allerdale' THEN 155
                    WHEN 'Barrow-in-Furness' THEN 156
                    WHEN 'Carlisle' THEN 157
                    WHEN 'Copeland' THEN 158
                    WHEN 'Eden' THEN 159
                    WHEN 'South Lakeland' THEN 160
                    WHEN 'Halton' THEN 161
                    WHEN 'Knowsley' THEN 162
                    WHEN 'Burnley' THEN 163
                    WHEN 'Chorley' THEN 164
                    WHEN 'Fylde' THEN 165
                    WHEN 'Hyndburn' THEN 166
                    WHEN 'Lancaster' THEN 167
                    WHEN 'Pendle' THEN 168
                    WHEN 'Preston' THEN 169
                    WHEN 'Ribble Valley' THEN 170
                    WHEN 'Rossendale' THEN 171
                    WHEN 'South Ribble' THEN 172
                    WHEN 'West Lancashire' THEN 173
                    WHEN 'Wyre' THEN 174
                    WHEN 'Liverpool' THEN 175
                    WHEN 'Manchester' THEN 176
                    WHEN 'Oldham' THEN 177
                    WHEN 'Rochdale' THEN 178
                    WHEN 'Salford' THEN 179
                    WHEN 'Sefton' THEN 180
                    WHEN 'St. Helens' THEN 181
                    WHEN 'Stockport' THEN 182
                    WHEN 'Tameside' THEN 183
                    WHEN 'Trafford' THEN 184
                    WHEN 'Warrington' THEN 185
                    WHEN 'Wigan' THEN 186
                    WHEN 'Wirral' THEN 187
                    WHEN 'Bracknell Forest' THEN 188
                    WHEN 'Brighton and Hove' THEN 189
                    WHEN 'Aylesbury Vale' THEN 190
                    WHEN 'Chiltern' THEN 191
                    WHEN 'South Bucks' THEN 192
                    WHEN 'Wycombe' THEN 193
                    WHEN 'Eastbourne' THEN 194
                    WHEN 'Hastings' THEN 195
                    WHEN 'Lewes' THEN 196
                    WHEN 'Rother' THEN 197
                    WHEN 'Wealden' THEN 198
                    WHEN 'Basingstoke and Deane' THEN 199
                    WHEN 'East Hampshire' THEN 200
                    WHEN 'Eastleigh' THEN 201
                    WHEN 'Fareham' THEN 202
                    WHEN 'Gosport' THEN 203
                    WHEN 'Hart' THEN 204
                    WHEN 'Havant' THEN 205
                    WHEN 'New Forest' THEN 206
                    WHEN 'Rushmoor' THEN 207
                    WHEN 'Test Valley' THEN 208
                    WHEN 'Winchester' THEN 209
                    WHEN 'Isle of Wight' THEN 210
                    WHEN 'Ashford' THEN 211
                    WHEN 'Canterbury' THEN 212
                    WHEN 'Dartford' THEN 213
                    WHEN 'Dover' THEN 214
                    WHEN 'Gravesham' THEN 215
                    WHEN 'Maidstone' THEN 216
                    WHEN 'Sevenoaks' THEN 217
                    WHEN 'Shepway' THEN 218
                    WHEN 'Swale' THEN 219
                    WHEN 'Thanet' THEN 220
                    WHEN 'Tonbridge and Malling' THEN 221
                    WHEN 'Tunbridge Wells' THEN 222
                    WHEN 'Medway' THEN 223
                    WHEN 'Milton Keynes' THEN 224
                    WHEN 'Cherwell' THEN 225
                    WHEN 'Oxford' THEN 226
                    WHEN 'South Oxfordshire' THEN 227
                    WHEN 'Vale of White Horse' THEN 228
                    WHEN 'West Oxfordshire' THEN 229
                    WHEN 'Portsmouth' THEN 230
                    WHEN 'Reading' THEN 231
                    WHEN 'Slough' THEN 232
                    WHEN 'Southampton' THEN 233
                    WHEN 'Elmbridge' THEN 234
                    WHEN 'Epsom and Ewell' THEN 235
                    WHEN 'Guildford' THEN 236
                    WHEN 'Mole Valley' THEN 237
                    WHEN 'Reigate and Banstead' THEN 238
                    WHEN 'Runnymede' THEN 239
                    WHEN 'Spelthorne' THEN 240
                    WHEN 'Surrey Heath' THEN 241
                    WHEN 'Tandridge' THEN 242
                    WHEN 'Waverley' THEN 243
                    WHEN 'Woking' THEN 244
                    WHEN 'West Berkshire' THEN 245
                    WHEN 'Adur' THEN 246
                    WHEN 'Arun' THEN 247
                    WHEN 'Chichester' THEN 248
                    WHEN 'Crawley' THEN 249
                    WHEN 'Horsham' THEN 250
                    WHEN 'Mid Sussex' THEN 251
                    WHEN 'Worthing' THEN 252
                    WHEN 'Windsor and Maidenhead' THEN 253
                    WHEN 'Wokingham' THEN 254
                    WHEN 'Bath and North East Somerset' THEN 255
                    WHEN 'Bournemouth' THEN 256
                    WHEN 'City of Bristol' THEN 257
                    WHEN 'Caradon' THEN 258                     -- Does not exists in database.
                    WHEN 'Carrick' THEN 259                     -- Does not exists in database.
                    WHEN 'Kerrier' THEN 260                     -- Does not exists in database.
                    WHEN 'North Cornwall' THEN 261              -- Does not exists in database.
                    WHEN 'Penwith' THEN 262                     -- Does not exists in database.
                    WHEN 'Restormel' THEN 263                   -- Does not exists in database.
                    WHEN 'East Devon' THEN 264
                    WHEN 'Exeter' THEN 265
                    WHEN 'Mid Devon' THEN 266
                    WHEN 'North Devon' THEN 267
                    WHEN 'South Hams' THEN 268
                    WHEN 'Teignbridge' THEN 269
                    WHEN 'Torridge' THEN 270
                    WHEN 'West Devon' THEN 271
                    WHEN 'Christchurch' THEN 272
                    WHEN 'East Dorset' THEN 273
                    WHEN 'North Dorset' THEN 274
                    WHEN 'Purbeck' THEN 275
                    WHEN 'West Dorset' THEN 276
                    WHEN 'Weymouth and Portland' THEN 277
                    WHEN 'Cheltenham' THEN 278
                    WHEN 'Cotswold' THEN 279
                    WHEN 'Forest of Dean' THEN 280
                    WHEN 'Gloucester' THEN 281
                    WHEN 'Stroud' THEN 282
                    WHEN 'Tewkesbury' THEN 283
                    WHEN 'Isles of Scilly' THEN 284
                    WHEN 'North Somerset' THEN 285
                    WHEN 'Plymouth' THEN 286
                    WHEN 'Poole' THEN 287
                    WHEN 'Mendip' THEN 288
                    WHEN 'Sedgemoor' THEN 289
                    WHEN 'South Somerset' THEN 290
                    WHEN 'Taunton Deane' THEN 291
                    WHEN 'West Somerset' THEN 292
                    WHEN 'South Gloucestershire' THEN 293
                    WHEN 'Swindon' THEN 294
                    WHEN 'Torbay' THEN 295
                    WHEN 'Kennet' THEN 296                      -- Does not exists in database.
                    WHEN 'North Wiltshire' THEN 297             -- Does not exists in database.
                    WHEN 'Salisbury' THEN 298                   -- Does not exists in database.
                    WHEN 'West Wiltshire' THEN 299              -- Does not exists in database.
                    WHEN 'Birmingham' THEN 300
                    WHEN 'Coventry' THEN 301
                    WHEN 'Dudley' THEN 302
                    WHEN 'Herefordshire' THEN 303
                    WHEN 'Sandwell' THEN 304
                    WHEN 'Bridgnorth' THEN 305                  -- Does not exists in database.
                    WHEN 'North Shropshire' THEN 306            -- Does not exists in database.
                    WHEN 'Oswestry' THEN 307                    -- Does not exists in database.
                    WHEN 'Shrewsbury and Atcham' THEN 308       -- Does not exists in database.
                    WHEN 'South Shropshire' THEN 309            -- Does not exists in database.
                    WHEN 'Solihull' THEN 310
                    WHEN 'Cannock Chase' THEN 311
                    WHEN 'East Staffordshire' THEN 312
                    WHEN 'Lichfield' THEN 313
                    WHEN 'Newcastle-under-Lyme' THEN 314
                    WHEN 'South Staffordshire' THEN 315
                    WHEN 'Stafford' THEN 316
                    WHEN 'Staffordshire Moorlands' THEN 317
                    WHEN 'Tamworth' THEN 318
                    WHEN 'Stoke-on-Trent' THEN 319
                    WHEN 'Telford and Wrekin' THEN 320
                    WHEN 'Walsall' THEN 321
                    WHEN 'North Warwickshire' THEN 322
                    WHEN 'Nuneaton and Bedworth' THEN 323
                    WHEN 'Rugby' THEN 324
                    WHEN 'Stratford-on-Avon' THEN 325
                    WHEN 'Warwick' THEN 326
                    WHEN 'Wolverhampton' THEN 327
                    WHEN 'Bromsgrove' THEN 328
                    WHEN 'Malvern Hills' THEN 329
                    WHEN 'Redditch' THEN 330
                    WHEN 'Worcester' THEN 331
                    WHEN 'Wychavon' THEN 332
                    WHEN 'Wyre Forest' THEN 333
                    WHEN 'Barnsley' THEN 334
                    WHEN 'Bradford' THEN 335
                    WHEN 'Calderdale' THEN 336
                    WHEN 'Doncaster' THEN 337
                    WHEN 'East Riding of Yorkshire' THEN 338
                    WHEN 'Kingston upon Hull' THEN 339
                    WHEN 'Kirklees' THEN 340
                    WHEN 'Leeds' THEN 341
                    WHEN 'North East Lincolnshire' THEN 342
                    WHEN 'North Lincolnshire' THEN 343
                    WHEN 'Craven' THEN 344
                    WHEN 'Hambleton' THEN 345
                    WHEN 'Harrogate' THEN 346
                    WHEN 'Richmondshire' THEN 347
                    WHEN 'Ryedale' THEN 348
                    WHEN 'Scarborough' THEN 349
                    WHEN 'Selby' THEN 350
                    WHEN 'Rotherham' THEN 351
                    WHEN 'Sheffield' THEN 352
                    WHEN 'Wakefield' THEN 353
                    WHEN 'York' THEN 354
                    WHEN 'Bedford' THEN 400
                    WHEN 'Central Bedfordshire' THEN 401
                    WHEN 'Cheshire East' THEN 402
                    WHEN 'Cheshire West and Chester' THEN 403
                    WHEN 'Cornwall' THEN 404
                    WHEN 'Isles of Scilly' THEN 405
                    WHEN 'County Durham' THEN 406
                    WHEN 'Northumberland' THEN 407
                    WHEN 'Shropshire' THEN 408
                    WHEN 'Wiltshire' THEN 409
                    ELSE -1
                 END
          FROM   "Cssr"
          WHERE  "NmdsIDLetter" = SUBSTRING(e."NmdsID",1,1)
          AND    "LocalCustodianCode" IN (SELECT local_custodian_code FROM cqcref.pcodedata WHERE postcode = e."PostCode")
          LIMIT 1
       ) lauthid, -- 036
       -- 'na' parliamentaryconstituency, -- 037
       COALESCE("NumberOfStaffValue", -1) totalstaff, --****COALESCE****  -- 038
       TO_CHAR("NumberOfStaffChangedAt",'DD/MM/YYYY') totalstaff_changedate, -- 039
       TO_CHAR("NumberOfStaffSavedAt",'DD/MM/YYYY') totalstaff_savedate, -- 040
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "Archived" = false) wkrrecs, -- 041
       (
          SELECT TO_CHAR(MAX("When"),'DD/MM/YYYY')
          FROM   "WorkerAudit"
          WHERE  "WorkerFK" IN (SELECT "ID" FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID")
          AND    "EventType" IN ('created','deleted','updated')
       ) wkrrecs_changedate, -- 042
       TO_CHAR("NumberOfStaffSavedAt",'DD/MM/YYYY') wkrrecs_WDFsavedate, -- 043
       CASE 
          WHEN "StartersValue" = 'None' THEN 0
          WHEN "StartersValue" = 'Don''t know' THEN -2
          WHEN "StartersValue" IS NULL THEN -1
          ELSE (SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Starters')
       END totalstarters, --****COALESCE**** -- 044
       TO_CHAR("StartersChangedAt",'DD/MM/YYYY') totalstarters_changedate, -- 045
       TO_CHAR("StartersSavedAt",'DD/MM/YYYY') totalstarters_savedate, -- 046
       CASE
          WHEN "LeaversValue" = 'None' THEN 0
          WHEN "LeaversValue" = 'Don''t know' THEN -2
          WHEN "LeaversValue" IS NULL THEN -1
          ELSE (SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Leavers')
       END totalleavers, --****COALESCE**** -- 047
       TO_CHAR("LeaversChangedAt",'DD/MM/YYYY') totalleavers_changedate, -- 048
       TO_CHAR("LeaversSavedAt",'DD/MM/YYYY') totalleavers_savedate, -- 049
       CASE
          WHEN "VacanciesValue" = 'None' THEN 0
          WHEN "VacanciesValue" = 'Don''t know' THEN -2
          WHEN "VacanciesValue" IS NULL THEN -1
          ELSE (SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Vacancies')
       END totalvacancies, --****COALESCE**** -- 050
       TO_CHAR("VacanciesChangedAt",'DD/MM/YYYY') totalvacancies_changedate, -- 051
       TO_CHAR("VacanciesSavedAt",'DD/MM/YYYY') totalvacancies_savedate, -- 052
       (
          SELECT CASE name
                    WHEN 'Care home services with nursing' THEN 1
                    WHEN 'Care home services without nursing' THEN 2
                    WHEN 'Other adult residential care services' THEN 5
                    WHEN 'Day care and day services' THEN 6
                    WHEN 'Other adult day care services' THEN 7
                    WHEN 'Domiciliary care services' THEN 8
                    WHEN 'Domestic services and home help' THEN 10
                    WHEN 'Other adult domiciliary care service' THEN 12
                    WHEN 'Carers support' THEN 13
                    WHEN 'Short breaks / respite care' THEN 14
                    WHEN 'Community support and outreach' THEN 15
                    WHEN 'Social work and care management' THEN 16
                    WHEN 'Shared lives' THEN 17
                    WHEN 'Disability adaptations / assistive technology services' THEN 18
                    WHEN 'Occupational / employment-related services' THEN 19
                    WHEN 'Information and advice services' THEN 20
                    WHEN 'Other adult community care service' THEN 21
                    WHEN 'Any other services' THEN 52
                    WHEN 'Sheltered housing' THEN 53
                    WHEN 'Extra care housing services' THEN 54
                    WHEN 'Supported living services' THEN 55
                    WHEN 'Specialist college services' THEN 60
                    WHEN 'Community based services for people with a learning disability' THEN 61
                    WHEN 'Community based services for people with mental health needs' THEN 62
                    WHEN 'Community based services for people who misuse substances' THEN 63
                    WHEN 'Community healthcare services' THEN 64
                    WHEN 'Hospice services' THEN 66
                    WHEN 'Long term conditions services' THEN 67
                    WHEN 'Hospital services for people with mental health needs, learning disabilities and/or problems with substance misuse' THEN 68
                    WHEN 'Rehabilitation services' THEN 69
                    WHEN 'Residential substance misuse treatment/ rehabilitation services' THEN 70
                    WHEN 'Other healthcare service' THEN 71
                    WHEN 'Head office services' THEN 72
                    WHEN 'Nurses agency' THEN 74
                    WHEN 'Any childrens / young peoples services' THEN 75
                 END
          FROM   services
          WHERE  id = e."MainServiceFKValue"
       ) mainstid, -- 053
       TO_CHAR("MainServiceFKChangedAt",'DD/MM/YYYY') mainstid_changedate, -- 054
       TO_CHAR("MainServiceFKSavedAt",'DD/MM/YYYY') mainstid_savedate, -- 055
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "Archived" = false LIMIT 1),0) jr28flag, -- 056
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "ContractValue" = 'Permanent' AND "Archived" = false) jr28perm, -- 057
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "ContractValue" = 'Temporary' AND "Archived" = false) jr28temp, -- 058
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr28pool, -- 059
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "ContractValue" = 'Agency' AND "Archived" = false) jr28agcy, -- 060
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "ContractValue" = 'Other' AND "Archived" = false) jr28oth, -- 061
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr28emp, -- 062
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "Archived" = false) jr28work, -- 063
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Starters'),-1) END jr28strt, --****COALESCE**** -- 064
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Leavers'),-1) END jr28stop, --****COALESCE**** -- 064a
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobType" = 'Vacancies'),-1) END jr28vacy, --****COALESCE**** -- 065
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (25,10,11,12,3,29,20,16) AND "Archived" = false LIMIT 1),0) jr29flag, -- 066
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (25,10,11,12,3,29,20,16) AND "ContractValue" = 'Permanent' AND "Archived" = false) jr29perm, -- 067
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (25,10,11,12,3,29,20,16) AND "ContractValue" = 'Temporary' AND "Archived" = false) jr29temp, -- 068
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (25,10,11,12,3,29,20,16) AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr29pool, -- 069
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (25,10,11,12,3,29,20,16) AND "ContractValue" = 'Agency' AND "Archived" = false) jr29agcy, -- 070
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (25,10,11,12,3,29,20,16) AND "ContractValue" = 'Other' AND "Archived" = false) jr29oth, -- 071
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (25,10,11,12,3,29,20,16) AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr29emp, -- 072
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (25,10,11,12,3,29,20,16) AND "Archived" = false) jr29work, -- 073
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (25,10,11,12,3,29,20,16) AND "JobType" = 'Starters'),-1) END jr29strt, --****COALESCE**** -- 074
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (25,10,11,12,3,29,20,16) AND "JobType" = 'Leavers'),-1) END jr29stop, --****COALESCE**** -- 075
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (25,10,11,12,3,29,20,16) AND "JobType" = 'Vacancies'),-1) END jr29vacy, --****COALESCE**** -- 076
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (26,15,13,22,28,14) AND "Archived" = false LIMIT 1),0) jr30flag, -- 077
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (26,15,13,22,28,14) AND "ContractValue" = 'Permanent' AND "Archived" = false) jr30perm, -- 078
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (26,15,13,22,28,14) AND "ContractValue" = 'Temporary' AND "Archived" = false) jr30temp, -- 079
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (26,15,13,22,28,14) AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr30pool, -- 080
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (26,15,13,22,28,14) AND "ContractValue" = 'Agency' AND "Archived" = false) jr30agcy, -- 081
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (26,15,13,22,28,14) AND "ContractValue" = 'Other' AND "Archived" = false) jr30oth, -- 082
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (26,15,13,22,28,14) AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr30emp, -- 083
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (26,15,13,22,28,14) AND "Archived" = false) jr30work, -- 084
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (26,15,13,22,28,14) AND "JobType" = 'Starters'),-1) END jr30strt, --****COALESCE**** -- 085
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (26,15,13,22,28,14) AND "JobType" = 'Leavers'),-1) END jr30stop, --****COALESCE**** -- 086
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (26,15,13,22,28,14) AND "JobType" = 'Vacancies'),-1) END jr30vacy, --****COALESCE**** -- 087
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (27,18,23,4,24,17) AND "Archived" = false LIMIT 1),0) jr31flag, -- 088
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (27,18,23,4,24,17) AND "ContractValue" = 'Permanent' AND "Archived" = false) jr31perm, -- 089
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (27,18,23,4,24,17) AND "ContractValue" = 'Temporary' AND "Archived" = false) jr31temp, -- 090
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (27,18,23,4,24,17) AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr31pool, -- 091
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (27,18,23,4,24,17) AND "ContractValue" = 'Agency' AND "Archived" = false) jr31agcy, -- 092
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (27,18,23,4,24,17) AND "ContractValue" = 'Other' AND "Archived" = false) jr31oth, -- 093
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (27,18,23,4,24,17) AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr31emp, -- 094
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (27,18,23,4,24,17) AND "Archived" = false) jr31work, -- 095
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (27,18,23,4,24,17) AND "JobType" = 'Starters'),-1) END jr31strt, --****COALESCE**** -- 096
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (27,18,23,4,24,17) AND "JobType" = 'Leavers'),-1) END jr31stop, --****COALESCE**** -- 097
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (27,18,23,4,24,17) AND "JobType" = 'Vacancies'),-1) END jr31vacy, --****COALESCE**** -- 098
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (2,5,21,1,19,7,8,9,6) AND "Archived" = false LIMIT 1),0) jr32flag, -- 099
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (2,5,21,1,19,7,8,9,6) AND "ContractValue" = 'Permanent' AND "Archived" = false) jr32perm, -- 100
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (2,5,21,1,19,7,8,9,6) AND "ContractValue" = 'Temporary' AND "Archived" = false) jr32temp, -- 101
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (2,5,21,1,19,7,8,9,6) AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr32pool, -- 102
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (2,5,21,1,19,7,8,9,6) AND "ContractValue" = 'Agency' AND "Archived" = false) jr32agcy, -- 103
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (2,5,21,1,19,7,8,9,6) AND "ContractValue" = 'Other' AND "Archived" = false) jr32oth, -- 104
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (2,5,21,1,19,7,8,9,6) AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr32emp, -- 105
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" IN (2,5,21,1,19,7,8,9,6) AND "Archived" = false) jr32work, -- 106
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (2,5,21,1,19,7,8,9,6) AND "JobType" = 'Starters'),-1) END jr32strt, --****COALESCE**** -- 107
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (2,5,21,1,19,7,8,9,6) AND "JobType" = 'Leavers'),-1) END jr32stop, --****COALESCE**** -- 108
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" IN (2,5,21,1,19,7,8,9,6) AND "JobType" = 'Vacancies'),-1) END jr32vacy, --****COALESCE**** -- 109
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 26 AND "Archived" = false LIMIT 1),0) jr01flag, -- 110
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 26 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr01perm, -- 111
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 26 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr01temp, -- 112
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 26 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr01pool, -- 113
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 26 AND "ContractValue" = 'Agency' AND "Archived" = false) jr01agcy, -- 114
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 26 AND "ContractValue" = 'Other' AND "Archived" = false) jr01oth, -- 115
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 26 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr01emp, -- 116
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 26 AND "Archived" = false) jr01work, -- 117
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 26 AND "JobType" = 'Starters'),-1) END jr01strt, --****COALESCE**** -- 118
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 26 AND "JobType" = 'Leavers'),-1) END jr01stop, --****COALESCE**** -- 119
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 26 AND "JobType" = 'Vacancies'),-1) END jr01vacy, --****COALESCE**** -- 120
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 15 AND "Archived" = false LIMIT 1),0) jr02flag, -- 121
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 15 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr02perm, -- 122
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 15 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr02temp, -- 123
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 15 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr02pool, -- 124
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 15 AND "ContractValue" = 'Agency' AND "Archived" = false) jr02agcy, -- 125
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 15 AND "ContractValue" = 'Other' AND "Archived" = false) jr02oth, -- 126
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 15 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr02emp, -- 127
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 15 AND "Archived" = false) jr02work, -- 128
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 15 AND "JobType" = 'Starters'),-1) END jr02strt, --****COALESCE**** -- 129
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 15 AND "JobType" = 'Leavers'),-1) END jr02stop, --****COALESCE**** -- 130
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 15 AND "JobType" = 'Vacancies'),-1) END jr02vacy, --****COALESCE**** -- 131
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 13 AND "Archived" = false LIMIT 1),0) jr03flag, -- 132
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 13 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr03perm, -- 133
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 13 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr03temp, -- 134
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 13 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr03pool, -- 135
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 13 AND "ContractValue" = 'Agency' AND "Archived" = false) jr03agcy, -- 136
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 13 AND "ContractValue" = 'Other' AND "Archived" = false) jr03oth, -- 137
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 13 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr03emp, -- 138
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 13 AND "Archived" = false) jr03work, -- 139
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 13 AND "JobType" = 'Starters'),-1) END jr03strt, --****COALESCE**** -- 140
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 13 AND "JobType" = 'Leavers'),-1) END jr03stop, --****COALESCE**** -- 141
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 13 AND "JobType" = 'Vacancies'),-1) END jr03vacy, --****COALESCE**** -- 142
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 22 AND "Archived" = false LIMIT 1),0) jr04flag, -- 143
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 22 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr04perm, -- 144
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 22 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr04temp, -- 145
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 22 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr04pool, -- 146
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 22 AND "ContractValue" = 'Agency' AND "Archived" = false) jr04agcy, -- 147
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 22 AND "ContractValue" = 'Other' AND "Archived" = false) jr04oth, -- 148
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 22 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr04emp, -- 149
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 22 AND "Archived" = false) jr04work, -- 150
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 22 AND "JobType" = 'Starters'),-1) END jr04strt, --****COALESCE**** -- 151
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 22 AND "JobType" = 'Leavers'),-1) END jr04stop, --****COALESCE**** -- 152
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 22 AND "JobType" = 'Vacancies'),-1) END jr04vacy, --****COALESCE**** -- 153
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 28 AND "Archived" = false LIMIT 1),0) jr05flag, -- 154
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 28 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr05perm, -- 155
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 28 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr05temp, -- 156
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 28 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr05pool, -- 157
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 28 AND "ContractValue" = 'Agency' AND "Archived" = false) jr05agcy, -- 158
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 28 AND "ContractValue" = 'Other' AND "Archived" = false) jr05oth, -- 159
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 28 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr05emp, -- 160
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 28 AND "Archived" = false) jr05work, -- 161
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 28 AND "JobType" = 'Starters'),-1) END jr05strt, --****COALESCE**** -- 162
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 28 AND "JobType" = 'Leavers'),-1) END jr05stop, --****COALESCE**** -- 163
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 28 AND "JobType" = 'Vacancies'),-1) END jr05vacy, --****COALESCE**** -- 164
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 27 AND "Archived" = false LIMIT 1),0) jr06flag, -- 165
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 27 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr06perm, -- 166
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 27 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr06temp, -- 167
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 27 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr06pool, -- 168
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 27 AND "ContractValue" = 'Agency' AND "Archived" = false) jr06agcy, -- 169
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 27 AND "ContractValue" = 'Other' AND "Archived" = false) jr06oth, -- 170
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 27 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr06emp, -- 171
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 27 AND "Archived" = false) jr06work, -- 172
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 27 AND "JobType" = 'Starters'),-1) END jr06strt, --****COALESCE**** -- 173
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 27 AND "JobType" = 'Leavers'),-1) END jr06stop, --****COALESCE**** -- 174
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 27 AND "JobType" = 'Vacancies'),-1) END jr06vacy, --****COALESCE**** -- 175
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 25 AND "Archived" = false LIMIT 1),0) jr07flag, -- 176
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 25 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr07perm, -- 177
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 25 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr07temp, -- 178
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 25 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr07pool, -- 179
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 25 AND "ContractValue" = 'Agency' AND "Archived" = false) jr07agcy, -- 180
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 25 AND "ContractValue" = 'Other' AND "Archived" = false) jr07oth, -- 181
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 25 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr07emp, -- 182
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 25 AND "Archived" = false) jr07work, -- 183
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 25 AND "JobType" = 'Starters'),-1) END jr07strt, --****COALESCE**** -- 184
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 25 AND "JobType" = 'Leavers'),-1) END jr07stop, --****COALESCE**** -- 185
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 25 AND "JobType" = 'Vacancies'),-1) END jr07vacy, --****COALESCE**** -- 186
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 10 AND "Archived" = false LIMIT 1),0) jr08flag, -- 187
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 10 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr08perm, -- 188
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 10 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr08temp, -- 189
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 10 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr08pool, -- 190
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 10 AND "ContractValue" = 'Agency' AND "Archived" = false) jr08agcy, -- 191
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 10 AND "ContractValue" = 'Other' AND "Archived" = false) jr08oth, -- 192
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 10 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr08emp, -- 193
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 10 AND "Archived" = false) jr08work, -- 194
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 10 AND "JobType" = 'Starters'),-1) END jr08strt, --****COALESCE**** -- 195
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 10 AND "JobType" = 'Leavers'),-1) END jr08stop, --****COALESCE**** -- 196
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 10 AND "JobType" = 'Vacancies'),-1) END jr08vacy, --****COALESCE**** -- 197
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 11 AND "Archived" = false LIMIT 1),0) jr09flag, -- 198
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 11 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr09perm, -- 199
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 11 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr09temp, -- 200
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 11 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr09pool, -- 201
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 11 AND "ContractValue" = 'Agency' AND "Archived" = false) jr09agcy, -- 202
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 11 AND "ContractValue" = 'Other' AND "Archived" = false) jr09oth, -- 203
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 11 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr09emp, -- 204
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 11 AND "Archived" = false) jr09work, -- 205
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 11 AND "JobType" = 'Starters'),-1) END jr09strt, --****COALESCE**** -- 206
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 11 AND "JobType" = 'Leavers'),-1) END jr09stop, --****COALESCE**** -- 207
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 11 AND "JobType" = 'Vacancies'),-1) END jr09vacy, --****COALESCE**** -- 208
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 12 AND "Archived" = false LIMIT 1),0) jr10flag, -- 209
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 12 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr10perm, -- 210
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 12 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr10temp, -- 211
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 12 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr10pool, -- 212
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 12 AND "ContractValue" = 'Agency' AND "Archived" = false) jr10agcy, -- 213
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 12 AND "ContractValue" = 'Other' AND "Archived" = false) jr10oth, -- 214
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 12 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr10emp, -- 215
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 12 AND "Archived" = false) jr10work, -- 216
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 12 AND "JobType" = 'Starters'),-1) END jr10strt, --****COALESCE**** -- 217
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 12 AND "JobType" = 'Leavers'),-1) END jr10stop, --****COALESCE**** -- 218
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 12 AND "JobType" = 'Vacancies'),-1) END jr10vacy, --****COALESCE**** -- 219
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 3 AND "Archived" = false LIMIT 1),0) jr11flag, -- 220
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 3 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr11perm, -- 221
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 3 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr11temp, -- 222
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 3 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr11pool, -- 223
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 3 AND "ContractValue" = 'Agency' AND "Archived" = false) jr11agcy, -- 224
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 3 AND "ContractValue" = 'Other' AND "Archived" = false) jr11oth, -- 225
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 3 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr11emp, -- 226
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 3 AND "Archived" = false) jr11work, -- 227
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 3 AND "JobType" = 'Starters'),-1) END jr11strt, --****COALESCE**** -- 228
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 3 AND "JobType" = 'Leavers'),-1) END jr11stop, --****COALESCE**** -- 229
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 3 AND "JobType" = 'Vacancies'),-1) END jr11vacy, --****COALESCE**** -- 230
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 18 AND "Archived" = false LIMIT 1),0) jr15flag, -- 231
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 18 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr15perm, -- 232
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 18 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr15temp, -- 233
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 18 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr15pool, -- 234
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 18 AND "ContractValue" = 'Agency' AND "Archived" = false) jr15agcy, -- 235
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 18 AND "ContractValue" = 'Other' AND "Archived" = false) jr15oth, -- 236
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 18 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr15emp, -- 237
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 18 AND "Archived" = false) jr15work, -- 238
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 18 AND "JobType" = 'Starters'),-1) END jr15strt, --****COALESCE**** -- 239
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 18 AND "JobType" = 'Leavers'),-1) END jr15stop, --****COALESCE**** -- 240
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 18 AND "JobType" = 'Vacancies'),-1) END jr15vacy, --****COALESCE**** -- 241
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 23 AND "Archived" = false LIMIT 1),0) jr16flag, -- 242
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 23 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr16perm, -- 243
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 23 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr16temp, -- 244
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 23 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr16pool, -- 245
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 23 AND "ContractValue" = 'Agency' AND "Archived" = false) jr16agcy, -- 246
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 23 AND "ContractValue" = 'Other' AND "Archived" = false) jr16oth, -- 247
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 23 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr16emp, -- 248
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 23 AND "Archived" = false) jr16work, -- 249
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 23 AND "JobType" = 'Starters'),-1) END jr16strt, --****COALESCE**** -- 250
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 23 AND "JobType" = 'Leavers'),-1) END jr16stop, --****COALESCE**** -- 251
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 23 AND "JobType" = 'Vacancies'),-1) END jr16vacy, --****COALESCE**** -- 252
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 4 AND "Archived" = false LIMIT 1),0) jr17flag, -- 253
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 4 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr17perm, -- 254
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 4 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr17temp, -- 255
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 4 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr17pool, -- 256
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 4 AND "ContractValue" = 'Agency' AND "Archived" = false) jr17agcy, -- 257
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 4 AND "ContractValue" = 'Other' AND "Archived" = false) jr17oth, -- 258
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 4 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr17emp, -- 259
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 4 AND "Archived" = false) jr17work, -- 260
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 4 AND "JobType" = 'Starters'),-1) END jr17strt, --****COALESCE**** -- 261
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 4 AND "JobType" = 'Leavers'),-1) END jr17stop, --****COALESCE**** -- 262
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 4 AND "JobType" = 'Vacancies'),-1) END jr17vacy, --****COALESCE**** -- 263
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 29 AND "Archived" = false LIMIT 1),0) jr22flag, -- 264
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 29 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr22perm, -- 265
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 29 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr22temp, -- 266
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 29 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr22pool, -- 267
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 29 AND "ContractValue" = 'Agency' AND "Archived" = false) jr22agcy, -- 268
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 29 AND "ContractValue" = 'Other' AND "Archived" = false) jr22oth, -- 269
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 29 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr22emp, -- 270
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 29 AND "Archived" = false) jr22work, -- 271
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 29 AND "JobType" = 'Starters'),-1) END jr22strt, --****COALESCE**** -- 272
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 29 AND "JobType" = 'Leavers'),-1) END jr22stop, --****COALESCE**** -- 273
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 29 AND "JobType" = 'Vacancies'),-1) END jr22vacy, --****COALESCE**** -- 274
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 20 AND "Archived" = false LIMIT 1),0) jr23flag, -- 275
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 20 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr23perm, -- 276
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 20 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr23temp, -- 277
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 20 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr23pool, -- 278
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 20 AND "ContractValue" = 'Agency' AND "Archived" = false) jr23agcy, -- 279
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 20 AND "ContractValue" = 'Other' AND "Archived" = false) jr23oth, -- 280
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 20 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr23emp, -- 281
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 20 AND "Archived" = false) jr23work, -- 282
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 20 AND "JobType" = 'Starters'),-1) END jr23strt, --****COALESCE**** -- 283
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 20 AND "JobType" = 'Leavers'),-1) END jr23stop, --****COALESCE**** -- 284
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 20 AND "JobType" = 'Vacancies'),-1) END jr23vacy, --****COALESCE**** -- 285
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 14 AND "Archived" = false LIMIT 1),0) jr24flag, -- 286
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 14 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr24perm, -- 287
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 14 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr24temp, -- 288
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 14 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr24pool, -- 289
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 14 AND "ContractValue" = 'Agency' AND "Archived" = false) jr24agcy, -- 290
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 14 AND "ContractValue" = 'Other' AND "Archived" = false) jr24oth, -- 291
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 14 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr24emp, -- 292
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 14 AND "Archived" = false) jr24work, -- 293
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 14 AND "JobType" = 'Starters'),-1) END jr24strt, --****COALESCE**** -- 294
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 14 AND "JobType" = 'Leavers'),-1) END jr24stop, --****COALESCE**** -- 295
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 14 AND "JobType" = 'Vacancies'),-1) END jr24vacy, --****COALESCE**** -- 296
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 2 AND "Archived" = false LIMIT 1),0) jr25flag, -- 297
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 2 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr25perm, -- 298
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 2 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr25temp, -- 299
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 2 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr25pool, -- 300
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 2 AND "ContractValue" = 'Agency' AND "Archived" = false) jr25agcy, -- 301
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 2 AND "ContractValue" = 'Other' AND "Archived" = false) jr25oth, -- 302
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 2 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr25emp, -- 303
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 2 AND "Archived" = false) jr25work, -- 304
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 2 AND "JobType" = 'Starters'),-1) END jr25strt, --****COALESCE**** -- 305
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 2 AND "JobType" = 'Leavers'),-1) END jr25stop, --****COALESCE**** -- 306
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 2 AND "JobType" = 'Vacancies'),-1) END jr25vacy, --****COALESCE**** -- 307
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 5 AND "Archived" = false LIMIT 1),0) jr26flag, -- 308
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 5 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr26perm, -- 309
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 5 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr26temp, -- 310
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 5 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr26pool, -- 311
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 5 AND "ContractValue" = 'Agency' AND "Archived" = false) jr26agcy, -- 312
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 5 AND "ContractValue" = 'Other' AND "Archived" = false) jr26oth, -- 313
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 5 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr26emp, -- 314
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 5 AND "Archived" = false) jr26work, -- 315
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 5 AND "JobType" = 'Starters'),-1) END jr26strt, --****COALESCE**** -- 316
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 5 AND "JobType" = 'Leavers'),-1) END jr26stop, --****COALESCE**** -- 317
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 5 AND "JobType" = 'Vacancies'),-1) END jr26vacy, --****COALESCE**** -- 318
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 21 AND "Archived" = false LIMIT 1),0) jr27flag, -- 319
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 21 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr27perm, -- 320
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 21 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr27temp, -- 321
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 21 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr27pool, -- 322
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 21 AND "ContractValue" = 'Agency' AND "Archived" = false) jr27agcy, -- 323
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 21 AND "ContractValue" = 'Other' AND "Archived" = false) jr27oth, -- 324
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 21 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr27emp, -- 325
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 21 AND "Archived" = false) jr27work, -- 326
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 21 AND "JobType" = 'Starters'),-1) END jr27strt, --****COALESCE**** -- 327
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 21 AND "JobType" = 'Leavers'),-1) END jr27stop, --****COALESCE**** -- 328
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 21 AND "JobType" = 'Vacancies'),-1) END jr27vacy, --****COALESCE**** -- 329
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 1 AND "Archived" = false LIMIT 1),0) jr34flag, -- 330
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 1 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr34perm, -- 331
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 1 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr34temp, -- 332
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 1 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr34pool, -- 333
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 1 AND "ContractValue" = 'Agency' AND "Archived" = false) jr34agcy, -- 334
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 1 AND "ContractValue" = 'Other' AND "Archived" = false) jr34oth, -- 335
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 1 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr34emp, -- 336
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 1 AND "Archived" = false) jr34work, -- 337
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 1 AND "JobType" = 'Starters'),-1) END jr34strt, --****COALESCE**** -- 338
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 1 AND "JobType" = 'Leavers'),-1) END jr34stop, --****COALESCE**** -- 339
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 1 AND "JobType" = 'Vacancies'),-1) END jr34vacy, --****COALESCE**** -- 340
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 24 AND "Archived" = false LIMIT 1),0) jr35flag, -- 341
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 24 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr35perm, -- 342
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 24 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr35temp, -- 343
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 24 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr35pool, -- 344
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 24 AND "ContractValue" = 'Agency' AND "Archived" = false) jr35agcy, -- 345
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 24 AND "ContractValue" = 'Other' AND "Archived" = false) jr35oth, -- 346
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 24 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr35emp, -- 347
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 24 AND "Archived" = false) jr35work, -- 348
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 24 AND "JobType" = 'Starters'),-1) END jr35strt, --****COALESCE**** -- 349
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 24 AND "JobType" = 'Leavers'),-1) END jr35stop, --****COALESCE**** -- 350
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 24 AND "JobType" = 'Vacancies'),-1) END jr35vacy, --****COALESCE**** -- 351
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 19 AND "Archived" = false LIMIT 1),0) jr36flag, -- 352
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 19 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr36perm, -- 353
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 19 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr36temp, -- 354
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 19 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr36pool, -- 355
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 19 AND "ContractValue" = 'Agency' AND "Archived" = false) jr36agcy, -- 356
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 19 AND "ContractValue" = 'Other' AND "Archived" = false) jr36oth, -- 357
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 19 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr36emp, -- 358
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 19 AND "Archived" = false) jr36work, -- 359
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 19 AND "JobType" = 'Starters'),-1) END jr36strt, --****COALESCE**** -- 360
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 19 AND "JobType" = 'Leavers'),-1) END jr36stop, --****COALESCE**** -- 361
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 19 AND "JobType" = 'Vacancies'),-1) END jr36vacy, --****COALESCE**** -- 362
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 17 AND "Archived" = false LIMIT 1),0) jr37flag, -- 363
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 17 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr37perm, -- 364
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 17 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr37temp, -- 365
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 17 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr37pool, -- 366
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 17 AND "ContractValue" = 'Agency' AND "Archived" = false) jr37agcy, -- 367
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 17 AND "ContractValue" = 'Other' AND "Archived" = false) jr37oth, -- 368
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 17 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr37emp, -- 369
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 17 AND "Archived" = false) jr37work, -- 370
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 17 AND "JobType" = 'Starters'),-1) END jr37strt, --****COALESCE**** -- 371
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 17 AND "JobType" = 'Leavers'),-1) END jr37stop, --****COALESCE**** -- 372
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 17 AND "JobType" = 'Vacancies'),-1) END jr37vacy, --****COALESCE**** -- 373
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 16 AND "Archived" = false LIMIT 1),0) jr38flag, -- 374
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 16 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr38perm, -- 375
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 16 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr38temp, -- 376
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 16 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr38pool, -- 377
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 16 AND "ContractValue" = 'Agency' AND "Archived" = false) jr38agcy, -- 378
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 16 AND "ContractValue" = 'Other' AND "Archived" = false) jr38oth, -- 379
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 16 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr38emp, -- 380
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 16 AND "Archived" = false) jr38work, -- 381
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 16 AND "JobType" = 'Starters'),-1) END jr38strt, --****COALESCE**** -- 382
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 16 AND "JobType" = 'Leavers'),-1) END jr38stop, --****COALESCE**** -- 383
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 16 AND "JobType" = 'Vacancies'),-1) END jr38vacy, --****COALESCE**** -- 384
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 7 AND "Archived" = false LIMIT 1),0) jr39flag, -- 385
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 7 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr39perm, -- 386
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 7 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr39temp, -- 387
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 7 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr39pool, -- 388
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 7 AND "ContractValue" = 'Agency' AND "Archived" = false) jr39agcy, -- 389
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 7 AND "ContractValue" = 'Other' AND "Archived" = false) jr39oth, -- 390
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 7 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr39emp, -- 391
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 7 AND "Archived" = false) jr39work, -- 392
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 7 AND "JobType" = 'Starters'),-1) END jr39strt, --****COALESCE**** -- 393
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 7 AND "JobType" = 'Leavers'),-1) END jr39stop, --****COALESCE**** -- 394
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 7 AND "JobType" = 'Vacancies'),-1) END jr39vacy, --****COALESCE**** -- 395
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 8 AND "Archived" = false LIMIT 1),0) jr40flag, -- 396
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 8 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr40perm, -- 397
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 8 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr40temp, -- 398
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 8 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr40pool, -- 399
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 8 AND "ContractValue" = 'Agency' AND "Archived" = false) jr40agcy, -- 400
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 8 AND "ContractValue" = 'Other' AND "Archived" = false) jr40oth, -- 401
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 8 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr40emp, -- 402
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 8 AND "Archived" = false) jr40work, -- 403
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 8 AND "JobType" = 'Starters'),-1) END jr40strt, --****COALESCE**** -- 404
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 8 AND "JobType" = 'Leavers'),-1) END jr40stop, --****COALESCE**** -- 405
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 8 AND "JobType" = 'Vacancies'),-1) END jr40vacy, --****COALESCE**** -- 406
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 9 AND "Archived" = false LIMIT 1),0) jr41flag, -- 407
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 9 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr41perm, -- 408
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 9 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr41temp, -- 409
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 9 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr41pool, -- 410
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 9 AND "ContractValue" = 'Agency' AND "Archived" = false) jr41agcy, -- 411
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 9 AND "ContractValue" = 'Other' AND "Archived" = false) jr41oth, -- 412
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 9 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr41emp, -- 413
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 9 AND "Archived" = false) jr41work, -- 414
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 9 AND "JobType" = 'Starters'),-1) END jr41strt, --****COALESCE**** -- 415
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 9 AND "JobType" = 'Leavers'),-1) END jr41stop, --****COALESCE**** -- 416
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 9 AND "JobType" = 'Vacancies'),-1) END jr41vacy, --****COALESCE**** -- 417
       COALESCE((SELECT 1 FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 6 AND "Archived" = false LIMIT 1),0) jr42flag, -- 418
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 6 AND "ContractValue" = 'Permanent' AND "Archived" = false) jr42perm, -- 419
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 6 AND "ContractValue" = 'Temporary' AND "Archived" = false) jr42temp, -- 420
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 6 AND "ContractValue" = 'Pool/Bank' AND "Archived" = false) jr42pool, -- 421
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 6 AND "ContractValue" = 'Agency' AND "Archived" = false) jr42agcy, -- 422
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 6 AND "ContractValue" = 'Other' AND "Archived" = false) jr42oth, -- 423
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 6 AND "ContractValue" IN ('Permanent','Temporary') AND "Archived" = false) jr42emp, -- 424
       (SELECT COUNT(1) FROM "Worker" WHERE "EstablishmentFK" = e."EstablishmentID" AND "MainJobFKValue" = 6 AND "Archived" = false) jr42work, -- 425
       CASE WHEN "StartersValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 6 AND "JobType" = 'Starters'),-1) END jr42strt, --****COALESCE**** -- 426
       CASE WHEN "LeaversValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 6 AND "JobType" = 'Leavers'),-1) END jr42stop, --****COALESCE**** -- 427
       CASE WHEN "VacanciesValue" = 'None' THEN 0 ELSE COALESCE((SELECT SUM("Total") FROM "EstablishmentJobs" WHERE "EstablishmentID" = e."EstablishmentID" AND "JobID" = 6 AND "JobType" = 'Vacancies'),-1) END jr42vacy, --****COALESCE**** -- 428
       TO_CHAR("ServiceUsersChangedAt",'DD/MM/YYYY') ut_changedate, -- 429
       TO_CHAR("ServiceUsersSavedAt",'DD/MM/YYYY') ut_savedate, -- 430
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 1 LIMIT 1),0) ut01flag, -- 431
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 2 LIMIT 1),0) ut02flag, -- 432
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 3 LIMIT 1),0) ut22flag, -- 433
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 4 LIMIT 1),0) ut23flag, -- 434
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 5 LIMIT 1),0) ut25flag, -- 435
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 6 LIMIT 1),0) ut26flag, -- 436
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 7 LIMIT 1),0) ut27flag, -- 437
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 8 LIMIT 1),0) ut46flag, -- 438
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 9 LIMIT 1),0) ut03flag, -- 439
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 10 LIMIT 1),0) ut28flag, -- 440
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 11 LIMIT 1),0) ut06flag, -- 441
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 12 LIMIT 1),0) ut29flag, -- 442
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 13 LIMIT 1),0) ut05flag, -- 443
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 14 LIMIT 1),0) ut04flag, -- 444
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 15 LIMIT 1),0) ut07flag, -- 445
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 16 LIMIT 1),0) ut08flag, -- 446
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 17 LIMIT 1),0) ut31flag, -- 447
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 18 LIMIT 1),0) ut09flag, -- 448
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 19 LIMIT 1),0) ut45flag, -- 449
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 20 LIMIT 1),0) ut18flag, -- 450
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 21 LIMIT 1),0) ut19flag, -- 451
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 22 LIMIT 1),0) ut20flag, -- 452
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 23 LIMIT 1),0) ut21flag, -- 453
       TO_CHAR(GREATEST("MainServiceFKChangedAt","OtherServicesChangedAt"),'DD/MM/YYYY') st_changedate, -- 454
       TO_CHAR(GREATEST("MainServiceFKSavedAt","OtherServicesSavedAt"),'DD/MM/YYYY') st_savedate, -- 455
       CASE
          WHEN "MainServiceFKValue" = 24 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 24) = 1 THEN 1
          ELSE 0
       END st01flag, -- 456
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 24 AND sc."Type" = 'Capacity'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st01cap, --****COALESCE**** -- 457
       CASE
          WHEN "MainServiceFKValue" = 24 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 24) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st01cap_changedate, -- 458
       CASE
          WHEN "MainServiceFKValue" = 24 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 24) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st01cap_savedate, -- 459
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 24 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st01util, --****COALESCE**** -- 460
       CASE
          WHEN "MainServiceFKValue" = 24 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 24) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st01util_changedate, -- 461
       CASE
          WHEN "MainServiceFKValue" = 24 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 24) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st01util_savedate, -- 462
       CASE
          WHEN "MainServiceFKValue" = 25 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 25) = 1 THEN 1
          ELSE 0
       END st02flag, -- 463
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 25 AND sc."Type" = 'Capacity'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st02cap, --****COALESCE**** -- 464
       CASE
          WHEN "MainServiceFKValue" = 25 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 25) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st02cap_changedate, -- 465
       CASE
          WHEN "MainServiceFKValue" = 25 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 25) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st02cap_savedate, -- 466
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 25 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st02util, --****COALESCE**** -- 467
       CASE
          WHEN "MainServiceFKValue" = 25 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 25) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st02util_changedate, -- 468
       CASE
          WHEN "MainServiceFKValue" = 25 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 25) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st02util_savedate, -- 469
       CASE
          WHEN "MainServiceFKValue" = 13 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 13) = 1 THEN 1
          ELSE 0
       END st53flag, -- 470
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 13 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st53util, --****COALESCE**** -- 471
       CASE
          WHEN "MainServiceFKValue" = 13 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 13) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st53util_changedate, -- 472
       CASE
          WHEN "MainServiceFKValue" = 13 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 13) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st53util_savedate, -- 473
       CASE
          WHEN "MainServiceFKValue" = 12 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 12) = 1 THEN 1
          ELSE 0
       END st05flag, -- 474
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 12 AND sc."Type" = 'Capacity'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st05cap, --****COALESCE**** -- 475
       CASE
          WHEN "MainServiceFKValue" = 12 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 12) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st05cap_changedate, -- 476
       CASE
          WHEN "MainServiceFKValue" = 12 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 12) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st05cap_savedate, -- 477
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 12 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st05util, --****COALESCE**** -- 478
       CASE
          WHEN "MainServiceFKValue" = 12 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 12) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st05util_changedate, -- 479
       CASE
          WHEN "MainServiceFKValue" = 12 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 12) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st05util_savedate, -- 480
       CASE
          WHEN "MainServiceFKValue" = 9 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 9) = 1 THEN 1
          ELSE 0
       END st06flag, -- 481
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 9 AND sc."Type" = 'Capacity'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st06cap, --****COALESCE**** -- 482
       CASE
          WHEN "MainServiceFKValue" = 9 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 9) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st06cap_changedate, -- 483
       CASE
          WHEN "MainServiceFKValue" = 9 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 9) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st06cap_savedate, -- 484
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 9 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st06util, --****COALESCE**** -- 485
       CASE
          WHEN "MainServiceFKValue" = 9 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 9) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st06util_changedate, -- 486
       CASE
          WHEN "MainServiceFKValue" = 9 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 9) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st06util_savedate, -- 487
       CASE
          WHEN "MainServiceFKValue" = 10 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 10) = 1 THEN 1
          ELSE 0
       END st07flag, -- 488
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 10 AND sc."Type" = 'Capacity'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st07cap, --****COALESCE**** -- 489
       CASE
          WHEN "MainServiceFKValue" = 10 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 10) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st07cap_changedate, -- 490
       CASE
          WHEN "MainServiceFKValue" = 10 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 10) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st07cap_savedate, -- 491
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 10 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st07util, --****COALESCE**** -- 492
       CASE
          WHEN "MainServiceFKValue" = 10 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 10) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st07util_changedate, -- 493
       CASE
          WHEN "MainServiceFKValue" = 10 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 10) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st07util_savedate, -- 494
       CASE
          WHEN "MainServiceFKValue" = 11 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 11) = 1 THEN 1
          ELSE 0
       END st10flag, -- 495
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 11 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st10util, --****COALESCE**** -- 496
       CASE
          WHEN "MainServiceFKValue" = 11 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 11) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st10util_changedate, -- 497
       CASE
          WHEN "MainServiceFKValue" = 11 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 11) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st10util_savedate, -- 498
       CASE
          WHEN "MainServiceFKValue" = 20 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 20) = 1 THEN 1
          ELSE 0
       END st08flag, -- 499
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 20 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st08util, --****COALESCE**** -- 500
       CASE
          WHEN "MainServiceFKValue" = 20 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 20) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st08util_changedate, -- 501
       CASE
          WHEN "MainServiceFKValue" = 20 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 20) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st08util_savedate, -- 502
       CASE
          WHEN "MainServiceFKValue" = 21 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 21) = 1 THEN 1
          ELSE 0
       END st54flag, -- 503
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 21 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st54util, --****COALESCE**** -- 504
       CASE
          WHEN "MainServiceFKValue" = 21 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 21) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st54util_changedate, -- 505
       CASE
          WHEN "MainServiceFKValue" = 21 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 21) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st54util_savedate, -- 506
       CASE
          WHEN "MainServiceFKValue" = 22 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 22) = 1 THEN 1
          ELSE 0
       END st74flag, -- 507
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 22 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st74util, --****COALESCE**** -- 508
       CASE
          WHEN "MainServiceFKValue" = 22 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 22) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st74util_changedate, -- 509
       CASE
          WHEN "MainServiceFKValue" = 22 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 22) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st74util_savedate, -- 510
       CASE
          WHEN "MainServiceFKValue" = 23 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 23) = 1 THEN 1
          ELSE 0
       END st55flag, -- 511
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 23 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st55util, --****COALESCE**** -- 512
       CASE
          WHEN "MainServiceFKValue" = 23 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 23) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st55util_changedate, -- 513
       CASE
          WHEN "MainServiceFKValue" = 23 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 23) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st55util_savedate, -- 514
       CASE
          WHEN "MainServiceFKValue" = 35 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 35) = 1 THEN 1
          ELSE 0
       END st73flag, -- 515
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 35 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st73util, --****COALESCE**** -- 516
       CASE
          WHEN "MainServiceFKValue" = 35 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 35) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st73util_changedate, -- 517
       CASE
          WHEN "MainServiceFKValue" = 35 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 35) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st73util_savedate, -- 518
       CASE
          WHEN "MainServiceFKValue" = 18 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 18) = 1 THEN 1
          ELSE 0
       END st12flag, -- 519
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 18 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st12util, --****COALESCE**** -- 520
       CASE
          WHEN "MainServiceFKValue" = 18 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 18) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st12util_changedate, -- 521
       CASE
          WHEN "MainServiceFKValue" = 18 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 18) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st12util_savedate, -- 522
       CASE
          WHEN "MainServiceFKValue" = 1 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 1) = 1 THEN 1
          ELSE 0
       END st13flag, -- 523
       CASE
          WHEN "MainServiceFKValue" = 2 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 2) = 1 THEN 1
          ELSE 0
       END st15flag, -- 524
       CASE
          WHEN "MainServiceFKValue" = 3 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 3) = 1 THEN 1
          ELSE 0
       END st18flag, -- 525
       CASE
          WHEN "MainServiceFKValue" = 4 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 4) = 1 THEN 1
          ELSE 0
       END st20flag, -- 526
       CASE
          WHEN "MainServiceFKValue" = 5 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 5) = 1 THEN 1
          ELSE 0
       END st19flag, -- 527
       CASE
          WHEN "MainServiceFKValue" = 19 OR
               (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 19) = 1 THEN 1
          ELSE 0
       END st17flag, -- 528
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 19 AND sc."Type" = 'Capacity'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st17cap, --****COALESCE**** -- 529
       CASE
          WHEN "MainServiceFKValue" = 19 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 19) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st17cap_changedate, -- 530
       CASE
          WHEN "MainServiceFKValue" = 19 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 19) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st17cap_savedate, -- 531
       COALESCE((
          SELECT "Answer"
          FROM   "EstablishmentCapacity" ec
                 JOIN "ServicesCapacity" sc ON ec."ServiceCapacityID" = sc."ServiceCapacityID" AND sc."ServiceID" = 19 AND sc."Type" = 'Utilisation'
          WHERE  ec."EstablishmentID" = e."EstablishmentID"
       ), -1) st17util, --****COALESCE**** -- 532
       CASE
          WHEN "MainServiceFKValue" = 19 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 19) = 1 THEN
             TO_CHAR("CapacityServicesChangedAt",'DD/MM/YYYY')
          ELSE NULL
       END st17util_changedate, -- 533
       CASE
          WHEN "MainServiceFKValue" = 19 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 19) = 1 THEN
             TO_CHAR("CapacityServicesSavedAt",'DD/MM/YYYY')
          ELSE NULL
       END st17util_savedate, -- 534
       CASE
          WHEN "MainServiceFKValue" = 7 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 7) = 1 THEN 1
          ELSE 0
       END st14flag, -- 535
       CASE
          WHEN "MainServiceFKValue" = 8 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 8) = 1 THEN 1
          ELSE 0
       END st16flag, -- 536
       CASE
          WHEN "MainServiceFKValue" = 6 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 6) = 1 THEN 1
          ELSE 0
       END st21flag, -- 537
       CASE
          WHEN "MainServiceFKValue" = 26 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 26) = 1 THEN 1
          ELSE 0
       END st63flag, -- 538
       CASE
          WHEN "MainServiceFKValue" = 27 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 27) = 1 THEN 1
          ELSE 0
       END st61flag, -- 539
       CASE
          WHEN "MainServiceFKValue" = 28 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 28) = 1 THEN 1
          ELSE 0
       END st62flag, -- 540
       CASE
          WHEN "MainServiceFKValue" = 29 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 29) = 1 THEN 1
          ELSE 0
       END st64flag, -- 541
       CASE
          WHEN "MainServiceFKValue" = 30 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 30) = 1 THEN 1
          ELSE 0
       END st66flag, -- 542
       CASE
          WHEN "MainServiceFKValue" = 31 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 31) = 1 THEN 1
          ELSE 0
       END st68flag, -- 543
       CASE
          WHEN "MainServiceFKValue" = 32 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 32) = 1 THEN 1
          ELSE 0
       END st67flag, -- 544
       CASE
          WHEN "MainServiceFKValue" = 33 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 33) = 1 THEN 1
          ELSE 0
       END st69flag, -- 545
       CASE
          WHEN "MainServiceFKValue" = 34 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 34) = 1 THEN 1
          ELSE 0
       END st70flag, -- 546
       CASE
          WHEN "MainServiceFKValue" = 17 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 17) = 1 THEN 1
          ELSE 0
       END st71flag, -- 547
       CASE
          WHEN "MainServiceFKValue" = 14 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 14) = 1 THEN 1
          ELSE 0
       END st75flag, -- 548
       CASE
          WHEN "MainServiceFKValue" = 16 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 16) = 1 THEN 1
          ELSE 0
       END st72flag, -- 549
       CASE
          WHEN "MainServiceFKValue" = 36 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 36) = 1 THEN 1
          ELSE 0
       END st60flag, -- 550
       CASE
          WHEN "MainServiceFKValue" = 15 OR
             (SELECT COUNT(1) FROM "EstablishmentServices" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceID" = 15) = 1 THEN 1
          ELSE 0
       END st52flag -- 551
FROM   "Establishment" e JOIN "Afr1BatchiSkAi0mo" b ON e."EstablishmentID" = b."EstablishmentID" AND b."BatchNo" = <batch_id>;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT CURRENT_DATABASE(), NOW(), 'Database view created and started creating CSV file.' status;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
\a \f | \pset footer \o <csv_filename>
SELECT /*+ PARALLEL(v_afr_workspace_<batch_id>) */ * FROM v_afr_workspace_<batch_id>;
\o \a \f
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT CURRENT_DATABASE(), NOW(), 'Csv file created successfully.' status;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
\q
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SeQueL11 -- SQL for Workspace / Establishment analysis file report END.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SeQueL20 -- SQL for creating batch for Worker analysis file report BEGINs.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- SET work_mem = '32MB';
-- SELECT name, setting, unit, source FROM pg_settings WHERE name = 'work_mem';

SET SEARCH_PATH TO cqc;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT CURRENT_DATABASE(), NOW(), 'Started creating batch table.' status;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DROP TABLE IF EXISTS cqc."Afr2BatchiSkAi0mo" CASCADE; -- afr stands for Analysis File Report.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CREATE TABLE "Afr2BatchiSkAi0mo" AS
SELECT "EstablishmentID",
       "NoOfWorkers",
       SUM("NoOfWorkers") OVER (ORDER BY "NoOfWorkers" ASC, "EstablishmentID" ASC) "RunningTotal",
       NULL::INT "BatchNo",
       TO_DATE('<run_date>','DD-MM-YYYY')::DATE AS "RunDate"
FROM   (
          SELECT e."EstablishmentID",COUNT(1) "NoOfWorkers"
          FROM   "Establishment" e JOIN "Worker" w ON
                 e."EstablishmentID" = w."EstablishmentFK" AND
                 e."Archived" = w."Archived" AND
                 e."Archived" = false AND
                 e."Status" IS NULL
          GROUP  BY 1
       ) x;

CREATE INDEX "Afr2BatchiSkAi0mo_idx" ON "Afr2BatchiSkAi0mo"("BatchNo");

CREATE OR REPLACE FUNCTION create_batch_4_worker(p_no_of_workers integer) RETURNS VOID AS $$
DECLARE
   current_status INT := 1;
   no_of_batch_created INT := 0;
BEGIN
   LOOP
      current_status := (SELECT COUNT(1) FROM "Afr2BatchiSkAi0mo" WHERE "BatchNo" IS NULL);
      IF current_status <> 0 THEN
         no_of_batch_created := no_of_batch_created + 1;
      END IF;

      EXIT WHEN current_status = 0;

      UPDATE "Afr2BatchiSkAi0mo"
      SET    "BatchNo" = (SELECT MAX(COALESCE("BatchNo",0)) + 1 FROM "Afr2BatchiSkAi0mo")
      WHERE  "RunningTotal" <= p_no_of_workers
      AND    "BatchNo" IS NULL;

      UPDATE "Afr2BatchiSkAi0mo"
      SET    "RunningTotal" = "RunningTotal" - p_no_of_workers
      WHERE  "BatchNo" IS NULL;
   END LOOP;

   RAISE NOTICE 'Created: [ % ] batch.', (SELECT COUNT(DISTINCT "BatchNo") FROM "Afr2BatchiSkAi0mo");
END;
$$ LANGUAGE plpgsql;

SELECT create_batch_4_worker(20000);
DROP FUNCTION create_batch_4_worker(integer);
SELECT "BatchNo",COUNT(1) "NoOfWorkspaces",SUM("NoOfWorkers") "TotalNoOfWorkers" FROM "Afr2BatchiSkAi0mo" GROUP BY 1 ORDER BY 1;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SeQueL20 -- SQL for creating batch for Worker analysis file report END.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SeQueL21 -- SQL for Worker analysis file report BEGINs.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SET SEARCH_PATH TO cqc;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT CURRENT_DATABASE(), NOW(), 'Started creating database view.' status;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CREATE OR REPLACE TEMPORARY VIEW v_afr_worker_<batch_id> AS
SELECT 'M' || DATE_PART('year',(b."RunDate" - INTERVAL '1 day')) || LPAD(DATE_PART('month',(b."RunDate" - INTERVAL '1 day'))::TEXT,2,'0') period, -- 001
       e."EstablishmentID" establishmentid, -- 002
       e."TribalID" tribalid, -- 003
       w."TribalID" tribalid_worker, -- 003a
       e."ParentID" parentid, -- 004
       CASE WHEN e."IsParent" THEN e."EstablishmentID" ELSE CASE WHEN e."ParentID" IS NOT NULL THEN e."ParentID" ELSE e."EstablishmentID" END END orgid, -- 005
       e."NmdsID" nmdsid, -- 006
       w."ID" workerid, -- 007
       -- UPPER(ENCODE(HMAC(REPLACE("NationalInsuranceNumberValue",' ','') || TO_CHAR("DateOfBirthValue",'YYYYMMDD'),'<gidek>','md5'),'hex')) wrkglbid, -- 008
       1 wkplacestat, -- 009
       TO_CHAR(w."created",'DD/MM/YYYY') createddate, -- 010
       TO_CHAR(GREATEST(
          w."NameOrIdChangedAt",
          w."ContractChangedAt",
          w."MainJobFKChangedAt",
          w."ApprovedMentalHealthWorkerChangedAt",
          w."MainJobStartDateChangedAt",
          w."OtherJobsChangedAt",
          w."NationalInsuranceNumberChangedAt",
          w."DateOfBirthChangedAt",
          w."PostcodeChangedAt",
          w."DisabilityChangedAt",
          w."GenderChangedAt",
          w."EthnicityFKChangedAt",
          w."NationalityChangedAt",
          w."CountryOfBirthChangedAt",
          w."RecruitedFromChangedAt",
          w."BritishCitizenshipChangedAt",
          w."YearArrivedChangedAt",
          w."SocialCareStartDateChangedAt",
          w."DaysSickChangedAt",
          w."ZeroHoursContractChangedAt",
          w."WeeklyHoursAverageChangedAt",
          w."WeeklyHoursContractedChangedAt",
          w."AnnualHourlyPayChangedAt",
          w."CareCertificateChangedAt",
          w."ApprenticeshipTrainingChangedAt",
          w."QualificationInSocialCareChangedAt",
          w."SocialCareQualificationFKChangedAt",
          w."OtherQualificationsChangedAt",
          w."HighestQualificationFKChangedAt",
          w."CompletedChangedAt",
          w."RegisteredNurseChangedAt",
          w."NurseSpecialismFKChangedAt",
          w."LocalIdentifierChangedAt",
          w."EstablishmentFkChangedAt"),'DD/MM/YYYY') updateddate, -- 011
       TO_CHAR(GREATEST(
          w."NameOrIdSavedAt",
          w."ContractSavedAt",
          w."MainJobFKSavedAt",
          w."ApprovedMentalHealthWorkerSavedAt",
          w."MainJobStartDateSavedAt",
          w."OtherJobsSavedAt",
          w."NationalInsuranceNumberSavedAt",
          w."DateOfBirthSavedAt",
          w."PostcodeSavedAt",
          w."DisabilitySavedAt",
          w."GenderSavedAt",
          w."EthnicityFKSavedAt",
          w."NationalitySavedAt",
          w."CountryOfBirthSavedAt",
          w."RecruitedFromSavedAt",
          w."BritishCitizenshipSavedAt",
          w."YearArrivedSavedAt",
          w."SocialCareStartDateSavedAt",
          w."DaysSickSavedAt",
          w."ZeroHoursContractSavedAt",
          w."WeeklyHoursAverageSavedAt",
          w."WeeklyHoursContractedSavedAt",
          w."AnnualHourlyPaySavedAt",
          w."CareCertificateSavedAt",
          w."ApprenticeshipTrainingSavedAt",
          w."QualificationInSocialCareSavedAt",
          w."SocialCareQualificationFKSavedAt",
          w."OtherQualificationsSavedAt",
          w."HighestQualificationFKSavedAt",
          w."CompletedSavedAt",
          w."RegisteredNurseSavedAt",
          w."NurseSpecialismFKSavedAt",
          w."LocalIdentifierSavedAt",
          w."EstablishmentFkSavedAt"),'DD/MM/YYYY') savedate, -- 012
       CASE e."ShareDataWithCQC" WHEN true THEN 1 ELSE 0 END cqcpermission, -- 013
       CASE e."ShareDataWithLA" WHEN true THEN 1 ELSE 0 END lapermission, -- 014
       CASE WHEN e."IsRegulated" is true THEN 2 ELSE 0 END regtype, -- 015
       e."ProvID" providerid, -- 016
       e."LocationID" locationid, -- 017
       CASE e."EmployerTypeValue"
          WHEN 'Local Authority (adult services)' THEN 1
          WHEN 'Local Authority (generic/other)' THEN 3
          WHEN 'Private Sector' THEN 6
          WHEN 'Voluntary / Charity' THEN 7
          WHEN 'Other' THEN 8
       END esttype, -- 018
       COALESCE((SELECT "RegionID" FROM "Cssr" WHERE "NmdsIDLetter" = SUBSTRING(e."NmdsID",1,1) LIMIT 1),NULL,-1) regionid, -- 019
       COALESCE((SELECT "CssrID" FROM "Cssr" WHERE "NmdsIDLetter" = SUBSTRING(e."NmdsID",1,1) AND "LocalCustodianCode" IN (SELECT local_custodian_code FROM cqcref.pcodedata WHERE postcode = e."PostCode") LIMIT 1),NULL,-1) cssr, -- 020
       COALESCE((
          SELECT CASE "LocalAuthority"
                    WHEN 'Mid Bedfordshire' THEN 1
                    WHEN 'Bedford' THEN 2
                    WHEN 'South Bedfordshire' THEN 3
                    WHEN 'Cambridge' THEN 4
                    WHEN 'East Cambridgeshire' THEN 5
                    WHEN 'Fenland' THEN 6
                    WHEN 'Huntingdonshire' THEN 7
                    WHEN 'South Cambridgeshire' THEN 8
                    WHEN 'Basildon' THEN 9
                    WHEN 'Braintree' THEN 10
                    WHEN 'Brentwood' THEN 11
                    WHEN 'Castle Point' THEN 12
                    WHEN 'Chelmsford' THEN 13
                    WHEN 'Colchester' THEN 14
                    WHEN 'Epping Forest' THEN 15
                    WHEN 'Harlow' THEN 16
                    WHEN 'Maldon' THEN 17
                    WHEN 'Rochford' THEN 18
                    WHEN 'Tendring' THEN 19
                    WHEN 'Uttlesford' THEN 20
                    WHEN 'Broxbourne' THEN 21
                    WHEN 'Dacorum' THEN 22
                    WHEN 'East Hertfordshire' THEN 23
                    WHEN 'Hertsmere' THEN 24
                    WHEN 'North Hertfordshire' THEN 25
                    WHEN 'St Albans' THEN 26
                    WHEN 'Stevenage' THEN 27
                    WHEN 'Three Rivers' THEN 28
                    WHEN 'Watford' THEN 29
                    WHEN 'Welwyn Hatfield' THEN 30
                    WHEN 'Luton' THEN 31
                    WHEN 'Breckland' THEN 32
                    WHEN 'Broadland' THEN 33
                    WHEN 'Great Yarmouth' THEN 34
                    WHEN 'King`s Lynn and West Norfolk' THEN 35
                    WHEN 'North Norfolk' THEN 36
                    WHEN 'Norwich' THEN 37
                    WHEN 'South Norfolk' THEN 38
                    WHEN 'Peterborough' THEN 39
                    WHEN 'Southend-on-Sea' THEN 40
                    WHEN 'Babergh' THEN 41
                    WHEN 'Forest Heath' THEN 42
                    WHEN 'Ipswich' THEN 43
                    WHEN 'Mid Suffolk' THEN 44
                    WHEN 'St. Edmundsbury' THEN 45
                    WHEN 'Suffolk Coastal' THEN 46
                    WHEN 'Waveney' THEN 47
                    WHEN 'Thurrock' THEN 48
                    WHEN 'Derby' THEN 49
                    WHEN 'Amber Valley' THEN 50
                    WHEN 'Bolsover' THEN 51
                    WHEN 'Chesterfield' THEN 52
                    WHEN 'Derbyshire Dales' THEN 53
                    WHEN 'Erewash' THEN 54
                    WHEN 'High Peak' THEN 55
                    WHEN 'North East Derbyshire' THEN 56
                    WHEN 'South Derbyshire' THEN 57
                    WHEN 'Leicester' THEN 58
                    WHEN 'Blaby' THEN 59
                    WHEN 'Charnwood' THEN 60
                    WHEN 'Harborough' THEN 61
                    WHEN 'Hinckley and Bosworth' THEN 62
                    WHEN 'Melton' THEN 63
                    WHEN 'North West Leicestershire' THEN 64
                    WHEN 'Oadby and Wigston' THEN 65
                    WHEN 'Boston' THEN 66
                    WHEN 'East Lindsey' THEN 67
                    WHEN 'Lincoln' THEN 68
                    WHEN 'North Kesteven' THEN 69
                    WHEN 'South Holland' THEN 70
                    WHEN 'South Kesteven' THEN 71
                    WHEN 'West Lindsey' THEN 72
                    WHEN 'Corby' THEN 73
                    WHEN 'Daventry' THEN 74
                    WHEN 'East Northamptonshire' THEN 75
                    WHEN 'Kettering' THEN 76
                    WHEN 'Northampton' THEN 77
                    WHEN 'South Northamptonshire' THEN 78
                    WHEN 'Wellingborough' THEN 79
                    WHEN 'Nottingham' THEN 80
                    WHEN 'Ashfield' THEN 81
                    WHEN 'Bassetlaw' THEN 82
                    WHEN 'Broxtowe' THEN 83
                    WHEN 'Gedling' THEN 84
                    WHEN 'Mansfield' THEN 85
                    WHEN 'Newark and Sherwood' THEN 86
                    WHEN 'Rushcliffe' THEN 87
                    WHEN 'Rutland' THEN 88
                    WHEN 'Barking and Dagenham' THEN 89
                    WHEN 'Barnet' THEN 90
                    WHEN 'Bexley' THEN 91
                    WHEN 'Brent' THEN 92
                    WHEN 'Bromley' THEN 93
                    WHEN 'Camden' THEN 94
                    WHEN 'City of London' THEN 95
                    WHEN 'Croydon' THEN 96
                    WHEN 'Ealing' THEN 97
                    WHEN 'Enfield' THEN 98
                    WHEN 'Greenwich' THEN 99
                    WHEN 'Hackney' THEN 100
                    WHEN 'Hammersmith and Fulham' THEN 101
                    WHEN 'Haringey' THEN 102
                    WHEN 'Harrow' THEN 103
                    WHEN 'Havering' THEN 104
                    WHEN 'Hillingdon' THEN 105
                    WHEN 'Hounslow' THEN 106
                    WHEN 'Islington' THEN 107
                    WHEN 'Kensington and Chelsea' THEN 108
                    WHEN 'Kingston upon Thames' THEN 109
                    WHEN 'Lambeth' THEN 110
                    WHEN 'Lewisham' THEN 111
                    WHEN 'Merton' THEN 112
                    WHEN 'Newham' THEN 113
                    WHEN 'Redbridge' THEN 114
                    WHEN 'Richmond upon Thames' THEN 115
                    WHEN 'Southwark' THEN 116
                    WHEN 'Sutton' THEN 117
                    WHEN 'Tower Hamlets' THEN 118
                    WHEN 'Waltham Forest' THEN 119
                    WHEN 'Wandsworth' THEN 120
                    WHEN 'Westminster' THEN 121
                    WHEN 'Darlington' THEN 122
                    WHEN 'Chester-le-Street' THEN 123
                    WHEN 'Derwentside' THEN 124
                    WHEN 'Durham' THEN 125
                    WHEN 'Easington' THEN 126
                    WHEN 'Sedgefield' THEN 127
                    WHEN 'Teesdale' THEN 128
                    WHEN 'Wear Valley' THEN 129
                    WHEN 'Gateshead' THEN 130
                    WHEN 'Hartlepool' THEN 131
                    WHEN 'middlesbrough' THEN 132
                    WHEN 'Newcastle upon Tyne' THEN 133
                    WHEN 'North Tyneside' THEN 134
                    WHEN 'Alnwick' THEN 135
                    WHEN 'Berwick-upon-Tweed' THEN 136
                    WHEN 'Blyth Valley' THEN 137
                    WHEN 'Castle Morpeth' THEN 138
                    WHEN 'Tynedale' THEN 139
                    WHEN 'Wansbeck' THEN 140
                    WHEN 'Redcar and Cleveland' THEN 141
                    WHEN 'South Tyneside' THEN 142
                    WHEN 'Stockton-on-Tees' THEN 143
                    WHEN 'Sunderland' THEN 144
                    WHEN 'Blackburn with Darwen' THEN 145
                    WHEN 'Blackpool' THEN 146
                    WHEN 'Bolton' THEN 147
                    WHEN 'Bury' THEN 148
                    WHEN 'Chester' THEN 149
                    WHEN 'Congleton' THEN 150
                    WHEN 'Crewe and Nantwich' THEN 151
                    WHEN 'Ellesmere Port & Neston' THEN 152
                    WHEN 'Macclesfield' THEN 153
                    WHEN 'Vale Royal' THEN 154
                    WHEN 'Allerdale' THEN 155
                    WHEN 'Barrow-in-Furness' THEN 156
                    WHEN 'Carlisle' THEN 157
                    WHEN 'Copeland' THEN 158
                    WHEN 'Eden' THEN 159
                    WHEN 'South Lakeland' THEN 160
                    WHEN 'Halton' THEN 161
                    WHEN 'Knowsley' THEN 162
                    WHEN 'Burnley' THEN 163
                    WHEN 'Chorley' THEN 164
                    WHEN 'Fylde' THEN 165
                    WHEN 'Hyndburn' THEN 166
                    WHEN 'Lancaster' THEN 167
                    WHEN 'Pendle' THEN 168
                    WHEN 'Preston' THEN 169
                    WHEN 'Ribble Valley' THEN 170
                    WHEN 'Rossendale' THEN 171
                    WHEN 'South Ribble' THEN 172
                    WHEN 'West Lancashire' THEN 173
                    WHEN 'Wyre' THEN 174
                    WHEN 'Liverpool' THEN 175
                    WHEN 'Manchester' THEN 176
                    WHEN 'Oldham' THEN 177
                    WHEN 'Rochdale' THEN 178
                    WHEN 'Salford' THEN 179
                    WHEN 'Sefton' THEN 180
                    WHEN 'St. Helens' THEN 181
                    WHEN 'Stockport' THEN 182
                    WHEN 'Tameside' THEN 183
                    WHEN 'Trafford' THEN 184
                    WHEN 'Warrington' THEN 185
                    WHEN 'Wigan' THEN 186
                    WHEN 'Wirral' THEN 187
                    WHEN 'Bracknell Forest' THEN 188
                    WHEN 'Brighton and Hove' THEN 189
                    WHEN 'Aylesbury Vale' THEN 190
                    WHEN 'Chiltern' THEN 191
                    WHEN 'South Bucks' THEN 192
                    WHEN 'Wycombe' THEN 193
                    WHEN 'Eastbourne' THEN 194
                    WHEN 'Hastings' THEN 195
                    WHEN 'Lewes' THEN 196
                    WHEN 'Rother' THEN 197
                    WHEN 'Wealden' THEN 198
                    WHEN 'Basingstoke and Deane' THEN 199
                    WHEN 'East Hampshire' THEN 200
                    WHEN 'Eastleigh' THEN 201
                    WHEN 'Fareham' THEN 202
                    WHEN 'Gosport' THEN 203
                    WHEN 'Hart' THEN 204
                    WHEN 'Havant' THEN 205
                    WHEN 'New Forest' THEN 206
                    WHEN 'Rushmoor' THEN 207
                    WHEN 'Test Valley' THEN 208
                    WHEN 'Winchester' THEN 209
                    WHEN 'Isle of Wight' THEN 210
                    WHEN 'Ashford' THEN 211
                    WHEN 'Canterbury' THEN 212
                    WHEN 'Dartford' THEN 213
                    WHEN 'Dover' THEN 214
                    WHEN 'Gravesham' THEN 215
                    WHEN 'Maidstone' THEN 216
                    WHEN 'Sevenoaks' THEN 217
                    WHEN 'Shepway' THEN 218
                    WHEN 'Swale' THEN 219
                    WHEN 'Thanet' THEN 220
                    WHEN 'Tonbridge and Malling' THEN 221
                    WHEN 'Tunbridge Wells' THEN 222
                    WHEN 'Medway' THEN 223
                    WHEN 'Milton Keynes' THEN 224
                    WHEN 'Cherwell' THEN 225
                    WHEN 'Oxford' THEN 226
                    WHEN 'South Oxfordshire' THEN 227
                    WHEN 'Vale of White Horse' THEN 228
                    WHEN 'West Oxfordshire' THEN 229
                    WHEN 'Portsmouth' THEN 230
                    WHEN 'Reading' THEN 231
                    WHEN 'Slough' THEN 232
                    WHEN 'Southampton' THEN 233
                    WHEN 'Elmbridge' THEN 234
                    WHEN 'Epsom and Ewell' THEN 235
                    WHEN 'Guildford' THEN 236
                    WHEN 'Mole Valley' THEN 237
                    WHEN 'Reigate and Banstead' THEN 238
                    WHEN 'Runnymede' THEN 239
                    WHEN 'Spelthorne' THEN 240
                    WHEN 'Surrey Heath' THEN 241
                    WHEN 'Tandridge' THEN 242
                    WHEN 'Waverley' THEN 243
                    WHEN 'Woking' THEN 244
                    WHEN 'West Berkshire' THEN 245
                    WHEN 'Adur' THEN 246
                    WHEN 'Arun' THEN 247
                    WHEN 'Chichester' THEN 248
                    WHEN 'Crawley' THEN 249
                    WHEN 'Horsham' THEN 250
                    WHEN 'Mid Sussex' THEN 251
                    WHEN 'Worthing' THEN 252
                    WHEN 'Windsor and Maidenhead' THEN 253
                    WHEN 'Wokingham' THEN 254
                    WHEN 'Bath and North East Somerset' THEN 255
                    WHEN 'Bournemouth' THEN 256
                    WHEN 'City of Bristol' THEN 257
                    WHEN 'Caradon' THEN 258
                    WHEN 'Carrick' THEN 259
                    WHEN 'Kerrier' THEN 260
                    WHEN 'North Cornwall' THEN 261
                    WHEN 'Penwith' THEN 262
                    WHEN 'Restormel' THEN 263
                    WHEN 'East Devon' THEN 264
                    WHEN 'Exeter' THEN 265
                    WHEN 'Mid Devon' THEN 266
                    WHEN 'North Devon' THEN 267
                    WHEN 'South Hams' THEN 268
                    WHEN 'Teignbridge' THEN 269
                    WHEN 'Torridge' THEN 270
                    WHEN 'West Devon' THEN 271
                    WHEN 'Christchurch' THEN 272
                    WHEN 'East Dorset' THEN 273
                    WHEN 'North Dorset' THEN 274
                    WHEN 'Purbeck' THEN 275
                    WHEN 'West Dorset' THEN 276
                    WHEN 'Weymouth and Portland' THEN 277
                    WHEN 'Cheltenham' THEN 278
                    WHEN 'Cotswold' THEN 279
                    WHEN 'Forest of Dean' THEN 280
                    WHEN 'Gloucester' THEN 281
                    WHEN 'Stroud' THEN 282
                    WHEN 'Tewkesbury' THEN 283
                    WHEN 'Isles of Scilly' THEN 284
                    WHEN 'North Somerset' THEN 285
                    WHEN 'Plymouth' THEN 286
                    WHEN 'Poole' THEN 287
                    WHEN 'Mendip' THEN 288
                    WHEN 'Sedgemoor' THEN 289
                    WHEN 'South Somerset' THEN 290
                    WHEN 'Taunton Deane' THEN 291
                    WHEN 'West Somerset' THEN 292
                    WHEN 'South Gloucestershire' THEN 293
                    WHEN 'Swindon' THEN 294
                    WHEN 'Torbay' THEN 295
                    WHEN 'Kennet' THEN 296
                    WHEN 'North Wiltshire' THEN 297
                    WHEN 'Salisbury' THEN 298
                    WHEN 'West Wiltshire' THEN 299
                    WHEN 'Birmingham' THEN 300
                    WHEN 'Coventry' THEN 301
                    WHEN 'Dudley' THEN 302
                    WHEN 'Herefordshire' THEN 303
                    WHEN 'Sandwell' THEN 304
                    WHEN 'Bridgnorth' THEN 305
                    WHEN 'North Shropshire' THEN 306
                    WHEN 'Oswestry' THEN 307
                    WHEN 'Shrewsbury and Atcham' THEN 308
                    WHEN 'South Shropshire' THEN 309
                    WHEN 'Solihull' THEN 310
                    WHEN 'Cannock Chase' THEN 311
                    WHEN 'East Staffordshire' THEN 312
                    WHEN 'Lichfield' THEN 313
                    WHEN 'Newcastle-under-Lyme' THEN 314
                    WHEN 'South Staffordshire' THEN 315
                    WHEN 'Stafford' THEN 316
                    WHEN 'Staffordshire Moorlands' THEN 317
                    WHEN 'Tamworth' THEN 318
                    WHEN 'Stoke-on-Trent' THEN 319
                    WHEN 'Telford and Wrekin' THEN 320
                    WHEN 'Walsall' THEN 321
                    WHEN 'North Warwickshire' THEN 322
                    WHEN 'Nuneaton and Bedworth' THEN 323
                    WHEN 'Rugby' THEN 324
                    WHEN 'Stratford-on-Avon' THEN 325
                    WHEN 'Warwick' THEN 326
                    WHEN 'Wolverhampton' THEN 327
                    WHEN 'Bromsgrove' THEN 328
                    WHEN 'Malvern Hills' THEN 329
                    WHEN 'Redditch' THEN 330
                    WHEN 'Worcester' THEN 331
                    WHEN 'Wychavon' THEN 332
                    WHEN 'Wyre Forest' THEN 333
                    WHEN 'Barnsley' THEN 334
                    WHEN 'Bradford' THEN 335
                    WHEN 'Calderdale' THEN 336
                    WHEN 'Doncaster' THEN 337
                    WHEN 'East Riding of Yorkshire' THEN 338
                    WHEN 'Kingston upon Hull' THEN 339
                    WHEN 'Kirklees' THEN 340
                    WHEN 'Leeds' THEN 341
                    WHEN 'North East Lincolnshire' THEN 342
                    WHEN 'North Lincolnshire' THEN 343
                    WHEN 'Craven' THEN 344
                    WHEN 'Hambleton' THEN 345
                    WHEN 'Harrogate' THEN 346
                    WHEN 'Richmondshire' THEN 347
                    WHEN 'Ryedale' THEN 348
                    WHEN 'Scarborough' THEN 349
                    WHEN 'Selby' THEN 350
                    WHEN 'Rotherham' THEN 351
                    WHEN 'Sheffield' THEN 352
                    WHEN 'Wakefield' THEN 353
                    WHEN 'York' THEN 354
                    WHEN 'Bedford' THEN 400
                    WHEN 'Central Bedfordshire' THEN 401
                    WHEN 'Cheshire East' THEN 402
                    WHEN 'Cheshire West and Chester' THEN 403
                    WHEN 'Cornwall' THEN 404
                    WHEN 'Isles of Scilly' THEN 405
                    WHEN 'County Durham' THEN 406
                    WHEN 'Northumberland' THEN 407
                    WHEN 'Shropshire' THEN 408
                    WHEN 'Wiltshire' THEN 409
                 END
          FROM   "Cssr"
          WHERE  "NmdsIDLetter" = SUBSTRING(e."NmdsID",1,1)
          AND    "LocalCustodianCode" IN (SELECT local_custodian_code FROM cqcref.pcodedata WHERE postcode = e."PostCode")
          LIMIT 1
       ),-1) lauthid, -- 021
       'na' parliamentaryconstituency, -- 022
       (
          SELECT CASE name
                    WHEN 'Care home services with nursing' THEN 1
                    WHEN 'Care home services without nursing' THEN 2
                    WHEN 'Other adult residential care services' THEN 5
                    WHEN 'Day care and day services' THEN 6
                    WHEN 'Other adult day care services' THEN 7
                    WHEN 'Domiciliary care services' THEN 8
                    WHEN 'Domestic services and home help' THEN 10
                    WHEN 'Other adult domiciliary care service' THEN 12
                    WHEN 'Carers support' THEN 13
                    WHEN 'Short breaks / respite care' THEN 14
                    WHEN 'Community support and outreach' THEN 15
                    WHEN 'Social work and care management' THEN 16
                    WHEN 'Shared lives' THEN 17
                    WHEN 'Disability adaptations / assistive technology services' THEN 18
                    WHEN 'Occupational / employment-related services' THEN 19
                    WHEN 'Information and advice services' THEN 20
                    WHEN 'Other adult community care service' THEN 21
                    WHEN 'Any other services' THEN 52
                    WHEN 'Sheltered housing' THEN 53
                    WHEN 'Extra care housing services' THEN 54
                    WHEN 'Supported living services' THEN 55
                    WHEN 'Specialist college services' THEN 60
                    WHEN 'Community based services for people with a learning disability' THEN 61
                    WHEN 'Community based services for people with mental health needs' THEN 62
                    WHEN 'Community based services for people who misuse substances' THEN 63
                    WHEN 'Community healthcare services' THEN 64
                    WHEN 'Hospice services' THEN 66
                    WHEN 'Long term conditions services' THEN 67
                    WHEN 'Hospital services for people with mental health needs, learning disabilities and/or problems with substance misuse' THEN 68
                    WHEN 'Rehabilitation services' THEN 69
                    WHEN 'Residential substance misuse treatment/ rehabilitation services' THEN 70
                    WHEN 'Other healthcare service' THEN 71
                    WHEN 'Head office services' THEN 72
                    WHEN 'Nurses agency' THEN 74
                 END
          FROM   services
          WHERE  id = e."MainServiceFKValue"
       ) mainstid, -- 023
       CASE w."ContractValue" WHEN 'Permanent' THEN 190 WHEN 'Temporary' THEN 191 WHEN 'Pool/Bank' THEN 192 WHEN 'Agency' THEN 193 WHEN 'Other' THEN 196 ELSE -1 END emplstat, -- 024
       TO_CHAR(w."ContractChangedAt",'DD/MM/YYYY') emplstat_changedate, -- 025
       TO_CHAR(w."ContractSavedAt",'DD/MM/YYYY') emplstat_savedate, -- 026
       COALESCE((
          SELECT CASE "JobName"
                    WHEN 'Senior Management' THEN 1
                    WHEN 'Middle Management' THEN 2
                    WHEN 'First Line Manager' THEN 3
                    WHEN 'Registered Manager' THEN 4
                    WHEN 'Supervisor' THEN 5
                    WHEN 'Social Worker' THEN 6
                    WHEN 'Senior Care Worker' THEN 7
                    WHEN 'Care Worker' THEN 8
                    WHEN 'Community, Support and Outreach Work' THEN 9
                    WHEN 'Employment Support' THEN 10
                    WHEN 'Advice, Guidance and Advocacy' THEN 11
                    WHEN 'Occupational Therapist' THEN 15
                    WHEN 'Registered Nurse' THEN 16
                    WHEN 'Allied Health Professional (not Occupational Therapist)' THEN 17
                    WHEN 'Technician' THEN 22
                    WHEN 'Other job roles directly involved in providing care' THEN 23
                    WHEN 'Managers and staff care-related but not care-providing' THEN 24
                    WHEN 'Administrative / office staff not care-providing' THEN 25
                    WHEN 'Ancillary staff not care-providing' THEN 26
                    WHEN 'Other job roles not directly involved in providing care' THEN 27
                    WHEN 'Activities worker or co-ordinator' THEN 34
                    WHEN 'Safeguarding & Reviewing Officer' THEN 35
                    WHEN 'Occupational Therapist Assistant' THEN 36
                    WHEN 'Nursing Associate' THEN 37
                    WHEN 'Nursing Assistant' THEN 38
                    WHEN 'Assessment Officer' THEN 39
                    WHEN 'Care Coordinator' THEN 40
                    WHEN 'Care Navigator' THEN 41
                    WHEN 'Any childrens / young people''s job role' THEN 42
                 END
          FROM   "Job"
          WHERE  "JobID" = w."MainJobFKValue"
       ),-1) mainjrid, -- 027
       TO_CHAR("MainJobFKChangedAt",'DD/MM/YYYY') mainjrid_changedate, -- 028
       TO_CHAR("MainJobFKSavedAt",'DD/MM/YYYY') mainjrid_savedate, -- 029
       TO_CHAR("MainJobStartDateValue",'DD/MM/YYYY') strtdate, -- 030
       TO_CHAR("MainJobStartDateChangedAt",'DD/MM/YYYY') strtdate_changedate, -- 031
       TO_CHAR("MainJobStartDateSavedAt",'DD/MM/YYYY') strtdate_savedate, -- 032
       EXTRACT(YEAR FROM AGE("DateOfBirthValue")) age, -- 033
       TO_CHAR("DateOfBirthChangedAt",'DD/MM/YYYY') age_changedate, -- 034
       TO_CHAR("DateOfBirthSavedAt",'DD/MM/YYYY') age_savedate, -- 035
       CASE "GenderValue" WHEN 'Male' THEN 1 WHEN 'Female' THEN 2 WHEN 'Don''t know' THEN 3 WHEN 'Other' THEN 4 ELSE -1 END gender, -- 036
       TO_CHAR("GenderChangedAt",'DD/MM/YYYY') gender_changedate, -- 037
       TO_CHAR("GenderSavedAt",'DD/MM/YYYY') gender_savedate, -- 038
       CASE "DisabilityValue" WHEN 'No' THEN 0 WHEN 'Yes' THEN 1 WHEN 'Undisclosed' THEN 2 WHEN 'Don''t know' THEN -2 ELSE -1 END disabled, -- 039
       TO_CHAR("DisabilityChangedAt",'DD/MM/YYYY') disabled_changedate, -- 040
       TO_CHAR("DisabilitySavedAt",'DD/MM/YYYY') disabled_savedate, -- 041
       COALESCE((
          SELECT CASE "Ethnicity"
                    WHEN 'English / Welsh / Scottish / Northern Irish / British' THEN 31
                    WHEN 'Irish' THEN 32
                    WHEN 'Gypsy or Irish Traveller' THEN 33
                    WHEN 'Any other White background' THEN 34
                    WHEN 'White and Black Caribbean' THEN 35
                    WHEN 'White and Black African' THEN 36
                    WHEN 'White and Asian' THEN 37
                    WHEN 'Any other Mixed/ multiple ethnic background' THEN 38
                    WHEN 'Indian' THEN 39
                    WHEN 'Pakistani' THEN 40
                    WHEN 'Bangladeshi' THEN 41
                    WHEN 'Chinese' THEN 42
                    WHEN 'Any other Asian background' THEN 43
                    WHEN 'African' THEN 44
                    WHEN 'Caribbean' THEN 45
                    WHEN 'Any other Black / African / Caribbean background' THEN 46
                    WHEN 'Arab' THEN 47
                    WHEN 'Any other ethnic group' THEN 98
                    WHEN 'Don''t know' THEN 99
                 END
          FROM   "Ethnicity"
          WHERE  "ID" = w."EthnicityFKValue"
       ),-1) ethnicity, -- 042
       TO_CHAR("EthnicityFKChangedAt",'DD/MM/YYYY') ethnicity_changedate, -- 043
       TO_CHAR("EthnicityFKSavedAt",'DD/MM/YYYY') ethnicity_savedate, -- 044
       CASE "NationalityValue" WHEN 'British' THEN 1 WHEN 'Other' THEN 0 WHEN 'Don''t know' THEN 2 ELSE -1 END isbritish, -- 045
       CASE "NationalityValue"
          WHEN 'British' THEN 826
          ELSE
             COALESCE((
                SELECT CASE "Nationality"
                          WHEN 'Afghan' THEN 4
                          WHEN 'Albanian' THEN 8
                          WHEN 'Algerian' THEN 12
                          WHEN 'American' THEN 16
                          WHEN 'Andorran' THEN 20
                          WHEN 'Angolan' THEN 24
                          WHEN 'Citizen of Antigua and Barbuda' THEN 28
                          WHEN 'Azerbaijani' THEN 31
                          WHEN 'Argentine' THEN 32
                          WHEN 'Australian' THEN 36
                          WHEN 'Austrian' THEN 40
                          WHEN 'Bahamian' THEN 44
                          WHEN 'Bahraini' THEN 48
                          WHEN 'Bangladeshi' THEN 50
                          WHEN 'Armenian' THEN 51
                          WHEN 'Barbadian' THEN 52
                          WHEN 'Belgian' THEN 56
                          WHEN 'Bermudian' THEN 60
                          WHEN 'Bhutanese' THEN 64
                          WHEN 'Bolivian' THEN 68
                          WHEN 'Citizen of Bosnia and Herzegovina' THEN 70
                          WHEN 'Botswanan' THEN 72
                          WHEN 'Brazilian' THEN 76
                          WHEN 'Belizean' THEN 84
                          WHEN 'Solomon Islander' THEN 90
                          WHEN 'Bruneian' THEN 96
                          WHEN 'Bulgarian' THEN 100
                          WHEN 'Burmese' THEN 104
                          WHEN 'Burundian' THEN 108
                          WHEN 'Belarusian' THEN 112
                          WHEN 'Cambodian' THEN 116
                          WHEN 'Cameroonian' THEN 120
                          WHEN 'Canadian' THEN 124
                          WHEN 'Cape Verdean' THEN 132
                          WHEN 'Cayman Islander' THEN 136
                          WHEN 'Central African' THEN 140
                          WHEN 'Sri Lankan' THEN 144
                          WHEN 'Chadian' THEN 148
                          WHEN 'Chilean' THEN 152
                          WHEN 'Chinese' THEN 156
                          WHEN 'Taiwanese' THEN 158
                          WHEN 'Colombian' THEN 170
                          WHEN 'Comoran' THEN 174
                          WHEN 'Congolese (Congo)' THEN 178
                          WHEN 'Congolese (DRC)' THEN 180
                          WHEN 'Cook Islander' THEN 184
                          WHEN 'Costa Rican' THEN 188
                          WHEN 'Croatian' THEN 191
                          WHEN 'Cuban' THEN 192
                          WHEN 'Cypriot' THEN 196
                          WHEN 'Czech' THEN 203
                          WHEN 'Beninese' THEN 204
                          WHEN 'Danish' THEN 208
                          WHEN 'Dominican' THEN 212
                          WHEN 'Citizen of the Dominican Republic' THEN 214
                          WHEN 'Ecuadorean' THEN 218
                          WHEN 'Salvadorean' THEN 222
                          WHEN 'Equatorial Guinean' THEN 226
                          WHEN 'Ethiopian' THEN 231
                          WHEN 'Eritrean' THEN 232
                          WHEN 'Estonian' THEN 233
                          WHEN 'Faroese' THEN 234
                          WHEN 'Fijian' THEN 242
                          WHEN 'Finnish' THEN 246
                          WHEN 'French' THEN 250
                          WHEN 'Djiboutian' THEN 262
                          WHEN 'Gabonese' THEN 266
                          WHEN 'Georgian' THEN 268
                          WHEN 'Gambian' THEN 270
                          WHEN 'Palestinian' THEN 275
                          WHEN 'German' THEN 276
                          WHEN 'Ghanaian' THEN 288
                          WHEN 'Gibraltarian' THEN 292
                          WHEN 'Citizen of Kiribati' THEN 296
                          WHEN 'Greek' THEN 300
                          WHEN 'Greenlandic' THEN 304
                          WHEN 'Grenadian' THEN 308
                          WHEN 'Guamanian' THEN 316
                          WHEN 'Guatemalan' THEN 320
                          WHEN 'Guinean' THEN 324
                          WHEN 'Guyanese' THEN 328
                          WHEN 'Haitian' THEN 332
                          WHEN 'Honduran' THEN 340
                          WHEN 'Hong Konger' THEN 344
                          WHEN 'Hungarian' THEN 348
                          WHEN 'Icelandic' THEN 352
                          WHEN 'Indian' THEN 356
                          WHEN 'Indonesian' THEN 360
                          WHEN 'Iranian' THEN 364
                          WHEN 'Iraqi' THEN 368
                          WHEN 'Irish' THEN 372
                          WHEN 'Israeli' THEN 376
                          WHEN 'Italian' THEN 380
                          WHEN 'Ivorian' THEN 384
                          WHEN 'Jamaican' THEN 388
                          WHEN 'Japanese' THEN 392
                          WHEN 'Kazakh' THEN 398
                          WHEN 'Jordanian' THEN 400
                          WHEN 'Kenyan' THEN 404
                          WHEN 'North Korean' THEN 408
                          WHEN 'South Korean' THEN 410
                          WHEN 'Kuwaiti' THEN 414
                          WHEN 'Kyrgyz' THEN 417
                          WHEN 'Lebanese' THEN 422
                          WHEN 'Mosotho' THEN 426
                          WHEN 'Latvian' THEN 428
                          WHEN 'Liberian' THEN 430
                          WHEN 'Libyan' THEN 434
                          WHEN 'Liechtenstein citizen' THEN 438
                          WHEN 'Lithuanian' THEN 440
                          WHEN 'Luxembourger' THEN 442
                          WHEN 'Macanese' THEN 446
                          WHEN 'Malagasy' THEN 450
                          WHEN 'Malawian' THEN 454
                          WHEN 'Malaysian' THEN 458
                          WHEN 'Maldivian' THEN 462
                          WHEN 'Malian' THEN 466
                          WHEN 'Maltese' THEN 470
                          WHEN 'Martiniquais' THEN 474
                          WHEN 'Mauritanian' THEN 478
                          WHEN 'Mauritian' THEN 480
                          WHEN 'Lao' THEN 481
                          WHEN 'Mexican' THEN 484
                          WHEN 'Monegasque' THEN 492
                          WHEN 'Mongolian' THEN 496
                          WHEN 'Moldovan' THEN 498
                          WHEN 'Montenegrin' THEN 499
                          WHEN 'Montserratian' THEN 500
                          WHEN 'Moroccan' THEN 504
                          WHEN 'Mozambican' THEN 508
                          WHEN 'Omani' THEN 512
                          WHEN 'Namibian' THEN 516
                          WHEN 'Nauruan' THEN 520
                          WHEN 'Nepalese' THEN 524
                          WHEN 'Dutch' THEN 528
                          WHEN 'Citizen of Vanuatu' THEN 548
                          WHEN 'New Zealander' THEN 554
                          WHEN 'Nicaraguan' THEN 558
                          WHEN 'Nigerien' THEN 562
                          WHEN 'Nigerian' THEN 566
                          WHEN 'Niuean' THEN 570
                          WHEN 'Norwegian' THEN 578
                          WHEN 'Micronesian' THEN 583
                          WHEN 'Marshallese' THEN 584
                          WHEN 'Palauan' THEN 585
                          WHEN 'Pakistani' THEN 586
                          WHEN 'Panamanian' THEN 591
                          WHEN 'Papua New Guinean' THEN 598
                          WHEN 'Paraguayan' THEN 600
                          WHEN 'Peruvian' THEN 604
                          WHEN 'Filipino' THEN 608
                          WHEN 'Polish' THEN 616
                          WHEN 'Portuguese' THEN 620
                          WHEN 'Guinea-Bissau' THEN 624
                          WHEN 'East Timorese' THEN 626
                          WHEN 'Puerto Rican' THEN 630
                          WHEN 'Qatari' THEN 634
                          WHEN 'Romanian' THEN 642
                          WHEN 'Russian' THEN 643
                          WHEN 'Rwandan' THEN 646
                          WHEN 'St Helenian' THEN 654
                          WHEN 'Kittitian' THEN 659
                          WHEN 'Anguillan' THEN 660
                          WHEN 'St Lucian' THEN 662
                          WHEN 'Vincentian' THEN 670
                          WHEN 'Sammarinese' THEN 674
                          WHEN 'Sao Tomean' THEN 678
                          WHEN 'Saudi Arabian' THEN 682
                          WHEN 'Senegalese' THEN 686
                          WHEN 'Serbian' THEN 688
                          WHEN 'Citizen of Seychelles' THEN 690
                          WHEN 'Sierra Leonean' THEN 694
                          WHEN 'Singaporean' THEN 702
                          WHEN 'Slovak' THEN 703
                          WHEN 'Vietnamese' THEN 704
                          WHEN 'Slovenian' THEN 705
                          WHEN 'Somali' THEN 706
                          WHEN 'South African' THEN 710
                          WHEN 'Zimbabwean' THEN 716
                          WHEN 'Spanish' THEN 724
                          WHEN 'South Sudanese' THEN 728
                          WHEN 'Sudanese' THEN 736
                          WHEN 'Surinamese' THEN 740
                          WHEN 'Swazi' THEN 748
                          WHEN 'Swedish' THEN 752
                          WHEN 'Swiss' THEN 756
                          WHEN 'Syrian' THEN 760
                          WHEN 'Tajik' THEN 762
                          WHEN 'Thai' THEN 764
                          WHEN 'Togolese' THEN 768
                          WHEN 'Tongan' THEN 776
                          WHEN 'Trinidadian' THEN 780
                          WHEN 'Emirati' THEN 784
                          WHEN 'Tunisian' THEN 788
                          WHEN 'Turkish' THEN 792
                          WHEN 'Turkmen' THEN 795
                          WHEN 'Turks and Caicos Islander' THEN 796
                          WHEN 'Tuvaluan' THEN 798
                          WHEN 'Ugandan' THEN 800
                          WHEN 'Ukrainian' THEN 804
                          WHEN 'Macedonian' THEN 807
                          WHEN 'Egyptian' THEN 818
                          WHEN 'British' THEN 826
                          WHEN 'Tanzanian' THEN 834
                          WHEN 'Burkinan' THEN 854
                          WHEN 'Uruguayan' THEN 858
                          WHEN 'Uzbek' THEN 860
                          WHEN 'Venezuelan' THEN 862
                          WHEN 'Wallisian' THEN 876
                          WHEN 'Samoan' THEN 882
                          WHEN 'Yemeni' THEN 887
                          WHEN 'Zambian' THEN 894
                          WHEN 'Kosovon' THEN 995
                          WHEN 'Workers nationality unknown' THEN 998
                       END
                FROM   "Nationality"
                WHERE  "ID" = w."NationalityOtherFK"
             ),-1)
       END nationality, -- 046
       TO_CHAR("NationalityChangedAt",'DD/MM/YYYY') isbritish_changedate, -- 047
       TO_CHAR("NationalitySavedAt",'DD/MM/YYYY') isbritish_savedate, -- 048
       CASE "BritishCitizenshipValue" WHEN 'No' THEN 0 WHEN 'Yes' THEN 1 WHEN 'Don''t know' THEN 2 ELSE -1 END britishcitizen, -- 049
       TO_CHAR("BritishCitizenshipChangedAt",'DD/MM/YYYY') britishcitizen_changedate, -- 050
       TO_CHAR("BritishCitizenshipSavedAt",'DD/MM/YYYY') britishcitizen_savedate, -- 051
       CASE "CountryOfBirthValue" WHEN 'Other' THEN 0 WHEN 'United Kingdom' THEN 1 WHEN 'Don''t know' THEN 2 ELSE -1 END borninuk, -- 052
       CASE "CountryOfBirthValue"
          WHEN 'United Kingdom' THEN 826
          ELSE
            COALESCE((
               SELECT CASE "Country"
                         WHEN 'Afghanistan' THEN 4
                         WHEN 'Albania' THEN 8
                         WHEN 'Antarctica' THEN 10
                         WHEN 'Algeria' THEN 12
                         WHEN 'American Samoa' THEN 16
                         WHEN 'Andorra' THEN 20
                         WHEN 'Angola' THEN 24
                         WHEN 'Antigua and Barbuda' THEN 28
                         WHEN 'Azerbaijan' THEN 31
                         WHEN 'Argentina' THEN 32
                         WHEN 'Australia' THEN 36
                         WHEN 'Austria' THEN 40
                         WHEN 'Bahamas' THEN 44
                         WHEN 'Bahrain' THEN 48
                         WHEN 'Bangladesh' THEN 50
                         WHEN 'Armenia' THEN 51
                         WHEN 'Barbados' THEN 52
                         WHEN 'Belgium' THEN 56
                         WHEN 'Bermuda' THEN 60
                         WHEN 'Bhutan' THEN 64
                         WHEN 'Bolivia' THEN 68
                         WHEN 'Bosnia and Herzegovina' THEN 70
                         WHEN 'Botswana' THEN 72
                         WHEN 'Bouvet Island' THEN 74
                         WHEN 'Brazil' THEN 76
                         WHEN 'Belize' THEN 84
                         WHEN 'British Indian Ocean Territory' THEN 86
                         WHEN 'Solomon Islands' THEN 90
                         WHEN 'Virgin Islands British' THEN 92
                         WHEN 'Brunei Darussalam' THEN 96
                         WHEN 'Bulgaria' THEN 100
                         WHEN 'Myanmar' THEN 104
                         WHEN 'Burundi' THEN 108
                         WHEN 'Belarus' THEN 112
                         WHEN 'Cambodia' THEN 116
                         WHEN 'Cameroon' THEN 120
                         WHEN 'Canada' THEN 124
                         WHEN 'Cape Verde' THEN 132
                         WHEN 'Cayman Islands' THEN 136
                         WHEN 'Central African Republic' THEN 140
                         WHEN 'Sri Lanka' THEN 144
                         WHEN 'Chad' THEN 148
                         WHEN 'Chile' THEN 152
                         WHEN 'China' THEN 156
                         WHEN 'Taiwan Province of China' THEN 158
                         WHEN 'Christmas Island' THEN 162
                         WHEN 'Cocos (Keeling) Islands' THEN 166
                         WHEN 'Colombia' THEN 170
                         WHEN 'Comoros' THEN 174
                         WHEN 'Mayotte' THEN 175
                         WHEN 'Congo' THEN 178
                         WHEN 'Congo Democratic Republic of the' THEN 180
                         WHEN 'Cook Islands' THEN 184
                         WHEN 'Costa Rica' THEN 188
                         WHEN 'Croatia' THEN 191
                         WHEN 'Cuba' THEN 192
                         WHEN 'Cyprus' THEN 196
                         WHEN 'Czech Republic' THEN 203
                         WHEN 'Benin' THEN 204
                         WHEN 'Denmark' THEN 208
                         WHEN 'Dominica' THEN 212
                         WHEN 'Dominican Republic' THEN 214
                         WHEN 'Ecuador' THEN 218
                         WHEN 'El Salvador' THEN 222
                         WHEN 'Equatorial Guinea' THEN 226
                         WHEN 'Ethiopia' THEN 231
                         WHEN 'Eritrea' THEN 232
                         WHEN 'Estonia' THEN 233
                         WHEN 'Faroe Islands' THEN 234
                         WHEN 'Falkland Islands (Malvinas)' THEN 238
                         WHEN 'South Georgia and the South Sandwich Islands' THEN 239
                         WHEN 'Fiji' THEN 242
                         WHEN 'Finland' THEN 246
                         WHEN 'Aland Islands' THEN 248
                         WHEN 'France' THEN 250
                         WHEN 'French Guiana' THEN 254
                         WHEN 'French Polynesia' THEN 258
                         WHEN 'French Southern Territories' THEN 260
                         WHEN 'Djibouti' THEN 262
                         WHEN 'Gabon' THEN 266
                         WHEN 'Georgia' THEN 268
                         WHEN 'Gambia' THEN 270
                         WHEN 'Palestine, State of' THEN 275
                         WHEN 'Germany' THEN 276
                         WHEN 'Ghana' THEN 288
                         WHEN 'Gibraltar' THEN 292
                         WHEN 'Kiribati' THEN 296
                         WHEN 'Greece' THEN 300
                         WHEN 'Greenland' THEN 304
                         WHEN 'Grenada' THEN 308
                         WHEN 'Guadeloupe' THEN 312
                         WHEN 'Guam' THEN 316
                         WHEN 'Guatemala' THEN 320
                         WHEN 'Guinea' THEN 324
                         WHEN 'Guyana' THEN 328
                         WHEN 'Haiti' THEN 332
                         WHEN 'Heard Island and McDonald Islands' THEN 334
                         WHEN 'Holy See (Vatican City State)' THEN 336
                         WHEN 'Honduras' THEN 340
                         WHEN 'Hong Kong' THEN 344
                         WHEN 'Hungary' THEN 348
                         WHEN 'Iceland' THEN 352
                         WHEN 'India' THEN 356
                         WHEN 'Indonesia' THEN 360
                         WHEN 'Iran Islamic Republic of' THEN 364
                         WHEN 'Iraq' THEN 368
                         WHEN 'Ireland' THEN 372
                         WHEN 'Israel' THEN 376
                         WHEN 'Italy' THEN 380
                         WHEN 'Cote d''Ivoire' THEN 384
                         WHEN 'Jamaica' THEN 388
                         WHEN 'Japan' THEN 392
                         WHEN 'Kazakhstan' THEN 398
                         WHEN 'Jordan' THEN 400
                         WHEN 'Kenya' THEN 404
                         WHEN 'Korea Democratic People''s Republic of' THEN 408
                         WHEN 'Korea Republic of' THEN 410
                         WHEN 'Kuwait' THEN 414
                         WHEN 'Kyrgyzstan' THEN 417
                         WHEN 'Laos' THEN 418
                         WHEN 'Lebanon' THEN 422
                         WHEN 'Lesotho' THEN 426
                         WHEN 'Latvia' THEN 428
                         WHEN 'Liberia' THEN 430
                         WHEN 'Libya' THEN 434
                         WHEN 'Liechtenstein' THEN 438
                         WHEN 'Lithuania' THEN 440
                         WHEN 'Luxembourg' THEN 442
                         WHEN 'Macao' THEN 446
                         WHEN 'Madagascar' THEN 450
                         WHEN 'Malawi' THEN 454
                         WHEN 'Malaysia' THEN 458
                         WHEN 'Maldives' THEN 462
                         WHEN 'Mali' THEN 466
                         WHEN 'Malta' THEN 470
                         WHEN 'Mauritania' THEN 478
                         WHEN 'Mauritius' THEN 480
                         WHEN 'Mexico' THEN 484
                         WHEN 'Monaco' THEN 492
                         WHEN 'Mongolia' THEN 496
                         WHEN 'Moldova' THEN 498
                         WHEN 'Montenegro' THEN 499
                         WHEN 'Montserrat' THEN 500
                         WHEN 'Morocco' THEN 504
                         WHEN 'Mozambique' THEN 508
                         WHEN 'Oman' THEN 512
                         WHEN 'Namibia' THEN 516
                         WHEN 'Nauru' THEN 520
                         WHEN 'Nepal' THEN 524
                         WHEN 'Netherlands' THEN 528
                         WHEN 'Curacao (Formerly Netherlands Antilles)' THEN 531
                         WHEN 'Aruba' THEN 533
                         WHEN 'Sint Maarten (Dutch part)' THEN 534
                         WHEN 'Bonaire, Sint Eustatius and Saba' THEN 535
                         WHEN 'New Caledonia' THEN 540
                         WHEN 'Vanuatu' THEN 548
                         WHEN 'New Zealand' THEN 554
                         WHEN 'Nicaragua' THEN 558
                         WHEN 'Niger' THEN 562
                         WHEN 'Nigeria' THEN 566
                         WHEN 'Niue' THEN 570
                         WHEN 'Norfolk Island' THEN 574
                         WHEN 'Norway' THEN 578
                         WHEN 'Northern Mariana Islands' THEN 580
                         WHEN 'United States Minor Outlying Islands' THEN 581
                         WHEN 'Micronesia Federated States of' THEN 583
                         WHEN 'Marshall Islands' THEN 584
                         WHEN 'Palau' THEN 585
                         WHEN 'Pakistan' THEN 586
                         WHEN 'Panama' THEN 591
                         WHEN 'Papua New Guinea' THEN 598
                         WHEN 'Paraguay' THEN 600
                         WHEN 'Peru' THEN 604
                         WHEN 'Philippines' THEN 608
                         WHEN 'Pitcairn' THEN 612
                         WHEN 'Poland' THEN 616
                         WHEN 'Portugal' THEN 620
                         WHEN 'Guinea-Bissau' THEN 624
                         WHEN 'Timor-Leste' THEN 626
                         WHEN 'Puerto Rico' THEN 630
                         WHEN 'Qatar' THEN 634
                         WHEN 'Reunion' THEN 638
                         WHEN 'Romania' THEN 642
                         WHEN 'Russian Federation' THEN 643
                         WHEN 'Rwanda' THEN 646
                         WHEN 'Saint Barthelemy' THEN 652
                         WHEN 'St Helena Ascension and Tristan da Cunha' THEN 654
                         WHEN 'Saint Kitts and Nevis' THEN 659
                         WHEN 'Anguilla' THEN 660
                         WHEN 'Saint Lucia' THEN 662
                         WHEN 'Saint Martin (French part)' THEN 663
                         WHEN 'Saint Pierre and Miquelon' THEN 666
                         WHEN 'Saint Vincent and the Grenadines' THEN 670
                         WHEN 'San Marino' THEN 674
                         WHEN 'Sao Tome and Principe' THEN 678
                         WHEN 'Saudi Arabia' THEN 682
                         WHEN 'Senegal' THEN 686
                         WHEN 'Serbia' THEN 688
                         WHEN 'Seychelles' THEN 690
                         WHEN 'Sierra Leone' THEN 694
                         WHEN 'Singapore' THEN 702
                         WHEN 'Slovakia' THEN 703
                         WHEN 'Viet Nam' THEN 704
                         WHEN 'Slovenia' THEN 705
                         WHEN 'Somalia' THEN 706
                         WHEN 'South Africa' THEN 710
                         WHEN 'Zimbabwe' THEN 716
                         WHEN 'Spain' THEN 724
                         WHEN 'South Sudan' THEN 728
                         WHEN 'Western Sahara' THEN 732
                         WHEN 'Sudan' THEN 736
                         WHEN 'Suriname' THEN 740
                         WHEN 'Svalbard and Jan Mayen' THEN 744
                         WHEN 'Swaziland' THEN 748
                         WHEN 'Sweden' THEN 752
                         WHEN 'Switzerland' THEN 756
                         WHEN 'Syrian Arab Republic' THEN 760
                         WHEN 'Tajikistan' THEN 762
                         WHEN 'Thailand' THEN 764
                         WHEN 'Togo' THEN 768
                         WHEN 'Tokelau' THEN 772
                         WHEN 'Tonga' THEN 776
                         WHEN 'Trinidad and Tobago' THEN 780
                         WHEN 'United Arab Emirates' THEN 784
                         WHEN 'Tunisia' THEN 788
                         WHEN 'Turkey' THEN 792
                         WHEN 'Turkmenistan' THEN 795
                         WHEN 'Turks and Caicos Islands' THEN 796
                         WHEN 'Tuvalu' THEN 798
                         WHEN 'Uganda' THEN 800
                         WHEN 'Ukraine' THEN 804
                         WHEN 'Macedonia the former Yugoslav Republic of' THEN 807
                         WHEN 'Egypt' THEN 818
                         WHEN 'United Kingdom' THEN 826
                         WHEN 'Guernsey' THEN 831
                         WHEN 'Jersey' THEN 832
                         WHEN 'Tanzania United Republic of' THEN 834
                         WHEN 'United States' THEN 840
                         WHEN 'Virgin Islands U.S.' THEN 850
                         WHEN 'Burkina Faso' THEN 854
                         WHEN 'Uruguay' THEN 858
                         WHEN 'Uzbekistan' THEN 860
                         WHEN 'Venezuela' THEN 862
                         WHEN 'Wallis and Futuna' THEN 876
                         WHEN 'Samoa' THEN 882
                         WHEN 'Yemen' THEN 887
                         WHEN 'Zambia' THEN 894
                         WHEN 'Kosovo' THEN 995
                         WHEN 'Country unknown' THEN 999
                      END
               FROM   "Country"
               WHERE  "ID" = w."CountryOfBirthOtherFK"
            ),-1)
       END countryofbirth, -- 053
       TO_CHAR("CountryOfBirthChangedAt",'DD/MM/YYYY') borninuk_changedate, -- 054
       TO_CHAR("CountryOfBirthSavedAt",'DD/MM/YYYY') borninuk_savedate, -- 055
       CASE "YearArrivedValue" WHEN 'Yes' THEN "YearArrivedYear" WHEN 'No' THEN -1 ELSE -2 END yearofentry, -- 056
       TO_CHAR("YearArrivedChangedAt",'DD/MM/YYYY') yearofentry_changedate, -- 057
       TO_CHAR("YearArrivedSavedAt",'DD/MM/YYYY') yearofentry_savedate, -- 058
       COALESCE((SELECT "RegionID" FROM "Cssr" WHERE "LocalCustodianCode" IN (SELECT local_custodian_code FROM cqcref.pcodedata WHERE postcode = w."PostcodeValue") LIMIT 1),-1) homeregionid, -- 059
       COALESCE((SELECT "CssrID" FROM "Cssr" WHERE "LocalCustodianCode" IN (SELECT local_custodian_code FROM cqcref.pcodedata WHERE postcode = w."PostcodeValue") LIMIT 1),-1) homecssrid, -- 060
       COALESCE((
          SELECT CASE "LocalAuthority"
                    WHEN 'Mid Bedfordshire' THEN 1
                    WHEN 'Bedford' THEN 2
                    WHEN 'South Bedfordshire' THEN 3
                    WHEN 'Cambridge' THEN 4
                    WHEN 'East Cambridgeshire' THEN 5
                    WHEN 'Fenland' THEN 6
                    WHEN 'Huntingdonshire' THEN 7
                    WHEN 'South Cambridgeshire' THEN 8
                    WHEN 'Basildon' THEN 9
                    WHEN 'Braintree' THEN 10
                    WHEN 'Brentwood' THEN 11
                    WHEN 'Castle Point' THEN 12
                    WHEN 'Chelmsford' THEN 13
                    WHEN 'Colchester' THEN 14
                    WHEN 'Epping Forest' THEN 15
                    WHEN 'Harlow' THEN 16
                    WHEN 'Maldon' THEN 17
                    WHEN 'Rochford' THEN 18
                    WHEN 'Tendring' THEN 19
                    WHEN 'Uttlesford' THEN 20
                    WHEN 'Broxbourne' THEN 21
                    WHEN 'Dacorum' THEN 22
                    WHEN 'East Hertfordshire' THEN 23
                    WHEN 'Hertsmere' THEN 24
                    WHEN 'North Hertfordshire' THEN 25
                    WHEN 'St Albans' THEN 26
                    WHEN 'Stevenage' THEN 27
                    WHEN 'Three Rivers' THEN 28
                    WHEN 'Watford' THEN 29
                    WHEN 'Welwyn Hatfield' THEN 30
                    WHEN 'Luton' THEN 31
                    WHEN 'Breckland' THEN 32
                    WHEN 'Broadland' THEN 33
                    WHEN 'Great Yarmouth' THEN 34
                    WHEN 'King`s Lynn and West Norfolk' THEN 35
                    WHEN 'North Norfolk' THEN 36
                    WHEN 'Norwich' THEN 37
                    WHEN 'South Norfolk' THEN 38
                    WHEN 'Peterborough' THEN 39
                    WHEN 'Southend-on-Sea' THEN 40
                    WHEN 'Babergh' THEN 41
                    WHEN 'Forest Heath' THEN 42
                    WHEN 'Ipswich' THEN 43
                    WHEN 'Mid Suffolk' THEN 44
                    WHEN 'St. Edmundsbury' THEN 45
                    WHEN 'Suffolk Coastal' THEN 46
                    WHEN 'Waveney' THEN 47
                    WHEN 'Thurrock' THEN 48
                    WHEN 'Derby' THEN 49
                    WHEN 'Amber Valley' THEN 50
                    WHEN 'Bolsover' THEN 51
                    WHEN 'Chesterfield' THEN 52
                    WHEN 'Derbyshire Dales' THEN 53
                    WHEN 'Erewash' THEN 54
                    WHEN 'High Peak' THEN 55
                    WHEN 'North East Derbyshire' THEN 56
                    WHEN 'South Derbyshire' THEN 57
                    WHEN 'Leicester' THEN 58
                    WHEN 'Blaby' THEN 59
                    WHEN 'Charnwood' THEN 60
                    WHEN 'Harborough' THEN 61
                    WHEN 'Hinckley and Bosworth' THEN 62
                    WHEN 'Melton' THEN 63
                    WHEN 'North West Leicestershire' THEN 64
                    WHEN 'Oadby and Wigston' THEN 65
                    WHEN 'Boston' THEN 66
                    WHEN 'East Lindsey' THEN 67
                    WHEN 'Lincoln' THEN 68
                    WHEN 'North Kesteven' THEN 69
                    WHEN 'South Holland' THEN 70
                    WHEN 'South Kesteven' THEN 71
                    WHEN 'West Lindsey' THEN 72
                    WHEN 'Corby' THEN 73
                    WHEN 'Daventry' THEN 74
                    WHEN 'East Northamptonshire' THEN 75
                    WHEN 'Kettering' THEN 76
                    WHEN 'Northampton' THEN 77
                    WHEN 'South Northamptonshire' THEN 78
                    WHEN 'Wellingborough' THEN 79
                    WHEN 'Nottingham' THEN 80
                    WHEN 'Ashfield' THEN 81
                    WHEN 'Bassetlaw' THEN 82
                    WHEN 'Broxtowe' THEN 83
                    WHEN 'Gedling' THEN 84
                    WHEN 'Mansfield' THEN 85
                    WHEN 'Newark and Sherwood' THEN 86
                    WHEN 'Rushcliffe' THEN 87
                    WHEN 'Rutland' THEN 88
                    WHEN 'Barking and Dagenham' THEN 89
                    WHEN 'Barnet' THEN 90
                    WHEN 'Bexley' THEN 91
                    WHEN 'Brent' THEN 92
                    WHEN 'Bromley' THEN 93
                    WHEN 'Camden' THEN 94
                    WHEN 'City of London' THEN 95
                    WHEN 'Croydon' THEN 96
                    WHEN 'Ealing' THEN 97
                    WHEN 'Enfield' THEN 98
                    WHEN 'Greenwich' THEN 99
                    WHEN 'Hackney' THEN 100
                    WHEN 'Hammersmith and Fulham' THEN 101
                    WHEN 'Haringey' THEN 102
                    WHEN 'Harrow' THEN 103
                    WHEN 'Havering' THEN 104
                    WHEN 'Hillingdon' THEN 105
                    WHEN 'Hounslow' THEN 106
                    WHEN 'Islington' THEN 107
                    WHEN 'Kensington and Chelsea' THEN 108
                    WHEN 'Kingston upon Thames' THEN 109
                    WHEN 'Lambeth' THEN 110
                    WHEN 'Lewisham' THEN 111
                    WHEN 'Merton' THEN 112
                    WHEN 'Newham' THEN 113
                    WHEN 'Redbridge' THEN 114
                    WHEN 'Richmond upon Thames' THEN 115
                    WHEN 'Southwark' THEN 116
                    WHEN 'Sutton' THEN 117
                    WHEN 'Tower Hamlets' THEN 118
                    WHEN 'Waltham Forest' THEN 119
                    WHEN 'Wandsworth' THEN 120
                    WHEN 'Westminster' THEN 121
                    WHEN 'Darlington' THEN 122
                    WHEN 'Chester-le-Street' THEN 123
                    WHEN 'Derwentside' THEN 124
                    WHEN 'Durham' THEN 125
                    WHEN 'Easington' THEN 126
                    WHEN 'Sedgefield' THEN 127
                    WHEN 'Teesdale' THEN 128
                    WHEN 'Wear Valley' THEN 129
                    WHEN 'Gateshead' THEN 130
                    WHEN 'Hartlepool' THEN 131
                    WHEN 'middlesbrough' THEN 132
                    WHEN 'Newcastle upon Tyne' THEN 133
                    WHEN 'North Tyneside' THEN 134
                    WHEN 'Alnwick' THEN 135
                    WHEN 'Berwick-upon-Tweed' THEN 136
                    WHEN 'Blyth Valley' THEN 137
                    WHEN 'Castle Morpeth' THEN 138
                    WHEN 'Tynedale' THEN 139
                    WHEN 'Wansbeck' THEN 140
                    WHEN 'Redcar and Cleveland' THEN 141
                    WHEN 'South Tyneside' THEN 142
                    WHEN 'Stockton-on-Tees' THEN 143
                    WHEN 'Sunderland' THEN 144
                    WHEN 'Blackburn with Darwen' THEN 145
                    WHEN 'Blackpool' THEN 146
                    WHEN 'Bolton' THEN 147
                    WHEN 'Bury' THEN 148
                    WHEN 'Chester' THEN 149
                    WHEN 'Congleton' THEN 150
                    WHEN 'Crewe and Nantwich' THEN 151
                    WHEN 'Ellesmere Port & Neston' THEN 152
                    WHEN 'Macclesfield' THEN 153
                    WHEN 'Vale Royal' THEN 154
                    WHEN 'Allerdale' THEN 155
                    WHEN 'Barrow-in-Furness' THEN 156
                    WHEN 'Carlisle' THEN 157
                    WHEN 'Copeland' THEN 158
                    WHEN 'Eden' THEN 159
                    WHEN 'South Lakeland' THEN 160
                    WHEN 'Halton' THEN 161
                    WHEN 'Knowsley' THEN 162
                    WHEN 'Burnley' THEN 163
                    WHEN 'Chorley' THEN 164
                    WHEN 'Fylde' THEN 165
                    WHEN 'Hyndburn' THEN 166
                    WHEN 'Lancaster' THEN 167
                    WHEN 'Pendle' THEN 168
                    WHEN 'Preston' THEN 169
                    WHEN 'Ribble Valley' THEN 170
                    WHEN 'Rossendale' THEN 171
                    WHEN 'South Ribble' THEN 172
                    WHEN 'West Lancashire' THEN 173
                    WHEN 'Wyre' THEN 174
                    WHEN 'Liverpool' THEN 175
                    WHEN 'Manchester' THEN 176
                    WHEN 'Oldham' THEN 177
                    WHEN 'Rochdale' THEN 178
                    WHEN 'Salford' THEN 179
                    WHEN 'Sefton' THEN 180
                    WHEN 'St. Helens' THEN 181
                    WHEN 'Stockport' THEN 182
                    WHEN 'Tameside' THEN 183
                    WHEN 'Trafford' THEN 184
                    WHEN 'Warrington' THEN 185
                    WHEN 'Wigan' THEN 186
                    WHEN 'Wirral' THEN 187
                    WHEN 'Bracknell Forest' THEN 188
                    WHEN 'Brighton and Hove' THEN 189
                    WHEN 'Aylesbury Vale' THEN 190
                    WHEN 'Chiltern' THEN 191
                    WHEN 'South Bucks' THEN 192
                    WHEN 'Wycombe' THEN 193
                    WHEN 'Eastbourne' THEN 194
                    WHEN 'Hastings' THEN 195
                    WHEN 'Lewes' THEN 196
                    WHEN 'Rother' THEN 197
                    WHEN 'Wealden' THEN 198
                    WHEN 'Basingstoke and Deane' THEN 199
                    WHEN 'East Hampshire' THEN 200
                    WHEN 'Eastleigh' THEN 201
                    WHEN 'Fareham' THEN 202
                    WHEN 'Gosport' THEN 203
                    WHEN 'Hart' THEN 204
                    WHEN 'Havant' THEN 205
                    WHEN 'New Forest' THEN 206
                    WHEN 'Rushmoor' THEN 207
                    WHEN 'Test Valley' THEN 208
                    WHEN 'Winchester' THEN 209
                    WHEN 'Isle of Wight' THEN 210
                    WHEN 'Ashford' THEN 211
                    WHEN 'Canterbury' THEN 212
                    WHEN 'Dartford' THEN 213
                    WHEN 'Dover' THEN 214
                    WHEN 'Gravesham' THEN 215
                    WHEN 'Maidstone' THEN 216
                    WHEN 'Sevenoaks' THEN 217
                    WHEN 'Shepway' THEN 218
                    WHEN 'Swale' THEN 219
                    WHEN 'Thanet' THEN 220
                    WHEN 'Tonbridge and Malling' THEN 221
                    WHEN 'Tunbridge Wells' THEN 222
                    WHEN 'Medway' THEN 223
                    WHEN 'Milton Keynes' THEN 224
                    WHEN 'Cherwell' THEN 225
                    WHEN 'Oxford' THEN 226
                    WHEN 'South Oxfordshire' THEN 227
                    WHEN 'Vale of White Horse' THEN 228
                    WHEN 'West Oxfordshire' THEN 229
                    WHEN 'Portsmouth' THEN 230
                    WHEN 'Reading' THEN 231
                    WHEN 'Slough' THEN 232
                    WHEN 'Southampton' THEN 233
                    WHEN 'Elmbridge' THEN 234
                    WHEN 'Epsom and Ewell' THEN 235
                    WHEN 'Guildford' THEN 236
                    WHEN 'Mole Valley' THEN 237
                    WHEN 'Reigate and Banstead' THEN 238
                    WHEN 'Runnymede' THEN 239
                    WHEN 'Spelthorne' THEN 240
                    WHEN 'Surrey Heath' THEN 241
                    WHEN 'Tandridge' THEN 242
                    WHEN 'Waverley' THEN 243
                    WHEN 'Woking' THEN 244
                    WHEN 'West Berkshire' THEN 245
                    WHEN 'Adur' THEN 246
                    WHEN 'Arun' THEN 247
                    WHEN 'Chichester' THEN 248
                    WHEN 'Crawley' THEN 249
                    WHEN 'Horsham' THEN 250
                    WHEN 'Mid Sussex' THEN 251
                    WHEN 'Worthing' THEN 252
                    WHEN 'Windsor and Maidenhead' THEN 253
                    WHEN 'Wokingham' THEN 254
                    WHEN 'Bath and North East Somerset' THEN 255
                    WHEN 'Bournemouth' THEN 256
                    WHEN 'City of Bristol' THEN 257
                    WHEN 'Caradon' THEN 258
                    WHEN 'Carrick' THEN 259
                    WHEN 'Kerrier' THEN 260
                    WHEN 'North Cornwall' THEN 261
                    WHEN 'Penwith' THEN 262
                    WHEN 'Restormel' THEN 263
                    WHEN 'East Devon' THEN 264
                    WHEN 'Exeter' THEN 265
                    WHEN 'Mid Devon' THEN 266
                    WHEN 'North Devon' THEN 267
                    WHEN 'South Hams' THEN 268
                    WHEN 'Teignbridge' THEN 269
                    WHEN 'Torridge' THEN 270
                    WHEN 'West Devon' THEN 271
                    WHEN 'Christchurch' THEN 272
                    WHEN 'East Dorset' THEN 273
                    WHEN 'North Dorset' THEN 274
                    WHEN 'Purbeck' THEN 275
                    WHEN 'West Dorset' THEN 276
                    WHEN 'Weymouth and Portland' THEN 277
                    WHEN 'Cheltenham' THEN 278
                    WHEN 'Cotswold' THEN 279
                    WHEN 'Forest of Dean' THEN 280
                    WHEN 'Gloucester' THEN 281
                    WHEN 'Stroud' THEN 282
                    WHEN 'Tewkesbury' THEN 283
                    WHEN 'Isles of Scilly' THEN 284
                    WHEN 'North Somerset' THEN 285
                    WHEN 'Plymouth' THEN 286
                    WHEN 'Poole' THEN 287
                    WHEN 'Mendip' THEN 288
                    WHEN 'Sedgemoor' THEN 289
                    WHEN 'South Somerset' THEN 290
                    WHEN 'Taunton Deane' THEN 291
                    WHEN 'West Somerset' THEN 292
                    WHEN 'South Gloucestershire' THEN 293
                    WHEN 'Swindon' THEN 294
                    WHEN 'Torbay' THEN 295
                    WHEN 'Kennet' THEN 296
                    WHEN 'North Wiltshire' THEN 297
                    WHEN 'Salisbury' THEN 298
                    WHEN 'West Wiltshire' THEN 299
                    WHEN 'Birmingham' THEN 300
                    WHEN 'Coventry' THEN 301
                    WHEN 'Dudley' THEN 302
                    WHEN 'Herefordshire' THEN 303
                    WHEN 'Sandwell' THEN 304
                    WHEN 'Bridgnorth' THEN 305
                    WHEN 'North Shropshire' THEN 306
                    WHEN 'Oswestry' THEN 307
                    WHEN 'Shrewsbury and Atcham' THEN 308
                    WHEN 'South Shropshire' THEN 309
                    WHEN 'Solihull' THEN 310
                    WHEN 'Cannock Chase' THEN 311
                    WHEN 'East Staffordshire' THEN 312
                    WHEN 'Lichfield' THEN 313
                    WHEN 'Newcastle-under-Lyme' THEN 314
                    WHEN 'South Staffordshire' THEN 315
                    WHEN 'Stafford' THEN 316
                    WHEN 'Staffordshire Moorlands' THEN 317
                    WHEN 'Tamworth' THEN 318
                    WHEN 'Stoke-on-Trent' THEN 319
                    WHEN 'Telford and Wrekin' THEN 320
                    WHEN 'Walsall' THEN 321
                    WHEN 'North Warwickshire' THEN 322
                    WHEN 'Nuneaton and Bedworth' THEN 323
                    WHEN 'Rugby' THEN 324
                    WHEN 'Stratford-on-Avon' THEN 325
                    WHEN 'Warwick' THEN 326
                    WHEN 'Wolverhampton' THEN 327
                    WHEN 'Bromsgrove' THEN 328
                    WHEN 'Malvern Hills' THEN 329
                    WHEN 'Redditch' THEN 330
                    WHEN 'Worcester' THEN 331
                    WHEN 'Wychavon' THEN 332
                    WHEN 'Wyre Forest' THEN 333
                    WHEN 'Barnsley' THEN 334
                    WHEN 'Bradford' THEN 335
                    WHEN 'Calderdale' THEN 336
                    WHEN 'Doncaster' THEN 337
                    WHEN 'East Riding of Yorkshire' THEN 338
                    WHEN 'Kingston upon Hull' THEN 339
                    WHEN 'Kirklees' THEN 340
                    WHEN 'Leeds' THEN 341
                    WHEN 'North East Lincolnshire' THEN 342
                    WHEN 'North Lincolnshire' THEN 343
                    WHEN 'Craven' THEN 344
                    WHEN 'Hambleton' THEN 345
                    WHEN 'Harrogate' THEN 346
                    WHEN 'Richmondshire' THEN 347
                    WHEN 'Ryedale' THEN 348
                    WHEN 'Scarborough' THEN 349
                    WHEN 'Selby' THEN 350
                    WHEN 'Rotherham' THEN 351
                    WHEN 'Sheffield' THEN 352
                    WHEN 'Wakefield' THEN 353
                    WHEN 'York' THEN 354
                    WHEN 'Bedford' THEN 400
                    WHEN 'Central Bedfordshire' THEN 401
                    WHEN 'Cheshire East' THEN 402
                    WHEN 'Cheshire West and Chester' THEN 403
                    WHEN 'Cornwall' THEN 404
                    WHEN 'Isles of Scilly' THEN 405
                    WHEN 'County Durham' THEN 406
                    WHEN 'Northumberland' THEN 407
                    WHEN 'Shropshire' THEN 408
                    WHEN 'Wiltshire' THEN 409
                 END
          FROM   "Cssr"
          WHERE  "LocalCustodianCode" IN (SELECT local_custodian_code FROM cqcref.pcodedata WHERE postcode = w."PostcodeValue")
          LIMIT 1
       ),-1) homelauthid, -- 061
       'na' homeparliamentaryconstituency, -- 062
       'na' distwrkk, -- 063
       CASE
          WHEN "RecruitedFromValue" IS NULL THEN -1
          WHEN "RecruitedFromValue" = 'No' THEN 225
          WHEN 'Yes' THEN
             (
                SELECT CASE "From"
                          WHEN 'Adult care sector: Local Authority' THEN 210
                          WHEN 'Adult care sector: private or voluntary sector' THEN 211
                          WHEN 'Health sector' THEN 214
                          WHEN 'Other sector' THEN 216
                          WHEN 'Internal promotion or transfer or career development' THEN 217
                          WHEN 'Not previously employed' THEN 219
                          WHEN 'Agency' THEN 221
                          WHEN 'Other sources' THEN 224
                          WHEN 'Childrens/young people''s social care' THEN 226
                          WHEN 'First role after education' THEN 227
                       END
                FROM   "RecruitedFrom"
                WHERE  "ID" = w."RecruitedFromOtherFK"
             )
       END scerec, -- 064
       TO_CHAR("RecruitedFromChangedAt",'DD/MM/YYYY') scerec_changedate, -- 065
       TO_CHAR("RecruitedFromSavedAt",'DD/MM/YYYY') scerec_savedate, -- 066
       CASE "SocialCareStartDateValue" WHEN 'Yes' THEN "SocialCareStartDateYear" WHEN 'No' THEN -2 ELSE  -1 END startsec, -- 067
       TO_CHAR("SocialCareStartDateChangedAt",'DD/MM/YYYY') startsec_changedate, -- 068
       TO_CHAR("SocialCareStartDateSavedAt",'DD/MM/YYYY') startsec_savedate, -- 069
       CASE "DaysSickValue" WHEN 'Yes' THEN "DaysSickDays" WHEN 'No' THEN -2 ELSE  -1 END dayssick, -- 070
       TO_CHAR("DaysSickChangedAt",'DD/MM/YYYY') dayssick_changedate, -- 071
       TO_CHAR("DaysSickSavedAt",'DD/MM/YYYY') dayssick_savedate, -- 072
       CASE "ZeroHoursContractValue" WHEN 'Yes' THEN 1 WHEN 'No' THEN 0 WHEN 'Don''t know' THEN -2 ELSE -1 END zerohours, -- 073
       TO_CHAR("ZeroHoursContractChangedAt",'DD/MM/YYYY') zerohours_changedate, -- 074
       TO_CHAR("ZeroHoursContractSavedAt",'DD/MM/YYYY') zerohours_savedate, -- 075
       CASE "WeeklyHoursAverageValue" WHEN 'Yes' THEN "WeeklyHoursAverageHours" WHEN 'No' THEN -2 ELSE -1 END averagehours, -- 076
       TO_CHAR("WeeklyHoursAverageChangedAt",'DD/MM/YYYY') zero_averagehours_changedate, -- 077
       TO_CHAR("WeeklyHoursAverageSavedAt",'DD/MM/YYYY') zero_averagehours_savedate, -- 078
       CASE "WeeklyHoursContractedValue" WHEN 'Yes' THEN "WeeklyHoursContractedHours" WHEN 'No' THEN -2 ELSE -1 END conthrs, -- 079
       TO_CHAR("WeeklyHoursContractedChangedAt",'DD/MM/YYYY') conthrs_changedate, -- 080
       TO_CHAR("WeeklyHoursContractedSavedAt",'DD/MM/YYYY') conthrs_savedate, -- 081
       CASE "AnnualHourlyPayValue" WHEN 'Annually' THEN 250 WHEN 'Hourly' THEN 252 WHEN 'Don''t know' THEN -2 ELSE -1 END salaryint, -- 082
       CASE "AnnualHourlyPayValue" WHEN 'Annually' THEN "AnnualHourlyPayRate" ELSE NULL END salary, -- 083
       CASE "AnnualHourlyPayValue" WHEN 'Hourly' THEN "AnnualHourlyPayRate" ELSE NULL END hrlyrate, -- 084
       TO_CHAR("AnnualHourlyPayChangedAt",'DD/MM/YYYY') pay_changedate, -- 085
       TO_CHAR("AnnualHourlyPaySavedAt",'DD/MM/YYYY') pay_savedate, -- 086
       CASE "CareCertificateValue" WHEN 'Yes, completed' THEN 1 WHEN 'No' THEN 2 WHEN 'Yes, in progress or partially completed' THEN 3 ELSE -1 END ccstatus, -- 087
       TO_CHAR("CareCertificateChangedAt",'DD/MM/YYYY') ccstatus_changedate, -- 088
       TO_CHAR("CareCertificateSavedAt",'DD/MM/YYYY') ccstatus_savedate, -- 089
       CASE "ApprenticeshipTrainingValue" WHEN 'Yes' THEN 1 WHEN 'No' THEN 2 WHEN 'Don''t know' THEN 3 ELSE -1 END apprentice, -- 090
       TO_CHAR("ApprenticeshipTrainingChangedAt",'DD/MM/YYYY') apprentice_changedate, -- 091
       TO_CHAR("ApprenticeshipTrainingSavedAt",'DD/MM/YYYY') apprentice_savedate, -- 092
       CASE "QualificationInSocialCareValue" WHEN 'Yes' THEN 1 WHEN 'No' THEN 2 WHEN 'Don''t know' THEN 3 ELSE -1 END scqheld, -- 093
       TO_CHAR("QualificationInSocialCareChangedAt",'DD/MM/YYYY') scqheld_changedate, -- 094
       TO_CHAR("QualificationInSocialCareSavedAt",'DD/MM/YYYY') scqheld_savedate, -- 095
       COALESCE((
          SELECT CASE "Level"
                    WHEN 'Entry level' THEN 0
                    WHEN 'Level 1' THEN 1
                    WHEN 'Level 2' THEN 2
                    WHEN 'Level 3' THEN 3
                    WHEN 'Level 4' THEN 4
                    WHEN 'Level 5' THEN 5
                    WHEN 'Level 6' THEN 6
                    WHEN 'Level 7' THEN 7
                    WHEN 'Level 8 or above' THEN 8
                    WHEN 'Don''t know' THEN 10
                 END
          FROM   "Qualification"
          WHERE  "ID" = w."SocialCareQualificationFKValue"
       ),-1) levelscqheld, -- 096
       TO_CHAR("SocialCareQualificationFKChangedAt",'DD/MM/YYYY') levelscqheld_changedate, -- 097
       TO_CHAR("SocialCareQualificationFKSavedAt",'DD/MM/YYYY') levelscqheld_savedate, -- 098
       CASE "OtherQualificationsValue" WHEN 'Yes' THEN 1 WHEN 'No' THEN 2 WHEN 'Don''t know' THEN 3 ELSE -1 END nonscqheld, -- 099
       TO_CHAR("OtherQualificationsChangedAt",'DD/MM/YYYY') nonscqheld_changedate, -- 100
       TO_CHAR("OtherQualificationsSavedAt",'DD/MM/YYYY') nonscqheld_savedate, -- 101
       COALESCE((
          SELECT CASE "Level"
                    WHEN 'Entry level' THEN 0
                    WHEN 'Level 1' THEN 1
                    WHEN 'Level 2' THEN 2
                    WHEN 'Level 3' THEN 3
                    WHEN 'Level 4' THEN 4
                    WHEN 'Level 5' THEN 5
                    WHEN 'Level 6' THEN 6
                    WHEN 'Level 7' THEN 7
                    WHEN 'Level 8 or above' THEN 8
                    WHEN 'Don''t know' THEN 10
                 END
          FROM   "Qualification"
          WHERE  "ID" = w."HighestQualificationFKValue"
       ),-1) levelnonscqheld, -- 102
       TO_CHAR("HighestQualificationFKChangedAt",'DD/MM/YYYY') levelnonscqheld_changedate, -- 103
       TO_CHAR("HighestQualificationFKSavedAt",'DD/MM/YYYY') levelnonscqheld_savedate, -- 104
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" LIMIT 1),0) listqualsachflag, -- 105
       (SELECT TO_CHAR(MAX(updated),'DD/MM/YYYY') FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID") listqualsachflag_changedate, -- 106
       (SELECT TO_CHAR(MAX(created),'DD/MM/YYYY') FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID") listqualsachflag_savedate, -- 107
       COALESCE((
          SELECT CAST((CASE WHEN b."Level" = 'E' THEN '1' WHEN b."Level" IS NULL THEN '-1' ELSE b."Level" END) AS INTEGER)
          FROM   "WorkerQualifications" a JOIN "Qualifications" b ON a."QualificationsFK" = b."ID" AND a."WorkerFK" = w."ID"
          ORDER  BY 1 DESC LIMIT 1
       ),-1) listhiqualev, -- 108
       (
          SELECT TO_CHAR(updated,'DD/MM/YYYY')
          FROM   (
                    SELECT CAST((CASE WHEN b."Level" = 'E' THEN '1' WHEN b."Level" IS NULL THEN '-1' ELSE b."Level" END) AS INTEGER),a.updated
                    FROM   "WorkerQualifications" a JOIN "Qualifications" b ON a."QualificationsFK" = b."ID" AND a."WorkerFK" = w."ID"
                    ORDER  BY 1 DESC,2 DESC LIMIT 1
                 ) z
       ) listhiqualev_changedate, -- 109
       (
          SELECT TO_CHAR(created,'DD/MM/YYYY')
          FROM   (
                    SELECT CAST((CASE WHEN b."Level" = 'E' THEN '1' WHEN b."Level" IS NULL THEN '-1' ELSE b."Level" END) AS INTEGER),a.created
                    FROM   "WorkerQualifications" a JOIN "Qualifications" b ON a."QualificationsFK" = b."ID" AND a."WorkerFK" = w."ID"
                    ORDER  BY 1 DESC,2 DESC LIMIT 1
                 ) z
       ) listhiqualev_savedate, -- 110
       CASE "MainJobFKValue"
          WHEN 26 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 26 LIMIT 1),0) ELSE 0 END
       END jr01flag, -- 111
       CASE "MainJobFKValue"
          WHEN 15 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 15 LIMIT 1),0) ELSE 0 END
       END jr02flag, -- 112
       CASE "MainJobFKValue"
          WHEN 13 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 13 LIMIT 1),0) ELSE 0 END
       END jr03flag, -- 113
       CASE "MainJobFKValue"
          WHEN 22 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 22 LIMIT 1),0) ELSE 0 END
       END jr04flag, -- 114
       CASE "MainJobFKValue"
          WHEN 28 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 28 LIMIT 1),0) ELSE 0 END
       END jr05flag, -- 115
       CASE "MainJobFKValue"
          WHEN 27 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 27 LIMIT 1),0) ELSE 0 END
       END jr06flag, -- 116
       CASE "MainJobFKValue"
          WHEN 25 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 25 LIMIT 1),0) ELSE 0 END
       END jr07flag, -- 117
       CASE "MainJobFKValue"
          WHEN 10 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 10 LIMIT 1),0) ELSE 0 END
       END jr08flag, -- 118
       CASE "MainJobFKValue"
          WHEN 11 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 11 LIMIT 1),0) ELSE 0 END
       END jr09flag, -- 119
       CASE "MainJobFKValue"
          WHEN 12 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 12 LIMIT 1),0) ELSE 0 END
       END jr10flag, -- 120
       CASE "MainJobFKValue"
          WHEN 3 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 3 LIMIT 1),0) ELSE 0 END
       END jr11flag, -- 121
       CASE "MainJobFKValue"
          WHEN 18 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 18 LIMIT 1),0) ELSE 0 END
       END jr15flag, -- 122
       CASE "MainJobFKValue"
          WHEN 23 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 23 LIMIT 1),0) ELSE 0 END
       END jr16flag, -- 123
       CASE "MainJobFKValue"
          WHEN 4 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 4 LIMIT 1),0) ELSE 0 END
       END jr17flag, -- 124
       CASE "MainJobFKValue"
          WHEN 29 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 29 LIMIT 1),0) ELSE 0 END
       END jr22flag, -- 125
       CASE "MainJobFKValue"
          WHEN 20 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 20 LIMIT 1),0) ELSE 0 END
       END jr23flag, -- 126
       CASE "MainJobFKValue"
          WHEN 14 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 14 LIMIT 1),0) ELSE 0 END
       END jr24flag, -- 127
       CASE "MainJobFKValue"
          WHEN 2 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 2 LIMIT 1),0) ELSE 0 END
       END jr25flag, -- 128
       CASE "MainJobFKValue"
          WHEN 5 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 5 LIMIT 1),0) ELSE 0 END
       END jr26flag, -- 129
       CASE "MainJobFKValue"
          WHEN 21 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 21 LIMIT 1),0) ELSE 0 END
       END jr27flag, -- 130
       -- Removed jr33flag as confirmed by Will Fenton on 24/10/2019
       CASE "MainJobFKValue"
          WHEN 1 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 1 LIMIT 1),0) ELSE 0 END
       END jr34flag, -- 132
       CASE "MainJobFKValue"
          WHEN 24 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 24 LIMIT 1),0) ELSE 0 END
       END jr35flag, -- 133
       CASE "MainJobFKValue"
          WHEN 19 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 19 LIMIT 1),0) ELSE 0 END
       END jr36flag, -- 134
       CASE "MainJobFKValue"
          WHEN 17 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 17 LIMIT 1),0) ELSE 0 END
       END jr37flag, -- 135
       CASE "MainJobFKValue"
          WHEN 16 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 16 LIMIT 1),0) ELSE 0 END
       END jr38flag, -- 136
       CASE "MainJobFKValue"
          WHEN 7 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 7 LIMIT 1),0) ELSE 0 END
       END jr39flag, -- 137
       CASE "MainJobFKValue"
          WHEN 8 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 8 LIMIT 1),0) ELSE 0 END
       END jr40flag, -- 138
       CASE "MainJobFKValue"
          WHEN 9 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 9 LIMIT 1),0) ELSE 0 END
       END jr41flag, -- 139
       CASE "MainJobFKValue"
          WHEN 6 THEN 1
          ELSE CASE "OtherJobsValue" WHEN 'Yes' THEN COALESCE((SELECT 1 FROM "WorkerJobs" WHERE "WorkerFK" = w."ID" AND "JobFK" = 6 LIMIT 1),0) ELSE 0 END
       END jr42flag, -- 140
       CASE "RegisteredNurseValue"
          WHEN 'Adult Nurse' THEN 1
          WHEN 'Mental Health Nurse' THEN 2
          WHEN 'Learning Disabilities Nurse' THEN 3
          WHEN 'Children''s Nurse' THEN 4
          WHEN 'Enrolled Nurse' THEN 5
          ELSE -1
       END jd16registered, -- 141
       TO_CHAR("RegisteredNurseChangedAt",'DD/MM/YYYY') jd16registered_changedate, -- 142
       TO_CHAR("RegisteredNurseSavedAt",'DD/MM/YYYY') jd16registered_savedate, -- 143
       CASE "NurseSpecialismFKValue" WHEN 1 THEN 1 ELSE 0 END jr16cat1, -- 144
       CASE "NurseSpecialismFKValue" WHEN 2 THEN 1 ELSE 0 END jr16cat2, -- 145
       CASE "NurseSpecialismFKValue" WHEN 3 THEN 1 ELSE 0 END jr16cat3, -- 146
       CASE "NurseSpecialismFKValue" WHEN 4 THEN 1 ELSE 0 END jr16cat4, -- 147
       CASE "NurseSpecialismFKValue" WHEN 5 THEN 1 ELSE 0 END jr16cat5, -- 148
       CASE "NurseSpecialismFKValue" WHEN 6 THEN 1 ELSE 0 END jr16cat6, -- 149
       CASE "NurseSpecialismFKValue" WHEN 7 THEN 1 ELSE 0 END jr16cat7, -- 150
       CASE "NurseSpecialismFKValue" WHEN 8 THEN 1 ELSE 0 END jr16cat8, -- 151
       TO_CHAR("NurseSpecialismFKChangedAt",'DD/MM/YYYY') jr16cat_changedate, -- 152
       TO_CHAR("NurseSpecialismFKSavedAt",'DD/MM/YYYY') jr16cat_savedate, -- 153
       CASE "ApprovedMentalHealthWorkerValue" WHEN 'Yes' THEN 1 WHEN 'No' THEN 0 WHEN 'Don''t know' THEN -2 ELSE -1 END amhp, -- 154
       TO_CHAR("ApprovedMentalHealthWorkerChangedAt",'DD/MM/YYYY') amhp_changedate, -- 155
       TO_CHAR("ApprovedMentalHealthWorkerSavedAt",'DD/MM/YYYY') amhp_savedate, -- 156
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 1 LIMIT 1),0) ut01flag, -- 157
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 2 LIMIT 1),0) ut02flag, -- 158
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 3 LIMIT 1),0) ut22flag, -- 159
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 4 LIMIT 1),0) ut23flag, -- 160
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 5 LIMIT 1),0) ut25flag, -- 161
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 6 LIMIT 1),0) ut26flag, -- 162
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 7 LIMIT 1),0) ut27flag, -- 163
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 8 LIMIT 1),0) ut46flag, -- 164
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 9 LIMIT 1),0) ut03flag, -- 165
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 14 LIMIT 1),0) ut04flag, -- 166
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 13 LIMIT 1),0) ut05flag, -- 167
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 11 LIMIT 1),0) ut06flag, -- 168
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 15 LIMIT 1),0) ut07flag, -- 169
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 16 LIMIT 1),0) ut08flag, -- 170
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 10 LIMIT 1),0) ut28flag, -- 171
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 12 LIMIT 1),0) ut29flag, -- 172
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 17 LIMIT 1),0) ut31flag, -- 173
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 18 LIMIT 1),0) ut09flag, -- 174
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 20 LIMIT 1),0) ut18flag, -- 175
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 21 LIMIT 1),0) ut19flag, -- 176
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 22 LIMIT 1),0) ut20flag, -- 177
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 19 LIMIT 1),0) ut45flag, -- 178
       COALESCE((SELECT 1 FROM "EstablishmentServiceUsers" WHERE "EstablishmentID" = e."EstablishmentID" AND "ServiceUserID" = 23 LIMIT 1),0) ut21flag, -- 179
       TO_CHAR((SELECT MAX(updated) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID"),'DD/MM/YYYY') qlach_changedate, -- 180
       TO_CHAR((SELECT MAX(created) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID"),'DD/MM/YYYY') qlach_savedate, -- 181
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 97 LIMIT 1),0) ql01achq2, -- 182
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 97 LIMIT 1) ql01year2, -- 183
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 98 LIMIT 1),0) ql02achq3, -- 184
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 98 LIMIT 1) ql02year3, -- 185
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 96 LIMIT 1),0) ql03achq4, -- 186
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 96 LIMIT 1) ql03year4, -- 187
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 93 LIMIT 1),0) ql04achq2, -- 188
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 93 LIMIT 1) ql04year2, -- 189
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 94 LIMIT 1),0) ql05achq3, -- 190
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 94 LIMIT 1) ql05year3, -- 191
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 95 LIMIT 1),0) ql06achq4, -- 192
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 95 LIMIT 1) ql06year4, -- 193
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 24) ql08achq, -- 194
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 24) ql08year, -- 195
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 99) ql09achq, -- 196
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 99) ql09year, -- 197
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 100 LIMIT 1),0) ql10achq4, -- 198
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 100 LIMIT 1) ql10year4, -- 199
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 25) ql12achq3, -- 200
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 25) ql12year3, -- 201
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 102 LIMIT 1),0) ql13achq3, -- 202
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 102 LIMIT 1) ql13year3, -- 203
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 107 LIMIT 1),0) ql14achq3, -- 204
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 107 LIMIT 1) ql14year3, -- 205
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 106 LIMIT 1),0) ql15achq3, -- 206
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 106 LIMIT 1) ql15year3, -- 207
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 72 LIMIT 1),0) ql16achq4, -- 208
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 72 LIMIT 1) ql16year4, -- 209
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 89) ql17achq4, -- 210
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 89) ql17year4, -- 211
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 71 LIMIT 1),0) ql18achq4, -- 212
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 71 LIMIT 1) ql18year4, -- 213
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 16 LIMIT 1),0) ql19achq4, -- 214
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 16 LIMIT 1) ql19year4, -- 215
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 1 LIMIT 1),0) ql20achq4, -- 216
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 1 LIMIT 1) ql20year4, -- 217
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 14 LIMIT 1),0) ql22achq4, -- 218
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 14 LIMIT 1) ql22year4, -- 219
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 15 LIMIT 1),0) ql25achq4, -- 220
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 15 LIMIT 1) ql25year4, -- 221
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 26) ql26achq4, -- 222
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 26) ql26year4, -- 223
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 114) ql27achq4, -- 224
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 114) ql27year4, -- 225
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 116) ql28achq4, -- 226
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 116) ql28year4, -- 227
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 115) ql32achq3, -- 228
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 115) ql32year3, -- 229
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 113) ql33achq4, -- 230
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 113) ql33year4, -- 231
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 111 LIMIT 1),0) ql34achqe, -- 232
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 111 LIMIT 1) ql34yeare, -- 233
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 109 LIMIT 1),0) ql35achq1, -- 234
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 109 LIMIT 1) ql35year1, -- 235
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 110 LIMIT 1),0) ql36achq2, -- 236
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 110 LIMIT 1) ql36year2, -- 237
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 117) ql37achq, -- 238
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 117) ql37year, -- 239
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 118) ql38achq, -- 240
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 118) ql38year, -- 241
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 119) ql39achq, -- 242
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 119) ql39year, -- 243
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 20 LIMIT 1),0) ql41achq2, -- 244
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 20 LIMIT 1) ql41year2, -- 245
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 30 LIMIT 1),0) ql42achq3, -- 246
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 30 LIMIT 1) ql42year3, -- 247
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 4 LIMIT 1),0) ql48achq2, -- 248
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 4 LIMIT 1) ql48year2, -- 249
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 5 LIMIT 1),0) ql49achq3, -- 250
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 5 LIMIT 1) ql49year3, -- 251
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 60 LIMIT 1),0) ql50achq2, -- 252
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 60 LIMIT 1) ql50year2, -- 253
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 61 LIMIT 1),0) ql51achq3, -- 254
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 61 LIMIT 1) ql51year3, -- 255
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 10 LIMIT 1),0) ql52achq2, -- 256
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 10 LIMIT 1) ql52year2, -- 257
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 80 LIMIT 1),0) ql53achq2, -- 258
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 80 LIMIT 1) ql53year2, -- 259
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 81 LIMIT 1),0) ql54achq3, -- 260
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 81 LIMIT 1) ql54year3, -- 261
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 82 LIMIT 1),0) ql55achq2, -- 262
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 82 LIMIT 1) ql55year2, -- 263
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 83 LIMIT 1),0) ql56achq3, -- 264
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 83 LIMIT 1) ql56year3, -- 265
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 84 LIMIT 1),0) ql57achq2, -- 266
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 84 LIMIT 1) ql57year2, -- 267
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 85 LIMIT 1),0) ql58achq3, -- 268
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 85 LIMIT 1) ql58year3, -- 269
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 86 LIMIT 1),0) ql62achq5, -- 270
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 86 LIMIT 1) ql62year5, -- 271
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 87 LIMIT 1),0) ql63achq5, -- 272
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 87 LIMIT 1) ql63year5, -- 273
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 88 LIMIT 1),0) ql64achq5, -- 274
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 88 LIMIT 1) ql64year5, -- 275
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 66 LIMIT 1),0) ql67achq2, -- 276
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 66 LIMIT 1) ql67year2, -- 277
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 67 LIMIT 1),0) ql68achq3, -- 278
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 67 LIMIT 1) ql68year3, -- 279
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 23 LIMIT 1),0) ql72achq2, -- 280
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 23 LIMIT 1) ql72year2, -- 281
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 32 LIMIT 1),0) ql73achq2, -- 282
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 32 LIMIT 1) ql73year2, -- 283
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 19 LIMIT 1),0) ql74achq3, -- 284
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 19 LIMIT 1) ql74year3, -- 285
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 64 LIMIT 1),0) ql76achq2, -- 286
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 64 LIMIT 1) ql76year2, -- 287
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 65 LIMIT 1),0) ql77achq3, -- 288
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 65 LIMIT 1) ql77year3, -- 289
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 103) ql82achq, -- 290
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 103) ql82year, -- 291
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 104) ql83achq, -- 292
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 104) ql83year, -- 293
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 105) ql84achq, -- 294
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 105) ql84year, -- 295
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 17 LIMIT 1),0) ql85achq1, -- 296
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 17 LIMIT 1) ql85year1, -- 297
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 2 LIMIT 1),0) ql86achq2, -- 298
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 2 LIMIT 1) ql86year2, -- 299
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 45 LIMIT 1),0) ql87achq3, -- 300
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 45 LIMIT 1) ql87year3, -- 301
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 9 LIMIT 1),0) ql88achq2, -- 302
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 9 LIMIT 1) ql88year2, -- 303
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 69 LIMIT 1),0) ql89achq3, -- 304
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 69 LIMIT 1) ql89year3, -- 305
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 12 LIMIT 1),0) ql90achq2, -- 306
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 12 LIMIT 1) ql90year2, -- 307
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 18 LIMIT 1),0) ql91achq2, -- 308
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 18 LIMIT 1) ql91year2, -- 309
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 13 LIMIT 1),0) ql92achq1, -- 310
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 13 LIMIT 1) ql92year1, -- 311
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 62 LIMIT 1),0) ql93achq1, -- 312
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 62 LIMIT 1) ql93year1, -- 313
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 21 LIMIT 1),0) ql94achq2, -- 314
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 21 LIMIT 1) ql94year2, -- 315
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 22 LIMIT 1),0) ql95achq3, -- 316
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 22 LIMIT 1) ql95year3, -- 317
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 11 LIMIT 1),0) ql96achq2, -- 318
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 11 LIMIT 1) ql96year2, -- 319
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 59 LIMIT 1),0) ql98achq2, -- 320
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 59 LIMIT 1) ql98year2, -- 321
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 6 LIMIT 1),0) ql99achq2, -- 322
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 6 LIMIT 1) ql99year2, -- 323
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 7 LIMIT 1),0) ql100achq3, -- 324
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 7 LIMIT 1) ql100year3, -- 325
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 68 LIMIT 1),0) ql101achq3, -- 326
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 68 LIMIT 1) ql101year3, -- 327
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 63 LIMIT 1),0) ql102achq5, -- 328
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 63 LIMIT 1) ql102year5, -- 329
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 8 LIMIT 1),0) ql103achq3, -- 330
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 8 LIMIT 1) ql103year3, -- 331
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 75 LIMIT 1),0) ql104achq4, -- 332
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 75 LIMIT 1) ql104year4, -- 333
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 76 LIMIT 1),0) ql105achq4, -- 334
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 76 LIMIT 1) ql105year4, -- 335
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 3 LIMIT 1),0) ql107achq3, -- 336
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 3 LIMIT 1) ql107year3, -- 337
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 47 LIMIT 1),0) ql108achq3, -- 338
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 47 LIMIT 1) ql108year3, -- 339
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 74 LIMIT 1),0) ql109achq4, -- 340
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 74 LIMIT 1) ql109year4, -- 341
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 31 LIMIT 1),0) ql110achq4, -- 342
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 31 LIMIT 1) ql110year4, -- 343
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 27) ql111achq, -- 344
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 27) ql111year, -- 345
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 28) ql112achq, -- 346
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 28) ql112year, -- 347
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 134) ql113achq, -- 348
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 134) ql113year, -- 349
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 135) ql114achq, -- 350
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 135) ql114year, -- 351
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 90) ql115achq, -- 352
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 90) ql115year, -- 353
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 91) ql116achq, -- 354
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 91) ql116year, -- 355
       (SELECT COUNT(1) FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 112) ql117achq, -- 356
       (SELECT MAX("Year") FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 112) ql117year, -- 357
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 39 LIMIT 1),0) ql118achq, -- 358
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 39 LIMIT 1) ql118year, -- 359
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 33 LIMIT 1),0) ql119achq, -- 360
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 33 LIMIT 1) ql119year, -- 361
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 49 LIMIT 1),0) ql120achq, -- 362
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 49 LIMIT 1) ql120year, -- 363
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 34 LIMIT 1),0) ql121achq, -- 364
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 34 LIMIT 1) ql121year, -- 365
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 50 LIMIT 1),0) ql122achq, -- 366
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 50 LIMIT 1) ql122year, -- 367
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 36 LIMIT 1),0) ql123achq, -- 368
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 36 LIMIT 1) ql123year, -- 369
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 37 LIMIT 1),0) ql124achq, -- 370
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 37 LIMIT 1) ql124year, -- 371
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 38 LIMIT 1),0) ql125achq, -- 372
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 38 LIMIT 1) ql125year, -- 373
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 51 LIMIT 1),0) ql126achq, -- 374
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 51 LIMIT 1) ql126year, -- 375
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 53 LIMIT 1),0) ql127achq, -- 376
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 53 LIMIT 1) ql127year, -- 377
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 52 LIMIT 1),0) ql128achq, -- 378
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 52 LIMIT 1) ql128year, -- 379
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 77 LIMIT 1),0) ql129achq, -- 380
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 77 LIMIT 1) ql129year, -- 381
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 78 LIMIT 1),0) ql130achq, -- 382
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 78 LIMIT 1) ql130year, -- 383
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 41 LIMIT 1),0) ql131achq, -- 384
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 41 LIMIT 1) ql131year, -- 385
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 79 LIMIT 1),0) ql132achq, -- 386
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 79 LIMIT 1) ql132year, -- 387
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 55 LIMIT 1),0) ql133achq, -- 388
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 55 LIMIT 1) ql133year, -- 389
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 42 LIMIT 1),0) ql134achq, -- 390
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 42 LIMIT 1) ql134year, -- 391
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 56 LIMIT 1),0) ql135achq, -- 392
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 56 LIMIT 1) ql135year, -- 393
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 35 LIMIT 1),0) ql136achq, -- 394
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 35 LIMIT 1) ql136year, -- 395
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 40 LIMIT 1),0) ql137achq, -- 396
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 40 LIMIT 1) ql137year, -- 397
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 43 LIMIT 1),0) ql138achq, -- 398
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 43 LIMIT 1) ql138year, -- 399
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 57 LIMIT 1),0) ql139achq, -- 400
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 57 LIMIT 1) ql139year, -- 401
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 58 LIMIT 1),0) ql140achq, -- 402
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 58 LIMIT 1) ql140year, -- 403
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 48 LIMIT 1),0) ql141achq, -- 404
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 48 LIMIT 1) ql141year, -- 405
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 54 LIMIT 1),0) ql142achq, -- 406
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 54 LIMIT 1) ql142year, -- 407
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 44 LIMIT 1),0) ql143achq, -- 408
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 44 LIMIT 1) ql143year, -- 409
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 127 LIMIT 1),0) ql301app, -- 410
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 127 LIMIT 1) ql301year, -- 411
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 121 LIMIT 1),0) ql302app, -- 412
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 121 LIMIT 1) ql302year, -- 413
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 123 LIMIT 1),0) ql303app, -- 414
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 123 LIMIT 1) ql303year, -- 415
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 122 LIMIT 1),0) ql304app, -- 416
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 122 LIMIT 1) ql304year, -- 417
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 128 LIMIT 1),0) ql305app, -- 418
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 128 LIMIT 1) ql305year, -- 419
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 126 LIMIT 1),0) ql306app, -- 420
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 126 LIMIT 1) ql306year, -- 421
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 129 LIMIT 1),0) ql307app, -- 422
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 129 LIMIT 1) ql307year, -- 423
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 125 LIMIT 1),0) ql308app, -- 424
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 125 LIMIT 1) ql308year, -- 425
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 130 LIMIT 1),0) ql309app, -- 426
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 130 LIMIT 1) ql309year, -- 427
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 124 LIMIT 1),0) ql310app, -- 428
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 124 LIMIT 1) ql310year, -- 429
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 133 LIMIT 1),0) ql311app, -- 430
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 133 LIMIT 1) ql311year, -- 431
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 131 LIMIT 1),0) ql312app, -- 432
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 131 LIMIT 1) ql312year, -- 433
       COALESCE((SELECT 1 FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 132 LIMIT 1),0) ql313app, -- 434
       (SELECT "Year" FROM "WorkerQualifications" WHERE "WorkerFK" = w."ID" AND "QualificationsFK" = 132 LIMIT 1) ql313year, -- 435
       TO_CHAR((SELECT MAX(updated) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID"),'DD/MM/YYYY') train_changedate, -- 436
       TO_CHAR((SELECT MAX(created) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID"),'DD/MM/YYYY') train_savedate, -- 437
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" LIMIT 1),0) trainflag, -- 438
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 8 LIMIT 1),0) tr01flag, -- 439
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 8) tr01latestdate, -- 440
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 8) tr01count, -- 441
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 8 AND "Accredited" = 'Yes') tr01ac, -- 442
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 8 AND "Accredited" = 'No') tr01nac, -- 443
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 8 AND "Accredited" = 'Don''t know') tr01dn, -- 444
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 10 LIMIT 1),0) tr02flag, -- 445
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 10) tr02latestdate, -- 446
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 10) tr02count, -- 447
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 10 AND "Accredited" = 'Yes') tr02ac, -- 448
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 10 AND "Accredited" = 'No') tr02nac, -- 449
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 10 AND "Accredited" = 'Don''t know') tr02dn, -- 450
       -- TR03 dataset (451 to 456) removed after confirmation from Roy Price.
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 14 LIMIT 1),0) tr05flag, -- 457
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 14) tr05latestdate, -- 458
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 14) tr05count, -- 459
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 14 AND "Accredited" = 'Yes') tr05ac, -- 460
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 14 AND "Accredited" = 'No') tr05nac, -- 461
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 14 AND "Accredited" = 'Don''t know') tr05dn, -- 462
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 17 LIMIT 1),0) tr06flag, -- 463
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 17) tr06latestdate, -- 464
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 17) tr06count, -- 465
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 17 AND "Accredited" = 'Yes') tr06ac, -- 466
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 17 AND "Accredited" = 'No') tr06nac, -- 467
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 17 AND "Accredited" = 'Don''t know') tr06dn, -- 468
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 18 LIMIT 1),0) tr07flag, -- 469
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 18) tr07latestdate, -- 470
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 18) tr07count, -- 471
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 18 AND "Accredited" = 'Yes') tr07ac, -- 472
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 18 AND "Accredited" = 'No') tr07nac, -- 473
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 18 AND "Accredited" = 'Don''t know') tr07dn, -- 474
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 19 LIMIT 1),0) tr08flag, -- 475
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 19) tr08latestdate, -- 476
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 19) tr08count, -- 477
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 19 AND "Accredited" = 'Yes') tr08ac, -- 478
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 19 AND "Accredited" = 'No') tr08nac, -- 479
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 19 AND "Accredited" = 'Don''t know') tr08dn, -- 480
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 20 LIMIT 1),0) tr09flag, -- 481
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 20) tr09latestdate, -- 482
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 20) tr09count, -- 483
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 20 AND "Accredited" = 'Yes') tr09ac, -- 484
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 20 AND "Accredited" = 'No') tr09nac, -- 485
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 20 AND "Accredited" = 'Don''t know') tr09dn, -- 486
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 21 LIMIT 1),0) tr10flag, -- 487
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 21) tr10latestdate, -- 488
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 21) tr10count, -- 489
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 21 AND "Accredited" = 'Yes') tr10ac, -- 490
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 21 AND "Accredited" = 'No') tr10nac, -- 491
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 21 AND "Accredited" = 'Don''t know') tr10dn, -- 492
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 22 LIMIT 1),0) tr11flag, -- 493
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 22) tr11latestdate, -- 494
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 22) tr11count, -- 495
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 22 AND "Accredited" = 'Yes') tr11ac, -- 496
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 22 AND "Accredited" = 'No') tr11nac, -- 497
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 22 AND "Accredited" = 'Don''t know') tr11dn, -- 498
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 23 LIMIT 1),0) tr12flag, -- 499
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 23) tr12latestdate, -- 500
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 23) tr12count, -- 501
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 23 AND "Accredited" = 'Yes') tr12ac, -- 502
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 23 AND "Accredited" = 'No') tr12nac, -- 503
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 23 AND "Accredited" = 'Don''t know') tr12dn, -- 504
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 24 LIMIT 1),0) tr13flag, -- 505
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 24) tr13latestdate, -- 506
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 24) tr13count, -- 507
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 24 AND "Accredited" = 'Yes') tr13ac, -- 508
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 24 AND "Accredited" = 'No') tr13nac, -- 509
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 24 AND "Accredited" = 'Don''t know') tr13dn, -- 510
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 25 LIMIT 1),0) tr14flag, -- 511
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 25) tr14latestdate, -- 512
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 25) tr14count, -- 513
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 25 AND "Accredited" = 'Yes') tr14ac, -- 514
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 25 AND "Accredited" = 'No') tr14nac, -- 515
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 25 AND "Accredited" = 'Don''t know') tr14dn, -- 516
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 27 LIMIT 1),0) tr15flag, -- 517
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 27) tr15latestdate, -- 518
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 27) tr15count, -- 519
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 27 AND "Accredited" = 'Yes') tr15ac, -- 520
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 27 AND "Accredited" = 'No') tr15nac, -- 521
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 27 AND "Accredited" = 'Don''t know') tr15dn, -- 522
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 28 LIMIT 1),0) tr16flag, -- 523
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 28) tr16latestdate, -- 524
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 28) tr16count, -- 525
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 28 AND "Accredited" = 'Yes') tr16ac, -- 526
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 28 AND "Accredited" = 'No') tr16nac, -- 527
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 28 AND "Accredited" = 'Don''t know') tr16dn, -- 528
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 29 LIMIT 1),0) tr17flag, -- 529
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 29) tr17latestdate, -- 530
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 29) tr17count, -- 531
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 29 AND "Accredited" = 'Yes') tr17ac, -- 532
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 29 AND "Accredited" = 'No') tr17nac, -- 533
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 29 AND "Accredited" = 'Don''t know') tr17dn, -- 534
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 31 LIMIT 1),0) tr18flag, -- 535
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 31) tr18latestdate, -- 536
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 31) tr18count, -- 537
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 31 AND "Accredited" = 'Yes') tr18ac, -- 538
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 31 AND "Accredited" = 'No') tr18nac, -- 539
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 31 AND "Accredited" = 'Don''t know') tr18dn, -- 540
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 32 LIMIT 1),0) tr19flag, -- 541
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 32) tr19latestdate, -- 542
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 32) tr19count, -- 543
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 32 AND "Accredited" = 'Yes') tr19ac, -- 544
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 32 AND "Accredited" = 'No') tr19nac, -- 545
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 32 AND "Accredited" = 'Don''t know') tr19dn, -- 546
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 33 LIMIT 1),0) tr20flag, -- 547
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 33) tr20latestdate, -- 548
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 33) tr20count, -- 549
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 33 AND "Accredited" = 'Yes') tr20ac, -- 550
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 33 AND "Accredited" = 'No') tr20nac, -- 551
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 33 AND "Accredited" = 'Don''t know') tr20dn, -- 552
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 37 LIMIT 1),0) tr21flag, -- 553
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 37) tr21latestdate, -- 554
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 37) tr21count, -- 555
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 37 AND "Accredited" = 'Yes') tr21ac, -- 556
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 37 AND "Accredited" = 'No') tr21nac, -- 557
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 37 AND "Accredited" = 'Don''t know') tr21dn, -- 558
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 12 LIMIT 1),0) tr22flag, -- 559
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 12) tr22latestdate, -- 560
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 12) tr22count, -- 561
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 12 AND "Accredited" = 'Yes') tr22ac, -- 562
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 12 AND "Accredited" = 'No') tr22nac, -- 563
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 12 AND "Accredited" = 'Don''t know') tr22dn, -- 564
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 16 LIMIT 1),0) tr23flag, -- 565
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 16) tr23latestdate, -- 566
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 16) tr23count, -- 567
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 16 AND "Accredited" = 'Yes') tr23ac, -- 568
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 16 AND "Accredited" = 'No') tr23nac, -- 569
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 16 AND "Accredited" = 'Don''t know') tr23dn, -- 570
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 3 LIMIT 1),0) tr25flag, -- 571
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 3) tr25latestdate, -- 572
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 3) tr25count, -- 573
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 3 AND "Accredited" = 'Yes') tr25ac, -- 574
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 3 AND "Accredited" = 'No') tr25nac, -- 575
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 3 AND "Accredited" = 'Don''t know') tr25dn, -- 576
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 6 LIMIT 1),0) tr26flag, -- 577
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 6) tr26latestdate, -- 578
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 6) tr26count, -- 579
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 6 AND "Accredited" = 'Yes') tr26ac, -- 580
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 6 AND "Accredited" = 'No') tr26nac, -- 581
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 6 AND "Accredited" = 'Don''t know') tr26dn, -- 582
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 15 LIMIT 1),0) tr27flag, -- 583
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 15) tr27latestdate, -- 584
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 15) tr27count, -- 585
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 15 AND "Accredited" = 'Yes') tr27ac, -- 586
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 15 AND "Accredited" = 'No') tr27nac, -- 587
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 15 AND "Accredited" = 'Don''t know') tr27dn, -- 588
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 4 LIMIT 1),0) tr28flag, -- 589
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 4) tr28latestdate, -- 590
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 4) tr28count, -- 591
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 4 AND "Accredited" = 'Yes') tr28ac, -- 592
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 4 AND "Accredited" = 'No') tr28nac, -- 593
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 4 AND "Accredited" = 'Don''t know') tr28dn, -- 594
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 11 LIMIT 1),0) tr29flag, -- 595
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 11) tr29latestdate, -- 596
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 11) tr29count, -- 597
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 11 AND "Accredited" = 'Yes') tr29ac, -- 598
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 11 AND "Accredited" = 'No') tr29nac, -- 599
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 11 AND "Accredited" = 'Don''t know') tr29dn, -- 600
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 9 LIMIT 1),0) tr30flag, -- 601
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 9) tr30latestdate, -- 602
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 9) tr30count, -- 603
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 9 AND "Accredited" = 'Yes') tr30ac, -- 604
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 9 AND "Accredited" = 'No') tr30nac, -- 605
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 9 AND "Accredited" = 'Don''t know') tr30dn, -- 606
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 26 LIMIT 1),0) tr31flag, -- 607
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 26) tr31latestdate, -- 608
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 26) tr31count, -- 609
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 26 AND "Accredited" = 'Yes') tr31ac, -- 610
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 26 AND "Accredited" = 'No') tr31nac, -- 611
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 26 AND "Accredited" = 'Don''t know') tr31dn, -- 612
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 2 LIMIT 1),0) tr32flag, -- 613
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 2) tr32latestdate, -- 614
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 2) tr32count, -- 615
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 2 AND "Accredited" = 'Yes') tr32ac, -- 616
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 2 AND "Accredited" = 'No') tr32nac, -- 617
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 2 AND "Accredited" = 'Don''t know') tr32dn, -- 618
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 7 LIMIT 1),0) tr33flag, -- 619
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 7) tr33latestdate, -- 620
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 7) tr33count, -- 621
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 7 AND "Accredited" = 'Yes') tr33ac, -- 622
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 7 AND "Accredited" = 'No') tr33nac, -- 623
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 7 AND "Accredited" = 'Don''t know') tr33dn, -- 624
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 13 LIMIT 1),0) tr34flag, -- 625
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 13) tr34latestdate, -- 626
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 13) tr34count, -- 627
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 13 AND "Accredited" = 'Yes') tr34ac, -- 628
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 13 AND "Accredited" = 'No') tr34nac, -- 629
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 13 AND "Accredited" = 'Don''t know') tr34dn, -- 630
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 36 LIMIT 1),0) tr35flag, -- 631
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 36) tr35latestdate, -- 632
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 36) tr35count, -- 633
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 36 AND "Accredited" = 'Yes') tr35ac, -- 634
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 36 AND "Accredited" = 'No') tr35nac, -- 635
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 36 AND "Accredited" = 'Don''t know') tr35dn, -- 636
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 35 LIMIT 1),0) tr36flag, -- 637
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 35) tr36latestdate, -- 638
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 35) tr36count, -- 639
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 35 AND "Accredited" = 'Yes') tr36ac, -- 640
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 35 AND "Accredited" = 'No') tr36nac, -- 641
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 35 AND "Accredited" = 'Don''t know') tr36dn, -- 642
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 5 LIMIT 1),0) tr37flag, -- 643
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 5) tr37latestdate, -- 644
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 5) tr37count, -- 645
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 5 AND "Accredited" = 'Yes') tr37ac, -- 646
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 5 AND "Accredited" = 'No') tr37nac, -- 647
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 5 AND "Accredited" = 'Don''t know') tr37dn, -- 648
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 30 LIMIT 1),0) tr38flag, -- 649
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 30) tr38latestdate, -- 650
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 30) tr38count, -- 651
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 30 AND "Accredited" = 'Yes') tr38ac, -- 652
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 30 AND "Accredited" = 'No') tr38nac, -- 653
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 30 AND "Accredited" = 'Don''t know') tr38dn, -- 654
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 1 LIMIT 1),0) tr39flag, -- 655
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 1) tr39latestdate, -- 656
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 1) tr39count, -- 657
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 1 AND "Accredited" = 'Yes') tr39ac, -- 658
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 1 AND "Accredited" = 'No') tr39nac, -- 659
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 1 AND "Accredited" = 'Don''t know') tr39dn, -- 660
       COALESCE((SELECT 1 FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 34 LIMIT 1),0) tr40flag, -- 661
       (SELECT TO_CHAR(MAX("Completed"),'DD/MM/YYYY') FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 34) tr40latestdate, -- 662
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 34) tr40count, -- 663
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 34 AND "Accredited" = 'Yes') tr40ac, -- 664
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 34 AND "Accredited" = 'No') tr40nac, -- 665
       (SELECT COUNT(1) FROM "WorkerTraining" WHERE "WorkerFK" = w."ID" AND "CategoryFK" = 34 AND "Accredited" = 'Don''t know') tr40dn -- 666
FROM   "Establishment" e
       JOIN "Worker" w ON e."EstablishmentID" = w."EstablishmentFK" AND e."Archived" = false AND w."Archived" = false
       JOIN "Afr2BatchiSkAi0mo" b ON e."EstablishmentID" = b."EstablishmentID" AND b."BatchNo" = <batch_id>;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT CURRENT_DATABASE(), NOW(), 'Database view created and started creating CSV file.' status;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
\a \f | \pset footer \o <csv_filename>
SELECT /*+ PARALLEL(v_afr_worker_<batch_id>) */ * FROM v_afr_worker_<batch_id>;
\o \a \f
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT CURRENT_DATABASE(), NOW(), 'Csv file created successfully.' status;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
\q
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SeQueL21 -- SQL for Worker analysis file report END.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SeQueL30 -- SQL for creating batch for Leaver analysis file report BEGINs.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- To do ... qwerty
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SeQueL30 -- SQL for creating batch for Leaver analysis file report END.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SeQueL31 -- SQL for Leaver analysis file report BEGINs.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SET SEARCH_PATH TO cqc;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT CURRENT_DATABASE(), NOW(), 'Started creating database view.' status;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CREATE OR REPLACE TEMPORARY VIEW v_afr_leaver_<batch_id> AS
SELECT 'M' || DATE_PART('year',(b."RunDate" - INTERVAL '1 day')) || LPAD(DATE_PART('month',(b."RunDate" - INTERVAL '1 day'))::TEXT,2,'0') period, -- 001
/*
       deletedate, -- 002
       reason, -- 003
       estid, -- 004
       tribalid, -- 005
       parentestid, -- 006
       orgid, -- 007
       estnmdsid, -- 008
       workerid, -- 009
       wrkglbid, -- 010
       wkplacestat, -- 011
       createddate, -- 012
       updateddate, -- 013
       savedate, -- 014
       cqcpermission, -- 015
       lapermission, -- 016
       regtype, -- 017
       providerid, -- 018
       locationid, -- 019
       esttype, -- 020
       regionid, -- 021
       cssr, -- 022
       lauthid, -- 023
       parliamentaryconstituency, -- 024
       mainstid, -- 025
       emplstat, -- 026
       emplstat_changedate, -- 027
       emplstat_savedate, -- 028
       mainjrid, -- 029
       mainjrid_changedate, -- 030
       mainjrid_savedate, -- 031
       strtdate, -- 032
       strtdate_changedate, -- 033
       strtdate_savedate, -- 034
       age, -- 035
       age_changedate, -- 036
       age_savedate, -- 037
       gender, -- 038
       gender_changedate, -- 039
       gender_savedate, -- 040
       disabled, -- 041
       disabled_changedate, -- 042
       disabled_savedate, -- 043
       ethnicity, -- 044
       ethnicity_changedate, -- 045
       ethnicity_savedate, -- 046
       isbritish, -- 047
       nationality, -- 048
       isbritish_changedate, -- 049
       isbritish_savedate, -- 050
       britishcitizen, -- 051
       britishcitizen_changedate, -- 052
       britishcitizen_savedate, -- 053
       borninuk, -- 054
       countryofbirth, -- 055
       borninuk_changedate, -- 056
       borninuk_savedate, -- 057
       yearofentry, -- 058
       yearofentry_changedate, -- 059
       yearofentry_savedate, -- 060
       homeregionid, -- 061
       homecssrid, -- 062
       homelauthid, -- 063
       homeparliamentaryconstituency, -- 064
       distwrkk, -- 065
       scerec, -- 066
       scerec_changedate, -- 067
       scerec_savedate, -- 068
       startsec, -- 069
       startsec_changedate, -- 070
       startsec_savedate, -- 071
       dayssick, -- 072
       dayssick_changedate, -- 073
       dayssick_savedate, -- 074
       zerohours, -- 075
       zerohours_changedate, -- 076
       zerohours_savedate, -- 077
       averagehours, -- 078
       zero_averagehours_changedate, -- 079
       zero_averagehours_savedate, -- 080
       conthrs, -- 081
       conthrs_changedate, -- 082
       conthrs_savedate, -- 083
       salaryint, -- 084
       salary, -- 085
       hrlyrate, -- 086
       pay_changedate, -- 087
       pay_savedate, -- 088
       ccstatus, -- 089
       ccstatus_changedate, -- 090
       ccstatus_savedate, -- 091
       apprentice, -- 092
       apprentice_changedate, -- 093
       apprentice_savedate, -- 094
       scqheld, -- 095
       scqheld_changedate, -- 096
       scqheld_savedate, -- 097
       levelscqheld, -- 098
       levelscqheld_changedate, -- 099
       levelscqheld_savedate, -- 100
       nonscqheld, -- 101
       nonscqheld_changedate, -- 102
       nonscqheld_savedate, -- 103
       levelnonscqheld, -- 104
       levelnonscqheld_changedate, -- 105
       levelnonscqheld_savedate, -- 106
       listqualsachflag, -- 107
       listqualsachflag_changedate, -- 108
       listqualsachflag_savedate, -- 109
       listhiqualev, -- 110
       listhiqualev_changedate, -- 111
       listhiqualev_savedate, -- 112
       jr01flag, -- 113
       jr02flag, -- 114
       jr03flag, -- 115
       jr04flag, -- 116
       jr05flag, -- 117
       jr06flag, -- 118
       jr07flag, -- 119
       jr08flag, -- 120
       jr09flag, -- 121
       jr10flag, -- 122
       jr11flag, -- 123
       jr15flag, -- 124
       jr16flag, -- 125
       jr17flag, -- 126
       jr22flag, -- 127
       jr23flag, -- 128
       jr24flag, -- 129
       jr25flag, -- 130
       jr26flag, -- 131
       jr27flag, -- 132
       jr33flag, -- 133
       jr34flag, -- 134
       jr35flag, -- 135
       jr36flag, -- 136
       jr37flag, -- 137
       jr38flag, -- 138
       jr39flag, -- 139
       jr40flag, -- 140
       jr41flag, -- 141
       jr42flag, -- 142
       jd16registered, -- 143
       jd16registered_changedate, -- 144
       jd16registered_savedate, -- 145
       jr16cat1, -- 146
       jr16cat2, -- 147
       jr16cat3, -- 148
       jr16cat4, -- 149
       jr16cat5, -- 150
       jr16cat6, -- 151
       jr16cat7, -- 152
       jr16cat8, -- 153
       jr16cat_changedate, -- 154
       jr16cat_savedate, -- 155
       amhp, -- 156
       amhp_changedate, -- 157
       amhp_savedate, -- 158
       ut01flag, -- 159
       ut02flag, -- 160
       ut22flag, -- 161
       ut23flag, -- 162
       ut25flag, -- 163
       ut26flag, -- 164
       ut27flag, -- 165
       ut46flag, -- 166
       ut03flag, -- 167
       ut04flag, -- 168
       ut05flag, -- 169
       ut06flag, -- 170
       ut07flag, -- 171
       ut08flag, -- 172
       ut28flag, -- 173
       ut29flag, -- 174
       ut31flag, -- 175
       ut09flag, -- 176
       ut18flag, -- 177
       ut19flag, -- 178
       ut20flag, -- 179
       ut45flag, -- 180
       ut21flag, -- 181
       qlach_changedate, -- 182
       qlach_savedate, -- 183
       ql01achq2, -- 184
       ql01year2, -- 185
       ql02achq3, -- 186
       ql02year3, -- 187
       ql03achq4, -- 188
       ql03year4, -- 189
       ql04achq2, -- 190
       ql04year2, -- 191
       ql05achq3, -- 192
       ql05year3, -- 193
       ql06achq4, -- 194
       ql06year4, -- 195
       ql08achq, -- 196
       ql08year, -- 197
       ql09achq, -- 198
       ql09year, -- 199
       ql10achq4, -- 200
       ql10year4, -- 201
       ql12achq3, -- 202
       ql12year3, -- 203
       ql13achq3, -- 204
       ql13year3, -- 205
       ql14achq3, -- 206
       ql14year3, -- 207
       ql15achq3, -- 208
       ql15year3, -- 209
       ql16achq4, -- 210
       ql16year4, -- 211
       ql17achq4, -- 212
       ql17year4, -- 213
       ql18achq4, -- 214
       ql18year4, -- 215
       ql19achq4, -- 216
       ql19year4, -- 217
       ql20achq4, -- 218
       ql20year4, -- 219
       ql22achq4, -- 220
       ql22year4, -- 221
       ql25achq4, -- 222
       ql25year4, -- 223
       ql26achq4, -- 224
       ql26year4, -- 225
       ql27achq4, -- 226
       ql27year4, -- 227
       ql28achq4, -- 228
       ql28year4, -- 229
       ql32achq3, -- 230
       ql32year3, -- 231
       ql33achq4, -- 232
       ql33year4, -- 233
       ql34achqe, -- 234
       ql34yeare, -- 235
       ql35achq1, -- 236
       ql35year1, -- 237
       ql36achq2, -- 238
       ql36year2, -- 239
       ql37achq, -- 240
       ql37year, -- 241
       ql38achq, -- 242
       ql38year, -- 243
       ql39achq, -- 244
       ql39year, -- 245
       ql41achq2, -- 246
       ql41year2, -- 247
       ql42achq3, -- 248
       ql42year3, -- 249
       ql48achq2, -- 250
       ql48year2, -- 251
       ql49achq3, -- 252
       ql49year3, -- 253
       ql50achq2, -- 254
       ql50year2, -- 255
       ql51achq3, -- 256
       ql51year3, -- 257
       ql52achq2, -- 258
       ql52year2, -- 259
       ql53achq2, -- 260
       ql53year2, -- 261
       ql54achq3, -- 262
       ql54year3, -- 263
       ql55achq2, -- 264
       ql55year2, -- 265
       ql56achq3, -- 266
       ql56year3, -- 267
       ql57achq2, -- 268
       ql57year2, -- 269
       ql58achq3, -- 270
       ql58year3, -- 271
       ql62achq5, -- 272
       ql62year5, -- 273
       ql63achq5, -- 274
       ql63year5, -- 275
       ql64achq5, -- 276
       ql64year5, -- 277
       ql67achq2, -- 278
       ql67year2, -- 279
       ql68achq3, -- 280
       ql68year3, -- 281
       ql72achq2, -- 282
       ql72year2, -- 283
       ql73achq2, -- 284
       ql73year2, -- 285
       ql74achq3, -- 286
       ql74year3, -- 287
       ql76achq2, -- 288
       ql76year2, -- 289
       ql77achq3, -- 290
       ql77year3, -- 291
       ql82achq, -- 292
       ql82year, -- 293
       ql83achq, -- 294
       ql83year, -- 295
       ql84achq, -- 296
       ql84year, -- 297
       ql85achq1, -- 298
       ql85year1, -- 299
       ql86achq2, -- 300
       ql86year2, -- 301
       ql87achq3, -- 302
       ql87year3, -- 303
       ql88achq2, -- 304
       ql88year2, -- 305
       ql89achq3, -- 306
       ql89year3, -- 307
       ql90achq2, -- 308
       ql90year2, -- 309
       ql91achq2, -- 310
       ql91year2, -- 311
       ql92achq1, -- 312
       ql92year1, -- 313
       ql93achq1, -- 314
       ql93year1, -- 315
       ql94achq2, -- 316
       ql94year2, -- 317
       ql95achq3, -- 318
       ql95year3, -- 319
       ql96achq2, -- 320
       ql96year2, -- 321
       ql98achq2, -- 322
       ql98year2, -- 323
       ql99achq2, -- 324
       ql99year2, -- 325
       ql100achq3, -- 326
       ql100year3, -- 327
       ql101achq3, -- 328
       ql101year3, -- 329
       ql102achq5, -- 330
       ql102year5, -- 331
       ql103achq3, -- 332
       ql103year3, -- 333
       ql104achq4, -- 334
       ql104year4, -- 335
       ql105achq4, -- 336
       ql105year4, -- 337
       ql107achq3, -- 338
       ql107year3, -- 339
       ql108achq3, -- 340
       ql108year3, -- 341
       ql109achq4, -- 342
       ql109year4, -- 343
       ql110achq4, -- 344
       ql110year4, -- 345
       ql111achq, -- 346
       ql111year, -- 347
       ql112achq, -- 348
       ql112year, -- 349
       ql113achq, -- 350
       ql113year, -- 351
       ql114achq, -- 352
       ql114year, -- 353
       ql115achq, -- 354
       ql115year, -- 355
       ql116achq, -- 356
       ql116year, -- 357
       ql117achq, -- 358
       ql117year, -- 359
       ql118achq, -- 360
       ql118year, -- 361
       ql119achq, -- 362
       ql119year, -- 363
       ql120achq, -- 364
       ql120year, -- 365
       ql121achq, -- 366
       ql121year, -- 367
       ql122achq, -- 368
       ql122year, -- 369
       ql123achq, -- 370
       ql123year, -- 371
       ql124achq, -- 372
       ql124year, -- 373
       ql125achq, -- 374
       ql125year, -- 375
       ql126achq, -- 376
       ql126year, -- 377
       ql127achq, -- 378
       ql127year, -- 379
       ql128achq, -- 380
       ql128year, -- 381
       ql129achq, -- 382
       ql129year, -- 383
       ql130achq, -- 384
       ql130year, -- 385
       ql131achq, -- 386
       ql131year, -- 387
       ql132achq, -- 388
       ql132year, -- 389
       ql133achq, -- 390
       ql133year, -- 391
       ql134achq, -- 392
       ql134year, -- 393
       ql135achq, -- 394
       ql135year, -- 395
       ql136achq, -- 396
       ql136year, -- 397
       ql137achq, -- 398
       ql137year, -- 399
       ql138achq, -- 400
       ql138year, -- 401
       ql139achq, -- 402
       ql139year, -- 403
       ql140achq, -- 404
       ql140year, -- 405
       ql141achq, -- 406
       ql141year, -- 407
       ql142achq, -- 408
       ql142year, -- 409
       ql143achq, -- 410
       ql143year, -- 411
       ql301app, -- 412
       ql301year, -- 413
       ql302app, -- 414
       ql302year, -- 415
       ql303app, -- 416
       ql303year, -- 417
       ql304app, -- 418
       ql304year, -- 419
       ql305app, -- 420
       ql305year, -- 421
       ql306app, -- 422
       ql306year, -- 423
       ql307app, -- 424
       ql307year, -- 425
       ql308app, -- 426
       ql308year, -- 427
       ql309app, -- 428
       ql309year, -- 429
       ql310app, -- 430
       ql310year, -- 431
       ql311app, -- 432
       ql311year, -- 433
       ql312app, -- 434
       ql312year, -- 435
       ql313app, -- 436
       ql313year, -- 437
       train_changedate, -- 438
       train_savedate, -- 439
       trainflag, -- 440
       tr01flag, -- 441
       tr01latestdate, -- 442
       tr01count, -- 443
       tr01ac, -- 444
       tr01nac, -- 445
       tr01dn, -- 446
       tr02flag, -- 447
       tr02latestdate, -- 448
       tr02count, -- 449
       tr02ac, -- 450
       tr02nac, -- 451
       tr02dn, -- 452
       tr03flag, -- 453
       tr03latestdate, -- 454
       tr03count, -- 455
       tr03ac, -- 456
       tr03nac, -- 457
       tr03dn, -- 458
       tr05flag, -- 459
       tr05latestdate, -- 460
       tr05count, -- 461
       tr05ac, -- 462
       tr05nac, -- 463
       tr05dn, -- 464
       tr06flag, -- 465
       tr06latestdate, -- 466
       tr06count, -- 467
       tr06ac, -- 468
       tr06nac, -- 469
       tr06dn, -- 470
       tr07flag, -- 471
       tr07latestdate, -- 472
       tr07count, -- 473
       tr07ac, -- 474
       tr07nac, -- 475
       tr07dn, -- 476
       tr08flag, -- 477
       tr08latestdate, -- 478
       tr08count, -- 479
       tr08ac, -- 480
       tr08nac, -- 481
       tr08dn, -- 482
       tr09flag, -- 483
       tr09latestdate, -- 484
       tr09count, -- 485
       tr09ac, -- 486
       tr09nac, -- 487
       tr09dn, -- 488
       tr10flag, -- 489
       tr10latestdate, -- 490
       tr10count, -- 491
       tr10ac, -- 492
       tr10nac, -- 493
       tr10dn, -- 494
       tr11flag, -- 495
       tr11latestdate, -- 496
       tr11count, -- 497
       tr11ac, -- 498
       tr11nac, -- 499
       tr11dn, -- 500
       tr12flag, -- 501
       tr12latestdate, -- 502
       tr12count, -- 503
       tr12ac, -- 504
       tr12nac, -- 505
       tr12dn, -- 506
       tr13flag, -- 507
       tr13latestdate, -- 508
       tr13count, -- 509
       tr13ac, -- 510
       tr13nac, -- 511
       tr13dn, -- 512
       tr14flag, -- 513
       tr14latestdate, -- 514
       tr14count, -- 515
       tr14ac, -- 516
       tr14nac, -- 517
       tr14dn, -- 518
       tr15flag, -- 519
       tr15latestdate, -- 520
       tr15count, -- 521
       tr15ac, -- 522
       tr15nac, -- 523
       tr15dn, -- 524
       tr16flag, -- 525
       tr16latestdate, -- 526
       tr16count, -- 527
       tr16ac, -- 528
       tr16nac, -- 529
       tr16dn, -- 530
       tr17flag, -- 531
       tr17latestdate, -- 532
       tr17count, -- 533
       tr17ac, -- 534
       tr17nac, -- 535
       tr17dn, -- 536
       tr18flag, -- 537
       tr18latestdate, -- 538
       tr18count, -- 539
       tr18ac, -- 540
       tr18nac, -- 541
       tr18dn, -- 542
       tr19flag, -- 543
       tr19latestdate, -- 544
       tr19count, -- 545
       tr19ac, -- 546
       tr19nac, -- 547
       tr19dn, -- 548
       tr20flag, -- 549
       tr20latestdate, -- 550
       tr20count, -- 551
       tr20ac, -- 552
       tr20nac, -- 553
       tr20dn, -- 554
       tr21flag, -- 555
       tr21latestdate, -- 556
       tr21count, -- 557
       tr21ac, -- 558
       tr21nac, -- 559
       tr21dn, -- 560
       tr22flag, -- 561
       tr22latestdate, -- 562
       tr22count, -- 563
       tr22ac, -- 564
       tr22nac, -- 565
       tr22dn, -- 566
       tr23flag, -- 567
       tr23latestdate, -- 568
       tr23count, -- 569
       tr23ac, -- 570
       tr23nac, -- 571
       tr23dn, -- 572
       tr25flag, -- 573
       tr25latestdate, -- 574
       tr25count, -- 575
       tr25ac, -- 576
       tr25nac, -- 577
       tr25dn, -- 578
       tr26flag, -- 579
       tr26latestdate, -- 580
       tr26count, -- 581
       tr26ac, -- 582
       tr26nac, -- 583
       tr26dn, -- 584
       tr27flag, -- 585
       tr27latestdate, -- 586
       tr27count, -- 587
       tr27ac, -- 588
       tr27nac, -- 589
       tr27dn, -- 590
       tr28flag, -- 591
       tr28latestdate, -- 592
       tr28count, -- 593
       tr28ac, -- 594
       tr28nac, -- 595
       tr28dn, -- 596
       tr29flag, -- 597
       tr29latestdate, -- 598
       tr29count, -- 599
       tr29ac, -- 600
       tr29nac, -- 601
       tr29dn, -- 602
       tr30flag, -- 603
       tr30latestdate, -- 604
       tr30count, -- 605
       tr30ac, -- 606
       tr30nac, -- 607
       tr30dn, -- 608
       tr31flag, -- 609
       tr31latestdate, -- 610
       tr31count, -- 611
       tr31ac, -- 612
       tr31nac, -- 613
       tr31dn, -- 614
       tr32flag, -- 615
       tr32latestdate, -- 616
       tr32count, -- 617
       tr32ac, -- 618
       tr32nac, -- 619
       tr32dn, -- 620
       tr33flag, -- 621
       tr33latestdate, -- 622
       tr33count, -- 623
       tr33ac, -- 624
       tr33nac, -- 625
       tr33dn, -- 626
       tr34flag, -- 627
       tr34latestdate, -- 628
       tr34count, -- 629
       tr34ac, -- 630
       tr34nac, -- 631
       tr34dn, -- 632
       tr35flag, -- 633
       tr35latestdate, -- 634
       tr35count, -- 635
       tr35ac, -- 636
       tr35nac, -- 637
       tr35dn, -- 638
       tr36flag, -- 639
       tr36latestdate, -- 640
       tr36count, -- 641
       tr36ac, -- 642
       tr36nac, -- 643
       tr36dn, -- 644
       tr37flag, -- 645
       tr37latestdate, -- 646
       tr37count, -- 647
       tr37ac, -- 648
       tr37nac, -- 649
       tr37dn, -- 650
       tr38flag, -- 651
       tr38latestdate, -- 652
       tr38count, -- 653
       tr38ac, -- 654
       tr38nac, -- 655
       tr38dn, -- 656
       tr39flag, -- 657
       tr39latestdate, -- 658
       tr39count, -- 659
       tr39ac, -- 660
       tr39nac, -- 661
       tr39dn, -- 662
       tr40flag, -- 663
       tr40latestdate, -- 664
       tr40count, -- 665
       tr40ac, -- 666
       tr40nac, -- 667
*/
       (SELECT 'x') tr40dn -- 668
FROM   "Establishment" e
       JOIN "Worker" w ON e."EstablishmentID" = w."EstablishmentFK" AND w."Archived" = false
       JOIN "Afr3BatchiSkAi0mo" b ON e."EstablishmentID" = b."EstablishmentID" AND b."BatchNo" = <batch_id>;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT CURRENT_DATABASE(), NOW(), 'Creation of the view completed & csv extract started.' status;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
\a \f | \pset footer \o <csv_filename>
SELECT /*+ PARALLEL(v_afr_leaver_<batch_id>) */ * FROM v_afr_leaver_<batch_id>;
\o \a \f
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SELECT CURRENT_DATABASE(), NOW(), 'Csv file created successfully.' status;
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
\q
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SeQueL31 -- SQL for Leaver analysis file report END.
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- zip analysis_file_report_xxxx.zip *.csv

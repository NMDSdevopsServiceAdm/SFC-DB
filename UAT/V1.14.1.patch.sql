SET SEARCH_PATH TO cqc;
BEGIN TRANSACTION;

ALTER TABLE "Establishment" ADD COLUMN "LinkToParentRequested" character varying(20);

END TRANSACTION;

-- The following would be produced for only dev, staging and accessibility/demo databases - so please execute it accordingly.
\a \t
SELECT '';
SELECT CASE SUBSTRING(CURRENT_DATABASE(),1,3)
          WHEN 'sfc' THEN
             'ALTER TABLE "Establishment" OWNER TO sfcadmin;' || E'\n' ||
             'GRANT ALL ON TABLE "Establishment" TO sfcadmin;' || E'\n' ||
             'GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE "Establishment" TO "Sfc_Admin_Role";' || E'\n' ||
             'GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE "Establishment" TO "Sfc_App_Role";' || E'\n' ||
             'GRANT INSERT, SELECT, UPDATE ON TABLE "Establishment" TO "Read_Update_Role";' || E'\n' ||
             'GRANT SELECT ON TABLE "Establishment" TO "Read_Only_Role";'
          ELSE NULL
       END;
SELECT '';
\t \a
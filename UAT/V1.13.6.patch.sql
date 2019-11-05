SET SEARCH_PATH TO cqc;
​
BEGIN TRANSACTION;
   -- Adding new column : CreatedByUserUID
   ALTER TABLE "Notifications" RENAME TO "Notifications_Old";
​
   CREATE TABLE "Notifications"
   (
      "NotificationUID"    UUID NOT NULL,
      "Type"               "NotificationType" NOT NULL,
      "TypeUID"            UUID NOT NULL,
      "RecipientUserUID"   UUID NOT NULL,
      "Created"            TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW() NOT NULL,
      "IsViewed"           BOOLEAN DEFAULT FALSE,
      "CreatedByUserUID"   UUID NOT NULL
   );
​
   INSERT INTO "Notifications"
   (
      "NotificationUID",
      "Type",
      "TypeUID",
      "RecipientUserUID",
      "Created",
      "IsViewed",
      "CreatedByUserUID"
   )
   SELECT "notificationUid",
          "type",
          "typeUid",
          "recipientUserUid",
          "created",
          "isViewed",
          "notificationUid"
   FROM   "Notifications_Old";
​
   DROP TABLE "Notifications_Old";
​
   ALTER TABLE ONLY "Notifications" ADD CONSTRAINT "pk_Notifications" PRIMARY KEY ("NotificationUID");
​
   CREATE INDEX notifications_user_fki ON "Notifications" USING btree ("RecipientUserUID");
​
   ALTER TABLE ONLY "Notifications" ADD CONSTRAINT notifications_user_fk FOREIGN KEY ("RecipientUserUID") REFERENCES "User"("UserUID");
​
   ROLLBACK;
END TRANSACTION;-- https://trello.com/c/0ZyA1yib
​
-- The following would be produced for only dev, staging and accessibility/demo databases - so please execute it accordingly.
\a \t
SELECT '';
SELECT CASE SUBSTRING(CURRENT_DATABASE(),1,3)
          WHEN 'sfc' THEN
             'ALTER TABLE "Notifications" OWNER TO sfcadmin;' || E'\n' ||
             'GRANT ALL ON TABLE "Notifications" TO sfcadmin;' || E'\n' ||
             'GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE "Notifications" TO "Sfc_Admin_Role";' || E'\n' ||
             'GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE "Notifications" TO "Sfc_App_Role";' || E'\n' ||
             'GRANT INSERT, SELECT, UPDATE ON TABLE "Notifications" TO "Read_Update_Role";' || E'\n' ||
             'GRANT SELECT ON TABLE "Notifications" TO "Read_Only_Role";'
          ELSE NULL
       END;
SELECT '';
\t \a
-- https://trello.com/c/0ZyA1yib

-- Add a constraint to the users table to permit finding one based upon the uuid it has
ALTER TABLE cqc."User"
    ADD CONSTRAINT unq_useruid UNIQUE ("UserUID")
;

-- Create a new enumeration for the notification type
CREATE TYPE cqc."NotificationType" AS ENUM
    ('OWNERCHANGE');

ALTER TYPE cqc."NotificationType"
    OWNER TO sfcadmin;


-- Create the new notifications table
CREATE TABLE cqc."Notifications" (
    "notificationUid" uuid NOT NULL,
    "type" cqc."NotificationType" NOT NULL,
    "typeUid" uuid NOT NULL,
    "recipientUserUid" uuid NOT NULL,
    "created" timestamp without time zone DEFAULT now() NOT NULL,
    "isViewed" boolean DEFAULT false
);

ALTER TABLE cqc."Notifications" OWNER TO sfcadmin;

ALTER TABLE ONLY cqc."Notifications"
    ADD CONSTRAINT "pk_Notifications" PRIMARY KEY ("notificationUid");

CREATE INDEX notifications_user_fki ON cqc."Notifications" USING btree ("recipientUserUid");

ALTER TABLE ONLY cqc."Notifications"
    ADD CONSTRAINT notifications_user_fk FOREIGN KEY ("recipientUserUid") REFERENCES cqc."User"("UserUID");

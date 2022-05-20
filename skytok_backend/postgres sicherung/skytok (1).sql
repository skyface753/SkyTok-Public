-- Adminer 4.8.1 PostgreSQL 14.2 (Debian 14.2-1.pgdg110+1) dump

DROP TABLE IF EXISTS "tags";
DROP SEQUENCE IF EXISTS "tags_ID_seq";
CREATE SEQUENCE "tags_ID_seq" INCREMENT  MINVALUE  MAXVALUE  CACHE ;

CREATE TABLE "syktok"."tags" (
    "ID" integer DEFAULT nextval('"tags_ID_seq"') NOT NULL,
    "tag_name" text NOT NULL,
    CONSTRAINT "tags_pkey" PRIMARY KEY ("ID")
) WITH (oids = false);


DROP TABLE IF EXISTS "user_tags";
DROP SEQUENCE IF EXISTS "user_tags_ID_seq";
CREATE SEQUENCE "user_tags_ID_seq" INCREMENT  MINVALUE  MAXVALUE  CACHE ;

CREATE TABLE "syktok"."user_tags" (
    "ID" integer DEFAULT nextval('"user_tags_ID_seq"') NOT NULL,
    "user_id" integer NOT NULL,
    "tag_id" integer NOT NULL,
    CONSTRAINT "user_tags_pkey" PRIMARY KEY ("ID")
) WITH (oids = false);


DROP TABLE IF EXISTS "users";
CREATE TABLE "syktok"."users" (
    "ID" integer NOT NULL,
    "username" text NOT NULL,
    "mail" text NOT NULL,
    "password" text NOT NULL,
    CONSTRAINT "users_mail" UNIQUE ("mail"),
    CONSTRAINT "users_pkey" PRIMARY KEY ("ID"),
    CONSTRAINT "users_username" UNIQUE ("username")
) WITH (oids = false);


DROP TABLE IF EXISTS "video_tags";
DROP SEQUENCE IF EXISTS "video_tags_ID_seq";
CREATE SEQUENCE "video_tags_ID_seq" INCREMENT  MINVALUE  MAXVALUE  CACHE ;

CREATE TABLE "syktok"."video_tags" (
    "ID" integer DEFAULT nextval('"video_tags_ID_seq"') NOT NULL,
    "video_id" integer NOT NULL,
    "tag_id" integer NOT NULL,
    CONSTRAINT "video_tags_pkey" PRIMARY KEY ("ID")
) WITH (oids = false);


DROP TABLE IF EXISTS "videos";
CREATE TABLE "syktok"."videos" (
    "ID" integer NOT NULL,
    "path" text NOT NULL,
    "length" numeric NOT NULL,
    "user_id" integer NOT NULL,
    "descryption" text NOT NULL,
    CONSTRAINT "videos_pkey" PRIMARY KEY ("ID")
) WITH (oids = false);


ALTER TABLE ONLY "syktok"."user_tags" ADD CONSTRAINT "user_tags_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES tags("ID") NOT DEFERRABLE;
ALTER TABLE ONLY "syktok"."user_tags" ADD CONSTRAINT "user_tags_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users("ID") NOT DEFERRABLE;

ALTER TABLE ONLY "syktok"."video_tags" ADD CONSTRAINT "video_tags_tag_id_fkey" FOREIGN KEY (tag_id) REFERENCES tags("ID") NOT DEFERRABLE;
ALTER TABLE ONLY "syktok"."video_tags" ADD CONSTRAINT "video_tags_video_id_fkey" FOREIGN KEY (video_id) REFERENCES videos("ID") NOT DEFERRABLE;

ALTER TABLE ONLY "syktok"."videos" ADD CONSTRAINT "videos_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users("ID") NOT DEFERRABLE;

-- 2022-02-25 17:59:34.389309+00

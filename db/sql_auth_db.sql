CREATE TABLE "codes" (
  "email" varchar(255) NOT NULL,
  "code" varchar(6) NOT NULL,
  "ended_at" timestamp NOT NULL,
  "ip" varchar(255) NOT NULL,
  "number_attempts" int2 NOT NULL
);

CREATE TABLE "users" (
  "user_id" bigserial,
  "email" varchar NOT NULL,
  "created_at" timestamp NOT NULL,
  "region" varchar(255) NOT NULL,
  "blocked" bool NOT NULL,
  PRIMARY KEY ("user_id"),
  CONSTRAINT "email_un" UNIQUE ("email")
);


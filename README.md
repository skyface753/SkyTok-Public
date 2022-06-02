# SkyTok

A rebuild of TikTok with Flutter and Node.js

# RUN

1. `cd skytok_backend && npm install && docker-compose -f docker-compose-debug.yml up -d && npm run debug-local`
2. http://localhost:8093 -> New Server -> Hostname: "db" -> User: "postgres" -> Password: "example"
3. Create Database -> Name: skytok -> Import Backup from /skytok_backend/postgres sicherung/skytok_postgres.sql
4. `cd skytok_flutter && flutter pub get && flutter run`
5. Username and Password: "syktok"

# INFO

I stored the videos and the pictures in an s3 bucket.
So you cannot access the videos and pictures. You have to setup an own s3 bucket or change the sorage in the backend.

# dev-docker-file
FROM postgres:latest

ENV POSTGRES_HOST_AUTH_METHOD=trust

EXPOSE 5432:5432

COPY ./init-db.sql /docker-entrypoint-initdb.d/init-user-db.sql

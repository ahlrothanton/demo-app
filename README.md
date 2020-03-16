# Demo application

Application for demo purposes.

Originally built for GCP Meetup - Tampere.

---

## Usage

- Docker-compose

  ```shell
  docker-compose up
  ````

- GCP

  ```shell
  ./deploy GCP_PROJECT_NAME
  ````

---

## Architecture

Classical three-tier web application. Frontend is written with VueJS, and it runs on nginx. Backend is a REST API running on FastAPI framework. Data is stored in Google Cloud SQL running Postgresql.

### Frontend

Single page Vue.js application, that let's users vote for their favourite 90's action movie heroes.

Runs of nginx. Uses axios library, to do API calls.

### Backend

Python FastAPI application, that uses the REST API model.

Just updates the scores in database, or inserts new action heroes(should throw 500).

### Database

Single Postgresql database in Google Cloud SQL.

#### Data Model

- single table    - actors
  - actor_id(pk)  - serial
  - first_name    - Arnold
  - last_name     -  Schwarzenegger
  - votes         - 0
  - imgage_link   - 'images/arnold.png'
  - created_on    - TIMESTAMP
  - last_modified - TIMESTAMP

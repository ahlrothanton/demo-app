#!/usr/bin/env bash
###############################################################################
# Description:
#    Script to deploy/undeploy demo-app infrastructure on GCP(GKE, GCR, Cloud SQL)
#
# Dependencies:
#    google-cloud-sdk(gcloud, gsutil), kubectl, docker
#
# Usage:
#     ./deploy.sh GCP_PROJECT_NAME
###############################################################################


function undeploy {

    # TODO: don't echo anything, if there's nothing to delete
    
    set +e

    clear
    echo "----- undeploying ${APP_NAME} -----"

    echo "  deleting local docker images"
    docker rmi gcr.io/${GCP_PROJECT}/demo-app-backend gcr.io/${GCP_PROJECT}/demo-app-frontend 2> /dev/null

    echo "  deleting gcr docker images"
    gcloud container images delete "gcr.io/${GCP_PROJECT}/demo-app-backend:latest" --force-delete-tags --quiet 2> /dev/null
    gcloud container images delete "gcr.io/${GCP_PROJECT}/demo-app-frontend:latest" --force-delete-tags --quiet 2> /dev/null

    # delete gke cluster
    echo "  deleting gke cluster: ${APP_NAME}-cluster"
    gcloud container clusters delete "${APP_NAME}-cluster" -q 2> /dev/null

    # delete cloud sql instances
    gcloud sql instances list | grep "${APP_NAME}-sql" > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        for INSTANCE in $(gcloud sql instances list | grep "${APP_NAME}-sql" | awk '{ print $1 }' ); do
            echo "  deleting cloud sql instance: ${INSTANCE}"
            gcloud sql instances delete "${INSTANCE}" -q 2> /dev/null
        done
    fi

    echo "  deleting gcs bucket: ${GCP_BUCKET_NAME}"
    gsutil -m rm -r "gs://${GCP_BUCKET_NAME}" 2> /dev/null

    # deleting iam service-accounts
    gcloud iam service-accounts list | grep "sqlproxy-sa" > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        for SA in $(gcloud iam service-accounts list | grep "sqlproxy-sa" | awk '{ print $2 }' ); do
            echo "  deleting iam service-account: ${SA}"
            gcloud iam service-accounts delete ${SA} -q
        done
    fi
    gcloud iam service-accounts list | grep "backend-sa" > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        for SA in $(gcloud iam service-accounts list | grep "backend-sa" | awk '{ print $2 }' ); do
            echo "  deleting iam service-account: ${SA}"
            gcloud iam service-accounts delete ${SA} -q
        done
    fi

    echo "Created GCP resources deleted. Logs and disks need to be manually deleted!"
}

function deploy {

    clear
    echo "----- deploying ${APP_NAME} -----"

    # create gcs bucket, if it doesn't exist
    set +e
    gsutil ls "gs://${GCP_BUCKET_NAME}"
    if [[ $? -ne 0 ]]; then
        gsutil mb -c regional -l "${GCP_COMPUTE_REGION}" "gs://${GCP_BUCKET_NAME}"
    fi
    set -e

    # copy sql data file to gcs bucket
    gsutil cp database/init-db.sql "gs://${GCP_BUCKET_NAME}/init-db.sql"

    # create cloud sql instance, if it doesn't exist
    set +e
    gcloud sql instances describe "${APP_NAME}-sql-${UUID}" > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "  creating Cloud SQL instance ${APP_NAME}-sql-${UUID}"
        gcloud sql instances create "${APP_NAME}-sql-${UUID}" \
            --zone "${GCP_COMPUTE_ZONE}" \
            --database-version=POSTGRES_11 \
            --memory 4 \
            --cpu 2
    fi
    set -e

    # create cloud sql database
    gcloud sql databases create "${APP_NAME}" --instance="${APP_NAME}-sql-${UUID}"

    # create cloud sql user
    gcloud sql users set-password postgres --instance "${APP_NAME}-sql-${UUID}" --password "postgres123" # TODO: hardcoded pw..
    
    # set permissions for Cloud SQL service account to access the GCS bucket
    SA_NAME=$(gcloud sql instances describe ${APP_NAME}-sql-${UUID} --project=${GCP_PROJECT} --format="value(serviceAccountEmailAddress)")
    gsutil acl ch -u ${SA_NAME}:R "gs://${GCP_BUCKET_NAME}";
    gsutil acl ch -u ${SA_NAME}:R "gs://${GCP_BUCKET_NAME}/init-db.sql";

    # import data into cloud sql
    gcloud sql import sql "${APP_NAME}-sql-${UUID}" \
        "gs://${GCP_BUCKET_NAME}/init-db.sql" \
        --database="${APP_NAME}" -q

    # create gke cluster, if it doesn't exist
    set +e
    gcloud container clusters describe "${APP_NAME}-cluster" > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        gcloud container clusters create "${APP_NAME}-cluster" \
            --zone "${GCP_COMPUTE_ZONE}" \
            --enable-autoscaling \
            --max-nodes=10 \
            --machine-type=n1-standard-4 \
            --no-enable-autoupgrade \
            --enable-ip-alias \
            --enable-stackdriver-kubernetes
    fi
    set -e

    # set gke cluster credentials for kubectl
    gcloud container clusters get-credentials "${APP_NAME}-cluster"

    # enable Cloud SQL Admin API
    gcloud services enable sqladmin.googleapis.com

    # create iam user for cloud proxy
    gcloud iam service-accounts create "sqlproxy-sa-${UUID}" --display-name "sqlproxy-sa-${UUID}"
    gcloud projects add-iam-policy-binding "${GCP_PROJECT}" \
        --member serviceAccount:"sqlproxy-sa-${UUID}@${GCP_PROJECT}.iam.gserviceaccount.com" \
        --role roles/cloudsql.client

    # create kubernetes secret from the user credentials
    gcloud iam service-accounts keys create key.json --iam-account "sqlproxy-sa-${UUID}@${GCP_PROJECT}.iam.gserviceaccount.com"
    kubectl create secret generic cloudsql-instance-credentials --from-file=credentials.json=key.json
    rm -rf key.json

    # TODO: db credentials as a secret instead hard coding
    # kubectl create secret generic cloudsql-db-credentials --from-literal=username=[DB_USER] --from-literal=password=[DB_PASS] --from-literal=dbname=[DB_NAME]

    ### backend

    # create iam user for backend so it can write to Cloud Logging
    gcloud iam service-accounts create "backend-sa-${UUID}" --display-name "backend-sa-${UUID}"
    gcloud projects add-iam-policy-binding "${GCP_PROJECT}" \
        --member serviceAccount:"backend-sa-${UUID}@${GCP_PROJECT}.iam.gserviceaccount.com" \
        --role roles/logging.logWriter

    # create kubernetes secret from the user credentials
    gcloud iam service-accounts keys create key.json --iam-account "backend-sa-${UUID}@${GCP_PROJECT}.iam.gserviceaccount.com"
    kubectl create secret generic cloudlogging-writer-credentials --from-file=credentials.json=key.json
    rm -rf key.json

    # build and push docker image to gcr
    [ ! -z $(docker images -q gcr.io/${GCP_PROJECT}/demo-app-backend:latest) ] || docker build -t "gcr.io/${GCP_PROJECT}/demo-app-backend:latest" "${SCRIPT_PATH}/backend/"
    docker push "gcr.io/${GCP_PROJECT}/demo-app-backend:latest"

    # get Cloud SQL instance connection name
    SQL_CONNECTION_NAME=$(gcloud sql instances describe "${APP_NAME}-sql-${UUID}" | grep connectionName | awk '{print $2}')
    
    # deploy backend to kubernetes
    sed -ie "s/SQL_CONNECTION_NAME/${SQL_CONNECTION_NAME}/g" kubernetes/backend/deployment.yaml
    sed -ie "s/GCP_PROJECT/${GCP_PROJECT}/g" kubernetes/backend/deployment.yaml
    kubectl apply -f kubernetes/backend/
    sed -ie "s/${SQL_CONNECTION_NAME}/SQL_CONNECTION_NAME/g" kubernetes/backend/deployment.yaml
    sed -ie "s/${GCP_PROJECT}/GCP_PROJECT/g" kubernetes/backend/deployment.yaml

    ### frontend

    # wait for backend service to be ready and set it as environmental variable for vue app
    set +e 
    BACKEND_EXTERNAL_IP=""
    while [ -z $BACKEND_EXTERNAL_IP ]; do
        echo "Waiting for backend external IP..."
        BACKEND_EXTERNAL_IP=$(kubectl get svc ${APP_NAME}-backend --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
        [ -z "$BACKEND_EXTERNAL_IP" ]
        sleep 10;
    done
    echo "VUE_APP_API_URL='http://${BACKEND_EXTERNAL_IP}:5000/api'" > "${SCRIPT_PATH}/frontend/.env"
    set -e
    
    # build and push frontend docker image to gcr
    docker build -t "gcr.io/${GCP_PROJECT}/demo-app-frontend:latest" "${SCRIPT_PATH}/frontend/"
    docker push "gcr.io/${GCP_PROJECT}/demo-app-frontend:latest"
    rm -rf "${SCRIPT_PATH}/frontend/.env"

    # deploy frontned to kubernetes
    sed -ie "s/GCP_PROJECT/${GCP_PROJECT}/g" kubernetes/frontend/deployment.yaml
    kubectl apply -f kubernetes/frontend/
    sed -ie "s/${GCP_PROJECT}/GCP_PROJECT/g" kubernetes/frontend/deployment.yaml
}


### "main"

set -e

if [ "$#" -ne 1 ]; then
  printf "Incorrect number of arguments!\n\nUsage:\n    ./deploy.sh GCP_PROJECT\n\nfor example:\n    ./deploy.sh example-project\n"
  exit 1
fi

# ensure we use correct path, so this script works from any path
SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# variables
GCP_PROJECT=$1
GCP_COMPUTE_REGION=$(gcloud config get-value compute/region 2> /dev/null)
GCP_COMPUTE_ZONE=$(gcloud config get-value compute/zone 2> /dev/null)
APP_NAME=demo-app
GCP_BUCKET_NAME="${GCP_PROJECT}-${APP_NAME}-temp-bucket"

# workaround:
#   Cloud SQL prevents using the same name for a week
#   and https://cloud.google.com/iam/docs/understanding-service-accounts#deleting_and_recreating_service_accounts
UUID=$(LC_ALL=C tr -dc 'a-z' </dev/urandom | head -c 13 ; echo) 

while true; do
    echo
    read -p "Do you want to (d)eploy or (u)ndeploy the demo-app? Press any other key to abort: " -n 1 -r
    echo

    case $REPLY in
        d)
            deploy
            exit 0
            ;;
        u)
            undeploy
            exit 0
            ;;
        *)
            echo "aborted"
            exit 0
            ;;
    esac
done

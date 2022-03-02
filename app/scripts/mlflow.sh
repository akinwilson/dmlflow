#!/bin/bash
set -x 

# NOTE!
# These env vars are being passed to the ecr task and into the serving container 
# Need to configure container to require these at runtime.
# that is: 
#        DB_ENV_VARS 
#        BUCKET_ID/NAME 
# need to be passed to this script, from the dockerfile. 

# -----> Solution:
#        build the dockerfile with push-to-ecr via local-provisioner, but pass vars 
#        building of the docker container 
# envsubst < db-s3-config.txt  


if [[ -z "${MLFLOW_ARTIFACT_URI}" ]]; then
    echo "MLFLOW_ARTIFACT_URI can not be set. Define default value as ./mlruns"
    export MLFLOW_ARTIFACT_URI="./mlruns"
fi

if [[ -z "${MLFLOW_ARTIFACT_DESTINATION}"]]; then
    echo "MLFLOW_ARTIFACT_DESTINATION has not been set"
    exit 0
fi 

if [[ -z "${MLFLOW_DB_DIALECT}" ]]; then
    export MLFLOW_DB_DIALECT="mysql+pymysql"
fi

if [[ -z "${MLFLOW_DB_USERNAME}" ]]; then
    export MLFLOW_DB_USERNAME="mlflow"
fi

if [[ -z "${MLFLOW_DB_PASSWORD}" ]]; then
    export MLFLOW_DB_PASSWORD="mlflow"
fi

if [[ -z "${MLFLOW_DB_DATABASE}" ]]; then
    export MLFLOW_DB_DATABASE="mlflow"
fi

if [[ -z "${MLFLOW_DB_PORT}" ]]; then
    export MLFLOW_DB_PORT=3306
fi

if [[ -z "${MLFLOW_BACKEND_URI}" ]]; then
    echo "MLFLOW_BACKEND_URI not set. Define default value based on other variables."
    export MLFLOW_BACKEND_URI=${MLFLOW_DB_DIALECT}://${MLFLOW_DB_USERNAME}:${MLFLOW_DB_PASSWORD}@${MLFLOW_DB_HOST}:${MLFLOW_DB_PORT}/${MLFLOW_DB_DATABASE}
fi

exec mlflow server \
    --host 0.0.0.0 \
    --port 5001 \
    --serve-artifacts \
    --artifacts-destination "${MLFLOW_ARTIFACT_DESTINATION}" \
    --backend-store-uri "${MLFLOW_BACKEND_URI}"

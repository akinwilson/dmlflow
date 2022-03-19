#!/bin/bash
set -x 
echo "Initialising Mlflow tracking server..."
echo ""

if [[ -z "${MLFLOW_ARTIFACT_URI}" ]]; then
    echo "MLFLOW_ARTIFACT_URI can not be set. Define default value as ./mlruns"
    export MLFLOW_ARTIFACT_URI="./mlruns"
fi

if [[ -z "${MLFLOW_BACKEND_URI}" ]]; then
    echo "MLFLOW_BACKEND_URI not set. Define default value based on other variables."
fi

exec mlflow server \
    --host 0.0.0.0 \
    --port 5001 \
    --serve-artifacts \
    --default-artifact-root "mlflow-artifacts:/" \
    --artifacts-destination ${MLFLOW_ARTIFACT_URI} \
    --backend-store-uri ${MLFLOW_BACKEND_URI}

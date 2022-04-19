#!/bin/bash
set -x
echo ""
echo "Initialising Mlflow tracking server..."
echo ""

exec mlflow server \
    --host 0.0.0.0 \
    --port 5001 \
    --serve-artifacts \
    --default-artifact-root "mlflow-artifacts:/" \
    --artifacts-destination ${MLFLOW_ARTIFACT_URI} \
    --backend-store-uri ${MLFLOW_BACKEND_URI}



#!/bin/bash
set -x

if [[ -z "${MLFLOW_TRACKING_USERNAME}" ]]; then
    export MLFLOW_TRACKING_USERNAME="mlflow"
fi

if [[ -z "${MLFLOW_TRACKING_PASSWORD}" ]]; then
    export MLFLOW_TRACKING_PASSWORD="mlflow"
fi

htpasswd -b -c /etc/nginx/.htpasswd ${MLFLOW_TRACKING_USERNAME} ${MLFLOW_TRACKING_PASSWORD}
exec nginx -g "daemon off;"
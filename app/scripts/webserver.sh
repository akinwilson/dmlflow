#!/bin/bash

set -x
echo ""
echo "Setting admin username and password for ngnix basic authentication..."
echo ""

htpasswd -b -c /etc/nginx/.htpasswd ${MLFLOW_TRACKING_USERNAME} ${MLFLOW_TRACKING_PASSWORD}
exec nginx -g "daemon off;"


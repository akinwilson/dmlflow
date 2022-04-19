#!/bin/bash
set -x 
echo ""
echo "Executing supervisor daemon ..."
echo ""
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

#!/bin/bash
set -x 

exec /usr/bin/supervisord -c /etc/supervisor/config.d/supervisord.conf

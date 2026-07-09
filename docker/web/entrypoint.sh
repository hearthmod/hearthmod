#!/bin/sh
set -e
# Start the web.py app under FastCGI where nginx expects it (127.0.0.1:9002),
# then run nginx in the foreground to keep the container alive.
echo "[web] Couchbase host: ${HM_COUCHBASE_HOST:-localhost}"
PYTHONUNBUFFERED=1 spawn-fcgi -d /opt/hm_web -a 127.0.0.1 -p 9002 -- \
    /usr/bin/python /opt/hm_web/app.py
exec /usr/local/nginx/sbin/nginx -g 'daemon off;'

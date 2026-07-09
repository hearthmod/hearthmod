#!/bin/sh
set -e
# stud terminates TLS on the frontend port and forwards plaintext to the
# lobbyserver backend. Defaults match the upstream config (front 1119,
# back 45678) but point the backend at the lobbyserver container.
cd /opt/hm/hm_stud
echo "[stud] TLS frontend 0.0.0.0:${STUD_FRONT_PORT:-1119} -> backend ${LOBBY_HOST:-lobbyserver}:${LOBBY_PORT:-45678}"
exec ./stud \
    -f "0.0.0.0,${STUD_FRONT_PORT:-1119}" \
    -b "${LOBBY_HOST:-lobbyserver},${LOBBY_PORT:-45678}" \
    cert/test.com.pem

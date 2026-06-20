#!/bin/bash
# Provision the Couchbase cluster, create the "hbs" bucket and restore the
# snapshot. Idempotent: safe to re-run (already-provisioned steps are ignored).
set -u

CB="${COUCHBASE_HOST:-couchbase}"
ADMIN="${COUCHBASE_ADMIN_USER:-Administrator}"
PASS="${COUCHBASE_ADMIN_PASSWORD:-password}"
BUCKET="hbs"
BUCKET_PASS="aci"        # matches the password the servers connect with
CLI="/opt/couchbase/bin/couchbase-cli"
CBRESTORE="/opt/couchbase/bin/cbrestore"

echo "[init] waiting for Couchbase REST at ${CB}:8091 ..."
until curl -s "http://${CB}:8091/pools" >/dev/null 2>&1; do sleep 2; done

echo "[init] provisioning cluster (idempotent) ..."
curl -s -X POST "http://${CB}:8091/node/controller/setupServices" \
     -d 'services=kv,index,n1ql' >/dev/null 2>&1 || true
curl -s -X POST "http://${CB}:8091/pools/default" \
     -d 'memoryQuota=512' -d 'indexMemoryQuota=256' >/dev/null 2>&1 || true
curl -s -X POST "http://${CB}:8091/settings/web" \
     -d "port=8091" -d "username=${ADMIN}" -d "password=${PASS}" >/dev/null 2>&1 || true

echo "[init] creating bucket '${BUCKET}' (idempotent) ..."
"$CLI" bucket-create \
    -c "${CB}:8091" -u "${ADMIN}" -p "${PASS}" \
    --bucket="${BUCKET}" --bucket-password="${BUCKET_PASS}" \
    --bucket-type=couchbase --bucket-ramsize=200 --bucket-replica=1 --wait \
    || echo "[init] bucket-create skipped (likely already exists)"

echo "[init] waiting for bucket to warm up ..."
sleep 10

echo "[init] restoring snapshot from /hm_database/hbs ..."
"$CBRESTORE" /hm_database/hbs "http://${CB}:8091" \
    -u "${ADMIN}" -p "${PASS}" \
    --bucket-source="${BUCKET}" --bucket-destination="${BUCKET}" \
    || echo "[init] WARN: cbrestore failed (bucket may already hold data) — continuing"

echo "[init] done."

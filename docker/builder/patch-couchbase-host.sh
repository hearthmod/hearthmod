#!/bin/sh
# Rewrite the hardcoded Couchbase host list  { "localhost" }  in a server's
# main.c so it honours the $HM_COUCHBASE_HOST env var at runtime (falling back
# to "localhost"). Required to split Couchbase into its own container.
#
# Usage: patch-couchbase-host.sh <path-to-main.c>
set -e

f="$1"
[ -f "$f" ] || { echo "ERROR: $f not found" >&2; exit 1; }

# getenv() needs stdlib.h
grep -q '#include <stdlib.h>' "$f" || sed -i '1i #include <stdlib.h>' "$f"

before=$(md5sum "$f" | cut -d' ' -f1)
sed -i 's/{ *"localhost" *}/{ getenv("HM_COUCHBASE_HOST") ? getenv("HM_COUCHBASE_HOST") : "localhost" }/' "$f"
after=$(md5sum "$f" | cut -d' ' -f1)

if [ "$before" = "$after" ]; then
    echo "ERROR: Couchbase host pattern '{ \"localhost\" }' not found in $f" >&2
    echo "       The source layout may have changed; update this patch." >&2
    exit 1
fi
echo "patched Couchbase host in $f"

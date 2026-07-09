# One-shot initializer: provisions the cluster, creates the "hbs" bucket and
# restores the database snapshot. Built FROM the Couchbase image so cbrestore /
# couchbase-cli are available and version-matched.
FROM couchbase:enterprise-4.5.0

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
        git curl ca-certificates \
 && git clone -b v0.1 https://github.com/farb3yonddriv3n/hm_database.git /hm_database \
 && rm -rf /var/lib/apt/lists/*

COPY docker/couchbase-init/init.sh /init.sh
RUN chmod +x /init.sh
ENTRYPOINT ["/init.sh"]

# Web UI: bundled nginx (hm_nginx) in front of the web.py app (hm_web) served
# over FastCGI via spawn-fcgi. Ubuntu 16.04 + python2, matching host_ctl.
FROM ubuntu:16.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        git ca-certificates build-essential cmake \
        python python-pip python-dev \
        libssl-dev zlib1g-dev libpcre3-dev libev-dev libevent-dev \
        spawn-fcgi \
    && rm -rf /var/lib/apt/lists/*

# libcouchbase 2.9.0 — the python couchbase SDK links against it
RUN git clone https://github.com/couchbase/libcouchbase.git /tmp/lcb \
 && cd /tmp/lcb && git checkout 2.9.0 && cmake . && make && make install && ldconfig \
 && rm -rf /tmp/lcb

# python deps (pinned couchbase 2.2.4 as in host_ctl_ubuntu.sh).
# flup MUST be 1.0.2 — the python2 build; newer flup imports _dummy_thread
# (a python3 module name) and crashes the FastCGI worker on python2.
RUN pip install --no-cache-dir "setuptools<45" \
 && pip install --no-cache-dir web.py==0.38 flup==1.0.2 couchbase==2.2.4

WORKDIR /opt
RUN git clone -b v0.1 https://github.com/farb3yonddriv3n/hm_web.git   hm_web \
 && git clone        https://github.com/farb3yonddriv3n/hm_nginx.git  hm_nginx

# build the bundled nginx; point the /static/ root at our hm_web checkout.
# Also pass HTTP_COOKIE to FastCGI — the hand-rolled fastcgi_param block omits
# it (and nginx doesn't auto-forward request headers for FastCGI), which breaks
# web.py session persistence (login wouldn't stick).
RUN cd hm_nginx \
 && sed "s@/usr/local/web@/opt/hm_web@g" conf/hm_nginx.conf > conf/nginx.conf \
 && sed -i '/fastcgi_pass 127.0.0.1:9002;/i\        fastcgi_param HTTP_COOKIE $http_cookie;' conf/nginx.conf \
 && ./configure && make && make install

# make the Couchbase host configurable (app.py:48 hardcodes localhost)
RUN sed -i "s@'couchbase://localhost/hbs'@'couchbase://%s/hbs' % os.environ.get('HM_COUCHBASE_HOST','localhost')@" hm_web/app.py \
 && grep -q "os.environ.get('HM_COUCHBASE_HOST'" hm_web/app.py

# drop the monolith's self-launch of a sibling sunwell checkout — sunwell is
# its own container here (app.py:490: os.system("cd ../hm_sunwell/examples ..."))
RUN sed -i '/hm_sunwell\/examples && npm start/d' hm_web/app.py

# fix login/signup: the AJAX handlers in base.html (the global layout) omit
# `url`, so jQuery POSTs to the current page instead of /signin (/signup) —
# login only worked when already on the /signin page. Pin the endpoints.
RUN perl -0777 -i -pe 's/(#signin"\)\.click\(function\(\)\s*\{.*?jQuery\.ajax\(\{\s*\n\s*type:\s*"POST",)/$1\n            url: "\/signin",/s' hm_web/templates/base.html \
 && perl -0777 -i -pe 's/(#signup"\)\.click\(function\(\)\s*\{.*?jQuery\.ajax\(\{\s*\n\s*type:\s*"POST",)/$1\n            url: "\/signup",/s' hm_web/templates/base.html \
 && grep -q 'url: "/signin"' hm_web/templates/base.html \
 && grep -q 'url: "/signup"' hm_web/templates/base.html

# wire card rendering to the sunwell container: write the carddata to the shared
# /shared volume and trigger sunwell by service name instead of localhost.
RUN sed -i 's@"../hm_sunwell/examples/carddata"@"/shared/carddata"@' hm_web/generate.py \
 && sed -i 's@urllib2.urlopen("http://localhost:8081/")@urllib2.urlopen(os.environ.get("SUNWELL_URL","http://sunwell:8081/"))@' hm_web/generate.py \
 && grep -q "/shared/carddata" hm_web/generate.py

COPY docker/web/entrypoint.sh /usr/local/bin/web-entrypoint.sh
RUN chmod +x /usr/local/bin/web-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/web-entrypoint.sh"]

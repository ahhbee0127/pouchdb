#!/usr/bin/env bash

if [ "$SERVER" = "couchdb-master" ]; then
  # Install CouchDB Master
  docker run -d -p 3001:5984 klaemo/couchdb:2.0-dev@sha256:336fd3d9a89475205fc79b6a287ee550d258fac3b62c67b8d13b8e66c71d228f --with-haproxy \
    --with-admin-party-please -n 1
  COUCH_PORT=3001
elif [ "$SERVER" = "pouchdb-server-stable" ]; then
  npm install pouchdb-server
  ./node_modules/.bin/pouchdb-server -p 3002 --in-memory
  COUCH_PORT=3002
else
  # Install CouchDB Stable
  docker run -d -p 3000:5984 klaemo/couchdb:1.6.1
  COUCH_PORT=3000
fi

# wait for couchdb to start, add cors
npm install add-cors-to-couchdb
while [ '200' != $(curl -s -o /dev/null -w %{http_code} http://127.0.0.1:${COUCH_PORT}) ]; do
  echo waiting for couch to load... ;
  sleep 1;
done
./node_modules/.bin/add-cors-to-couchdb http://127.0.0.1:${COUCH_PORT}

#!/bin/bash

set -euo pipefail

BLAZEGRAPH_MEMORY=${BLAZEGRAPH_MEMORY:-4g}

WIKIDATA_SERVICE_VERSION=0.2.5

TARGET=$(readlink -m "$1")

shift

FILES_OR_DIRS="$@"

if [ ! -d lib ]; then
    echo "Downloading Wikidata BlazeGraph service ${WIKIDATA_SERVICE_VERSION} ..."
    curl -sL https://search.maven.org/remotecontent?filepath=org/wikidata/query/rdf/service/${WIKIDATA_SERVICE_VERSION}/service-${WIKIDATA_SERVICE_VERSION}-dist.zip > wikidata-service.zip
    unzip -j wikidata-service.zip "service-${WIKIDATA_SERVICE_VERSION}/blazegraph-service-${WIKIDATA_SERVICE_VERSION}.war" -d .
    rm wikidata-service.zip
    unzip -j blazegraph-service-${WIKIDATA_SERVICE_VERSION}.war "WEB-INF/lib/*" -d lib
    rm blazegraph-service-${WIKIDATA_SERVICE_VERSION}.war
fi

CONFIG=$(cat config.properties | sed -e "s|AbstractJournal.file=.*|AbstractJournal.file=$TARGET|")

# NOTE: Wikidata service uses logback, not log4j ...

LC_ALL=en_US.UTF8 java -server -XX:+UseG1GC -Xmx$BLAZEGRAPH_MEMORY \
    -cp "lib/*" \
    -Dlogback.configurationFile=`pwd`/logback.xml \
    -Dcom.bigdata.rdf.store.DataLoader.flush=false \
    -Dcom.bigdata.rdf.store.DataLoader.bufferCapacity=100000 \
    -Dcom.bigdata.rdf.store.DataLoader.queueCapacity=10 \
    com.bigdata.rdf.store.DataLoader \
    -verbose \
    -format N-Triples \
    -namespace wdq \
    <(echo "$CONFIG") \
    $FILES_OR_DIRS

#!/bin/sh

BLAZEGRAPH_PORT=9999
BLAZEGRAPH_MEMORY=${BLAZEGRAPH_MEMORY:-4g}
BLAZEGRAPH_NATIVE_MEMORY=${BLAZEGRAPH_NATIVE_MEMORY:-4g}
BLAZEGRAPH_TEMP_DIR=${BLAZEGRAPH_TEMP_DIR:-/tmp}

WIKIDATA_MWSERVICES=$(echo service-*/services.json)

# Q-id of the default globe
DEFAULT_GLOBE=0

JAVA_OPTS="-server -XX:+UseG1GC -Xmx$BLAZEGRAPH_MEMORY -XX:MaxDirectMemorySize=$BLAZEGRAPH_NATIVE_MEMORY \
  -Dlog4j.configuration=file:log4j.properties \
  -Dcom.bigdata.rdf.sail.webapp.ConfigParams.propertyFile=/config.properties \
  -Djava.io.tmpdir=$BLAZEGRAPH_TEMP_DIR \
  -Dcom.bigdata.rdf.sparql.ast.QueryHints.analytic=true \
  -Dcom.bigdata.rdf.sparql.ast.QueryHints.analyticMaxMemoryPerQuery=1073741824 \
  -Dorg.eclipse.jetty.server.Request.maxFormContentSize=-1 \
  -DASTOptimizerClass=org.wikidata.query.rdf.blazegraph.WikibaseOptimizers \
  -Dorg.wikidata.query.rdf.blazegraph.inline.literal.WKTSerializer.noGlobe=$DEFAULT_GLOBE \
  -Dorg.wikidata.query.rdf.blazegraph.mwapi.MWApiServiceFactory.config=$WIKIDATA_MWSERVICES \
  -Dcom.bigdata.rdf.sail.webapp.client.HttpClientConfigurator=org.wikidata.query.rdf.blazegraph.ProxiedHttpConnectionFactory \
  "

java $JAVA_OPTS \
  -jar service-*/jetty-runner*.jar \
  --host 0.0.0.0 \
  --port $BLAZEGRAPH_PORT \
  --path / \
  service-*/blazegraph-service-*.war

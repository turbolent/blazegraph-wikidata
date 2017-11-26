FROM openjdk:8-jdk-alpine

ENV BLAZEGRAPH_DATA_DIR /data
ENV BLAZEGRAPH_MEMORY 4g
ENV BLAZEGRAPH_NATIVE_MEMORY 3g
ENV WIKIDATA_SERVICE_VERSION 0.2.5

RUN mkdir $BLAZEGRAPH_DATA_DIR
VOLUME $BLAZEGRAPH_DATA_DIR

# add curl for health checks
RUN apk --no-cache add curl

RUN curl -sL https://search.maven.org/remotecontent?filepath=org/wikidata/query/rdf/service/$WIKIDATA_SERVICE_VERSION/service-$WIKIDATA_SERVICE_VERSION-dist.zip > /wikidata-service.zip && \
    unzip /wikidata-service.zip && \
    rm wikidata-service.zip

ADD run.sh /
ADD config.properties /config.properties

CMD "/run.sh"

ADD log4j.properties /

EXPOSE 9999

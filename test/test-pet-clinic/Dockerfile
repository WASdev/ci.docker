
ARG IMAGE=ibmcom/websphere-liberty:kernel-java8-openj9-ubi
FROM ${IMAGE} as staging

COPY --chown=1001:0 server.xml /config
COPY --chown=1001:0 spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar /staging/myFatApp.jar

RUN features.sh \
 && springBootUtility thin \
 --sourceAppPath=/staging/myFatApp.jar \
 --targetThinAppPath=/staging/myThinApp.jar \
 --targetLibCachePath=/staging/lib.index.cache

RUN configure.sh

FROM ${IMAGE}

COPY --from=staging /config/server.xml /config/server.xml

RUN features.sh

COPY --from=staging /staging/lib.index.cache /lib.index.cache
RUN mkdir /config/dropins/spring 
COPY --from=staging /staging/myThinApp.jar /config/dropins/spring/myThinApp.jar

RUN configure.sh


ARG IMAGE=ibmcom/websphere-liberty:full-java8-openj9-ubi
FROM ${IMAGE} as staging

COPY --chown=1001:0 spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar /staging/myFatApp.jar

RUN springBootUtility thin \
 --sourceAppPath=/staging/myFatApp.jar \
 --targetThinAppPath=/staging/myThinApp.jar \
 --targetLibCachePath=/staging/lib.index.cache

FROM ${IMAGE}
COPY --from=staging /staging/lib.index.cache /lib.index.cache
COPY --from=staging /staging/myThinApp.jar /config/dropins/spring/myThinApp.jar

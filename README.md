# WebSphere Application Server Liberty Profile and Docker [![Build Status](https://travis-ci.org/WASdev/ci.docker.svg?branch=master)](https://travis-ci.org/WASdev/ci.docker)

This project contains the Dockerfiles for [WebSphere Application Server Liberty](https://hub.docker.com/_/websphere-liberty/). 

## Building an application image 

According to Docker's best practices you should create a new image (FROM websphere-liberty) which adds a single application and the corresponding configuration. You should avoid configuring the image manually (after it started) via Admin Console or wsadmin (unless it is for debugging purposes) because such changes won't be present if you spawn a new container from the image.

Even if you docker save the manually configured container, the steps to reproduce the image from `websphere-liberty` will be lost and you will hinder your ability to update that image.

The key point to take-away from the sections below is that your application Dockerfile should always follow a pattern similar to:

```dockerfile
FROM websphere-liberty:kernel

# Add my app and config
COPY --chown=1001:0  Sample1.war /config/dropins/
COPY --chown=1001:0  server.xml /config/

# Optional functionality
ARG HZ_SESSION_CACHE=true
ARG MP_MONITORING=true

# This script will add the requested XML snippets and grow image to be fit-for-purpose
RUN /configure.sh
```

This will result in a Docker image that has your application and configuration pre-loaded, which means you can spawn new fully-configured containers at any time.

## Enterprise Functionality (under construction)

This section describes the optional enterprise functionality that can be enabled via the Dockerfile during `build` time, by setting particular build-arguments (`ARG`) and calling `RUN /configure.sh`.  Each of these options trigger the inclusion of specific configuration via XML snippets, described below:

* `HTTP_ENDPOINT` 
  *  Decription: Add configuration properties for an HTTP endpoint.
  *  XML Snippet Location: [http-ssl-endpoint.xml](ga/18.0.0.4/kernel/helpers/build/configuration_snippets/http-ssl-endpoint.xml) when SSL is enabled. Otherwise [http-endpoint.xml](ga/18.0.0.4/kernel/helpers/build/configuration_snippets/http-endpoint.xml)
* `MP_HEALTH_CHECK`
  *  Decription: Check the health of the environment using Liberty feature `mpHealth-1.0` (implements [MicroProfile Health](https://microprofile.io/project/eclipse/microprofile-health)).
  *  XML Snippet Location: [mp-health-check.xml](ga/18.0.0.4/kernel/helpers/build/configuration_snippets/mp-health-check.xml)
* `MP_MONITORING` 
  *  Decription: Monitor the server runtime environment and application metrics by using Liberty features `mpMetrics-1.1` (implements [Microprofile Metrics](https://microprofile.io/project/eclipse/microprofile-metrics)) and `monitor-1.0`.
  *  XML Snippet Location: [mp-monitoring.xml](ga/18.0.0.4/kernel/helpers/build/configuration_snippets/mp-monitoring.xml)
* `SSL` 
  *  Decription: Enable SSL in Liberty by adding the `ssl-1.0` feature.
  *  XML Snippet Location:  [ssl.xml](ga/18.0.0.4/kernel/helpers/build/configuration_snippets/ssl.xml)


### Session Caching

The Liberty session caching feature builds on top of an existing technology called JCache (JSR 107), which provides an API for distributed in-memory caching. There are several providers of JCache implementations. One example is Hazelcast In-Memory Data Grid. Enabling Hazelcast session caching retrieves the Hazelcast client libraries from the `hazelcast/hazelcast` Docker image, configures Hazelcast by copying a sample hazelcast.xml, and configures the Liberty server feature sessionCache-1.0 by including a sample server.xml. By default, the [Hazelcast Discovery Plugin](https://github.com/hazelcast/hazelcast-kubernetes) for Kubernetes will auto-discover its peers within the same Kubernetes namespace. To enable this functionality, the Docker image author can include the following Dockerfile snippet, and choose from either client-server or embedded [topology](https://docs.hazelcast.org/docs/latest-development/manual/html/Hazelcast_Overview/Hazelcast_Topology.html).

```dockerfile
### Hazelcast Session Caching ###
# Copy the Hazelcast libraries from the Hazelcast Docker image
COPY --from=hazelcast/hazelcast --chown=1001:0 /opt/hazelcast/*.jar /opt/ibm/wlp/usr/shared/resources/hazelcast/

# Instruct configure.sh to copy the client topology hazelcast.xml
ARG HZ_SESSION_CACHE=client

# Instruct configure.sh to copy the embedded topology hazelcast.xml and set the required system property
#ARG HZ_SESSION_CACHE=embedded
#ENV JAVA_TOOL_OPTIONS="-Dhazelcast.jcache.provider.type=server ${JAVA_TOOL_OPTIONS}"

## This script will add the requested XML snippets and grow image to be fit-for-purpose
RUN configure.sh
```


# Issues and Contributions

For issues relating specifically to the Dockerfiles and scripts, please use the [GitHub issue tracker](https://github.com/WASdev/ci.docker/issues). For more general issue relating to IBM WebSphere Application Server Liberty you can [get help](https://developer.ibm.com/wasdev/help/) through the WASdev community or, if you have production licenses for WebSphere Application Server, via the usual support channels. We welcome contributions following [our guidelines](https://github.com/WASdev/wasdev.github.io/blob/master/CONTRIBUTING.md).

# License

The Dockerfiles and associated scripts found in this project are licensed under the [Apache License 2.0](LICENSE).

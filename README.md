# WebSphere Application Server Liberty Profile and Docker [![Build Status](https://travis-ci.org/WASdev/ci.docker.svg?branch=master)](https://travis-ci.org/WASdev/ci.docker)

## Docker Hub images

There are two different WebSphere Liberty Docker image sets available on Docker Hub:

1. **Official Images**:  available [here](https://hub.docker.com/_/websphere-liberty), these are re-build automatically anytime something changes in the layers below, and updated with new WebSphere Liberty binaries as they become available (generally every 4 weeks). There are tags with Ubuntu and different combinations of Java versions.

1. **Community Images**: available [here](https://hub.docker.com/r/ibmcom/websphere-liberty), these are images using Red Hat's [Universal Base Image](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image) as the Operating System and IBM's Small Footprint Java as the JRE.    


## Building an application image

According to Docker's best practices you should create a new image (FROM websphere-liberty) which adds a single application and the corresponding configuration. You should avoid configuring the image manually, after it started (unless it is for debugging purposes), because such changes won't be present if you spawn a new container from the image.

Even if you docker save the manually configured container, the steps to reproduce the image from `websphere-liberty` will be lost and you will hinder your ability to update that image.

The key point to take-away from the sections below is that your application Dockerfile should always follow a pattern similar to:

```dockerfile
FROM websphere-liberty:kernel

# Add my app and config
COPY --chown=1001:0  Sample1.war /config/dropins/
COPY --chown=1001:0  server.xml /config/

# Optional functionality
ARG SSL=true
ARG MP_MONITORING=true

# Add interim fixes (optional)
COPY --chown=1001:0  interim-fixes /opt/ibm/fixes/

# This script will add the requested XML snippets, grow image to be fit-for-purpose and apply interim fixes
RUN configure.sh
```

This will result in a Docker image that has your application and configuration pre-loaded, which means you can spawn new fully-configured containers at any time.

## Optional Enterprise Functionality

This section describes the optional enterprise functionality that can be enabled via the Dockerfile during `build` time, by setting particular argument (`ARG`) or environment variable (`ENV`) and calling `RUN configure.sh`.  Each of these options trigger the inclusion of specific configuration via XML snippets, described below:

* `HTTP_ENDPOINT`
  *  Decription: Add configuration properties for an HTTP endpoint.
  *  XML Snippet Location: [http-ssl-endpoint.xml](ga/latest/kernel/helpers/build/configuration_snippets/http-ssl-endpoint.xml) when SSL is enabled. Otherwise [http-endpoint.xml](ga/latest/kernel/helpers/build/configuration_snippets/http-endpoint.xml)
* `MP_HEALTH_CHECK`
  *  Decription: Check the health of the environment using Liberty feature `mpHealth-1.0` (implements [MicroProfile Health](https://microprofile.io/project/eclipse/microprofile-health)).
  *  XML Snippet Location: [mp-health-check.xml](ga/latest/kernel/helpers/build/configuration_snippets/mp-health-check.xml)
* `MP_MONITORING`
  *  Decription: Monitor the server runtime environment and application metrics by using Liberty features `mpMetrics-1.1` (implements [Microprofile Metrics](https://microprofile.io/project/eclipse/microprofile-metrics)) and `monitor-1.0`.
  *  XML Snippet Location: [mp-monitoring.xml](ga/latest/kernel/helpers/build/configuration_snippets/mp-monitoring.xml)
  *  Note: With this option, `/metrics` endpoint is configured without authentication to support the environments that do not yet support scraping secured endpoints.
* `TLS` or `SSL` (SSL is being deprecated)
  *  Decription: Enable Transport Security in Liberty by adding the `transportSecurity-1.0` feature (includes support for SSL).
  *  XML Snippet Location:  [keystore.xml](ga/latest/kernel/helpers/build/configuration_snippets/keystore.xml).
* `IIOP_ENDPOINT`
  *  Decription: Add configuration properties for an IIOP endpoint.
  *  XML Snippet Location: [iiop-ssl-endpoint.xml](ga/latest/kernel/helpers/build/configuration_snippets/iiop-ssl-endpoint.xml) when SSL is enabled. Otherwise, [iiop-endpoint.xml](ga/latest/kernel/helpers/build/configuration_snippets/iiop-endpoint.xml).
  *  Note: If using this option, `env.IIOP_ENDPOINT_HOST` environment variable should be set to the server's host. See [IIOP endpoint configuration](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.liberty.autogen.base.doc/ae/rwlp_config_orb.html#iiopEndpoint) for more details.
* `JMS_ENDPOINT`
  *  Decription: Add configuration properties for an JMS endpoint.
  *  XML Snippet Location: [jms-ssl-endpoint.xml](ga/latest/kernel/helpers/build/configuration_snippets/jms-ssl-endpoint.xml) when SSL is enabled. Otherwise, [jms-endpoint.xml](ga/latest/kernel/helpers/build/configuration_snippets/jms-endpoint.xml)
* `OIDC`
  *  Decription: Enable OpenIdConnect Client function by adding the `openidConnectClient-1.0` feature.
  *  XML Snippet Location: [oidc.xml](ga/latest/kernel/helpers/build/configuration_snippets/oidc.xml)
* `OIDC_CONFIG`
  *  Decription: Enable OpenIdConnect Client configuration to be read from environment variables.  
  *  XML Snippet Location: [oidc-config.xml](ga/latest/kernel/helpers/build/configuration_snippets/oidc-config.xml)
  *  Note: The following variables will be read:  OIDC_CLIENT_ID, OIDC_CLIENT_SECRET, OIDC_DISCOVERY_URL.  
* `HZ_SESSION_CACHE`
  *  Decription: Enable the persistence of HTTP sessions using JCache by adding the `sessionCache-1.0` feature.
  *  XML Snippet Location: [hazelcast-sessioncache.xml](ga/latest/kernel/helpers/build/configuration_snippets/hazelcast-sessioncache.xml)


### Session Caching

The Liberty session caching feature builds on top of an existing technology called JCache (JSR 107), which provides an API for distributed in-memory caching. There are several providers of JCache implementations. One example is [Hazelcast In-Memory Data Grid](https://hazelcast.org/). Enabling Hazelcast session caching retrieves the Hazelcast client libraries from the [hazelcast/hazelcast](https://hub.docker.com/r/hazelcast/hazelcast/) Docker image, configures Hazelcast by copying a sample [hazelcast.xml](ga/latest/kernel/helpers/build/configuration_snippets/), and configures the Liberty server feature [sessionCache-1.0](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/twlp_admin_session_persistence_jcache.html) by including the XML snippet [hazelcast-sessioncache.xml](ga/latest/kernel/helpers/build/configuration_snippets/hazelcast-sessioncache.xml). By default, the [Hazelcast Discovery Plugin for Kubernetes](https://github.com/hazelcast/hazelcast-kubernetes) will auto-discover its peers within the same Kubernetes namespace. To enable this functionality, the Docker image author can include the following Dockerfile snippet, and choose from either client-server or embedded [topology](https://docs.hazelcast.org/docs/latest-development/manual/html/Hazelcast_Overview/Hazelcast_Topology.html).

```dockerfile
### Hazelcast Session Caching ###
# Copy the Hazelcast libraries from the Hazelcast Docker image
COPY --from=hazelcast/hazelcast --chown=1001:0 /opt/hazelcast/lib/*.jar /opt/ibm/wlp/usr/shared/resources/hazelcast/

# Instruct configure.sh to copy the client topology hazelcast.xml
ARG HZ_SESSION_CACHE=client

# Instruct configure.sh to copy the embedded topology hazelcast.xml and set the required system property
#ARG HZ_SESSION_CACHE=embedded
#ENV JAVA_TOOL_OPTIONS="-Dhazelcast.jcache.provider.type=server ${JAVA_TOOL_OPTIONS}"

## This script will add the requested XML snippets and grow image to be fit-for-purpose
RUN configure.sh
```

### Applying interim fixes

This section describes the process to apply interim fixes via the Dockerfile during `build` time, by adding the interim fix JAR files to `/opt/ibm/fixes` directory and calling `RUN configure.sh`. Interim fixes recommended by IBM, such as to resolve security vulnerabilities, are also included in the same directory.

Ensure that all features needed by your applications, apart from the ones that will be automatically added for the [enterprise functionalities](#enterprise-functionality) you selected, are specified prior to calling `RUN configure.sh`, since interim fixes should only be applied once needed features are installed.

```dockerfile
# Add interim fixes (optional)
COPY --chown=1001:0  interim-fixes /opt/ibm/fixes/

# This script will add the requested XML snippets, grow image to be fit-for-purpose and apply interim fixes
RUN configure.sh
```

### Installing Liberty Features from local repository (19.0.0.8+)

This section describes very simple way to speed up feature installation during builds of your images

Using `FEATURE_REPO_URL` build argument it is possible to provide a link to a feature repo zip file 
containing all the features. You will also need to make sure to call `RUN configure.sh` in your Dockerfile

`docker build --build-arg FEATURE_REPO_URL="http://wlprepos:8080/19.0.0.x/repo.zip"`

You can also set it through Dockerfile 

```dockerfile
FROM websphere-liberty:kernel
ARG FEATURE_REPO_URL=http://wlprepos:8080/19.0.0.x/repo.zip
RUN configure.sh
```

The repository files can be downloaded from [Fix Central](https://www-945.ibm.com/support/fixcentral). 

Note: This feature requires a `curl ` command to be in the docker image.
Some base images do not provide `curl`. You can add it before calling `confiure.sh` this way:

```dockerfile
FROM websphere-liberty:kernel
USER root
RUN apt-get update && apt-get install -y curl
USER 1001
ARG FEATURE_REPO_URL=http://wlprepos:8080/19.0.0.x/repo.zip
RUN configure.sh
```

To be able to host these on-premises one of the easiest solutions could be using `nginx` docker image

`docker run --name repo-host -v /repo-host:/usr/share/nginx/html:ro -p 8080:80 -d nginx`

You can mount and serve multiple zip files using a docker volume mount, for example repo-host folder mounted from host to nginx container above.

You can place each zip archive in versioned folders, for example repo-host/${LIBERTY_VERSION}/repo.zip

You will need a hostname/IP and mapped port to generate `FEATURE_REPO_URL`, for example above port 8080 is used.

# Issues and Contributions

For issues relating specifically to the Dockerfiles and scripts, please use the [GitHub issue tracker](https://github.com/WASdev/ci.docker/issues). For more general issue relating to IBM WebSphere Application Server Liberty you can [get help](https://developer.ibm.com/wasdev/help/) through the WASdev community or, if you have production licenses for WebSphere Application Server, via the usual support channels. We welcome contributions following [our guidelines](https://github.com/WASdev/wasdev.github.io/blob/master/CONTRIBUTING.md).

# License

The Dockerfiles and associated scripts found in this project are licensed under the [Apache License 2.0](LICENSE).

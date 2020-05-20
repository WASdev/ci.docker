# WebSphere Application Server Liberty and Containers [![Build Status](https://travis-ci.org/WASdev/ci.docker.svg?branch=master)](https://travis-ci.org/WASdev/ci.docker)

## Container images

* Our recommended set uses Red Hat's [Universal Base Image](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image) as the Operating System and are re-built daily.  They can be found on [Docker Hub](https://hub.docker.com/r/ibmcom/websphere-libert) or [IBM Cloud](https://cloud.ibm.com/docs/services/Registry?topic=RegistryImages-ibmliberty).
* Another set, using Ubuntu as the Operating System can be found [here](https://hub.docker.com/_/websphere-liberty).  These are re-built automatically anytime something changes in the layers below.


## Building an application image

According to Docker's best practices you should create a new image (FROM ibmcom/websphere-liberty) which adds a single application and the corresponding configuration. You should avoid configuring the image manually, after it started (unless it is for debugging purposes), because such changes won't be present if you spawn a new container from the image.

Even if you docker save the manually configured container, the steps to reproduce the image from `websphere-liberty` will be lost and you will hinder your ability to update that image.

The key point to take-away from the sections below is that your application Dockerfile should always follow a pattern similar to:

```dockerfile
FROM ibmcom/websphere-liberty:kernel-java8-openj9-ubi

# Add my app and config
COPY --chown=1001:0  Sample1.war /config/dropins/
COPY --chown=1001:0  server.xml /config/

# Add interim fixes (optional)
COPY --chown=1001:0  interim-fixes /opt/ibm/fixes/

# Default setting for the verbose option
ARG VERBOSE=false

# This script will add the requested XML snippets, grow image to be fit-for-purpose and apply interim fixes
RUN configure.sh
```

This will result in a Docker image that has your application and configuration pre-loaded, which means you can spawn new fully-configured containers at any time.

## Optional Enterprise Functionality

This section describes the optional enterprise functionality that can be enabled via the Dockerfile during `build` time, by setting particular argument (`ARG`) or environment variable (`ENV`) and calling `RUN configure.sh`.  Each of these options trigger the inclusion of specific configuration via XML snippets (except for `VERBOSE`), described below:

* `HTTP_ENDPOINT`
  *  Description: Add configuration properties for an HTTP endpoint.
  *  XML Snippet Location: [http-ssl-endpoint.xml](ga/latest/kernel/helpers/build/configuration_snippets/http-ssl-endpoint.xml) when SSL is enabled. Otherwise [http-endpoint.xml](ga/latest/kernel/helpers/build/configuration_snippets/http-endpoint.xml)
* `MP_HEALTH_CHECK`
  *  Description: Check the health of the environment using Liberty feature `mpHealth-1.0` (implements [MicroProfile Health](https://microprofile.io/project/eclipse/microprofile-health)).
  *  XML Snippet Location: [mp-health-check.xml](ga/latest/kernel/helpers/build/configuration_snippets/mp-health-check.xml)
* `MP_MONITORING`
  *  Description: Monitor the server runtime environment and application metrics by using Liberty features `mpMetrics-1.1` (implements [Microprofile Metrics](https://microprofile.io/project/eclipse/microprofile-metrics)) and `monitor-1.0`.
  *  XML Snippet Location: [mp-monitoring.xml](ga/latest/kernel/helpers/build/configuration_snippets/mp-monitoring.xml)
  *  Note: With this option, `/metrics` endpoint is configured without authentication to support the environments that do not yet support scraping secured endpoints.
* `TLS` or `SSL` (SSL is being deprecated)
  *  Description: Enable Transport Security in Liberty by adding the `transportSecurity-1.0` feature (includes support for SSL).
  *  XML Snippet Location:  [keystore.xml](ga/latest/kernel/helpers/build/configuration_snippets/keystore.xml).
* `IIOP_ENDPOINT`
  *  Description: Add configuration properties for an IIOP endpoint.
  *  XML Snippet Location: [iiop-ssl-endpoint.xml](ga/latest/kernel/helpers/build/configuration_snippets/iiop-ssl-endpoint.xml) when SSL is enabled. Otherwise, [iiop-endpoint.xml](ga/latest/kernel/helpers/build/configuration_snippets/iiop-endpoint.xml).
  *  Note: If using this option, `env.IIOP_ENDPOINT_HOST` environment variable should be set to the server's host. See [IIOP endpoint configuration](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.liberty.autogen.base.doc/ae/rwlp_config_orb.html#iiopEndpoint) for more details.
* `JMS_ENDPOINT`
  *  Description: Add configuration properties for an JMS endpoint.
  *  XML Snippet Location: [jms-ssl-endpoint.xml](ga/latest/kernel/helpers/build/configuration_snippets/jms-ssl-endpoint.xml) when SSL is enabled. Otherwise, [jms-endpoint.xml](ga/latest/kernel/helpers/build/configuration_snippets/jms-endpoint.xml)
* `OIDC`
  *  Description: Enable OpenIdConnect Client function by adding the `openidConnectClient-1.0` feature.
  *  XML Snippet Location: [oidc.xml](ga/latest/kernel/helpers/build/configuration_snippets/oidc.xml)
* `OIDC_CONFIG`
  *  Description: Enable OpenIdConnect Client configuration to be read from environment variables.
  *  XML Snippet Location: [oidc-config.xml](ga/latest/kernel/helpers/build/configuration_snippets/oidc-config.xml)
  *  Note: The following variables will be read:  OIDC_CLIENT_ID, OIDC_CLIENT_SECRET, OIDC_DISCOVERY_URL.
* `HZ_SESSION_CACHE`
  *  Description: Enable the persistence of HTTP sessions using JCache by adding the `sessionCache-1.0` feature.
  *  XML Snippet Location: [hazelcast-sessioncache.xml](ga/latest/kernel/helpers/build/configuration_snippets/hazelcast-sessioncache.xml)
*  `VERBOSE`
  * Description: When set to `true` it outputs the commands and results to stdout from `configure.sh`. Otherwise, default setting is `false` and `configure.sh` is silenced.

## Security 

Single Sign-On can be optionally configured by adding Liberty server variables in an xml file, by passing environment variables (less secure),
or by passing Liberty server variables in through the Liberty operator. See [SECURITY.md](SECURITY.md).

## OpenJ9 Shared Class Cache (SCC)

OpenJ9's SCC allows the VM to store Java classes in an optimized form that can be loaded very quickly, JIT compiled code, and profiling data. Deploying an SCC file together with your application can significantly improve start-up time. The SCC can also be shared by multiple VMs, thereby reducing total memory consumption.

WebSphere Liberty Docker images contain an SCC and (by default) add your application's specific data to the SCC at image build time when your Dockerfile invokes `RUN configure.sh`.

This feature can be controlled via the following variables:

* `OPENJ9_SCC` (environment variable)
  *  Description: If `"true"`, cache application-specific in an SCC and include it in the image. A new SCC will be created if needed, otherwise data will be added to the existing SCC.
  *  Default: `"true"`.

## Logging

It is important to be able to observe the logs emitted by WebSphere Liberty when it is running in docker. A best practice method would be to emit the logs in JSON and to then consume it with a logging stack of your choice.

Configure your WebSphere Liberty docker image to emit JSON formatted logs to the console/standard-out with your selection of liberty logging events by providing the following environment variables to your WebSphere Liberty DockerFile.

For example:
```
//This example illustrates the use of all available logging sources.
ENV WLP_LOGGING_CONSOLE_FORMAT=JSON
ENV WLP_LOGGING_CONSOLE_LOGLEVEL=info
ENV WLP_LOGGING_CONSOLE_SOURCE=message,trace,accessLog,ffdc,audit
```

These environment variables can be set during container invocation as well. This can be achieved by using the docker command's '-e' option to pass in an environment variable value.

```
docker run -d -p 80:9080 -p 443:9443 -e WLP_LOGGING_CONSOLE_FORMAT=JSON -e WLP_LOGGING_CONSOLE_LOGLEVEL=info -e WLP_LOGGING_CONSOLE_SOURCE=message,trace,accessLog,ffdc,audit websphere-liberty:latest
```

For more information regarding the configuration of WebSphere Liberty's logging capabilities see: https://www.ibm.com/support/knowledgecenter/en/SSD28V_liberty/com.ibm.websphere.wlp.core.doc/ae/rwlp_logging.html

## Session Caching

The Liberty session caching feature builds on top of an existing technology called JCache (JSR 107), which provides an API for distributed in-memory caching. There are several providers of JCache implementations. The configuration for two such providers, Infinispan and Hazelcast, are outlined below.

1. **Infinispan(Beta Feature)** - One JCache provider is the open source project [Infinispan](https://infinispan.org/), which is the basis for Red Hat Data Grid. Enabling Infinispan session caching retrieves the Infinispan client libraries from the [Infinispan JCACHE (JSR 107) Remote Implementation](https://mvnrepository.com/artifact/org.infinispan/infinispan-jcache-remote) maven repository, and configures the necessary infinispan.client.hotrod.* properties and the Liberty server feature [sessionCache-1.0](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/twlp_admin_session_persistence_jcache.html) by including the XML snippet [infinispan-client-sessioncache.xml](/ga/latest/kernel/helpers/build/configuration_snippets/infinispan-client-sessioncache.xml).

    *  **Setup Infinispan Service** - Configuring Liberty session caching with Infinispan depends on an Infinispan service being available in your Kubernetes environment. It is preferable to create your Infinispan service by utilizing the [Infinispan Operator](https://infinispan.org/infinispan-operator/master/operator.html). The [Infinispan Operator Tutorial](https://github.com/infinispan/infinispan-simple-tutorials/tree/master/operator) provides a good example of getting started with Infinispan in OpenShift.

    *  **Install Client Jars and Set INFINISPAN_SERVICE_NAME** - To enable Infinispan functionality in Liberty, the Docker image author can use the Dockerfile provided below. This Dockerfile assumes an Infinispan service name of `example-infinispan`, which is the default used in the [Infinispan Operator Tutorial](https://github.com/infinispan/infinispan-simple-tutorials/tree/master/operator). To customize your Infinispan service see [Creating Infinispan Clusters](https://infinispan.org/infinispan-operator/master/operator.html#creating_minimal_clusters-start). The `INFINISPAN_SERVICE_NAME` environment variable must be set at build time as shown in the example Dockerfile, or overridden at image deploy time.
        *  **TIP** - If your Infinispan deployment and Liberty deployment are in different namespaces/projects, you will need to set the `INFINISPAN_HOST`, `INFINISPAN_PORT`, `INFINISPAN_USER`, and `INFINISPAN_PASS` environment variables in addition to the `INFINISPAN_SERVICE_NAME` environment variable. This is due to the Liberty deployment not having the access to the Infinispan service environment variables it requires.

    ```dockerfile
    ### Infinispan Session Caching ###
    FROM ibmcom/websphere-liberty:kernel-java8-openj9-ubi AS infinispan-client
    
    # Install Infinispan client jars
    USER root
    RUN infinispan-client-setup.sh
    USER 1001
    
    FROM ibmcom/websphere-liberty:kernel-java8-openj9-ubi AS open-liberty-infinispan
    
    # Copy Infinispan client jars to Open Liberty shared resources
    COPY --chown=1001:0 --from=infinispan-client /opt/ibm/wlp/usr/shared/resources/infinispan /opt/ibm/wlp/usr/shared/resources/infinispan
    
    # Instruct configure.sh to use Infinispan for session caching.
    # This should be set to the Infinispan service name.
    # TIP - Run the following oc/kubectl command with admin permissions to determine this value:
    #       oc get infinispan -o jsonpath={.items[0].metadata.name}
    ENV INFINISPAN_SERVICE_NAME=example-infinispan
    
    # Uncomment and set to override auto detected values.
    # These are normally not needed if running in a Kubernetes environment.
    # One such scenario would be when the Infinispan and Liberty deployments are in different namespaces/projects.
    #ENV INFINISPAN_HOST=
    #ENV INFINISPAN_PORT=
    #ENV INFINISPAN_USER=
    #ENV INFINISPAN_PASS=
    
    # This script will add the requested XML snippets and grow image to be fit-for-purpose
    RUN configure.sh
    ```

    *  **Mount Infinispan Secret** - Finally, the Infinispan generated secret must be mounted as a volume under the mount point of `/platform/bindings/secret/` on Liberty containers. The default location of `/platform/bindings/secret/` can to be overridden by setting the `LIBERTY_INFINISPAN_SECRET_DIR` environment variable. When using the Infinispan Operator, this secret is automatically generated as part of the Infinispan service with the name of `<INFINISPAN_CLUSTER_NAME>-generated-secret`. For the mounting of this secret to succeed, the Infinispan Operator and Liberty must share the same namespace. If they do not share the same namespace, the `INFINISPAN_HOST`, `INFINISPAN_PORT`, `INFINISPAN_USER`, and `INFINISPAN_PASS` environment variables can be used instead(see the dockerfile example above). For an example of mounting this secret, review the `volumes` and `volumeMounts` portions of the YAML below.

    ```yaml
    ...
        spec:
          volumes:
          - name: infinispan-secret-volume
            secret:
              secretName: example-infinispan-generated-secret
          containers:
          - name: servera-container
            image: ol-runtime-infinispan-client:1.0.0
            ports:
            - containerPort: 9080
            volumeMounts:
            - name: infinispan-secret-volume
              readOnly: true
              mountPath: "/config/liberty-infinispan-secret"
    ...

    ```

2. **Hazelcast** - Another JCache provider is [Hazelcast In-Memory Data Grid](https://hazelcast.org/). Enabling Hazelcast session caching retrieves the Hazelcast client libraries from the [hazelcast/hazelcast](https://hub.docker.com/r/hazelcast/hazelcast/) Docker image, configures Hazelcast by copying a sample [hazelcast.xml](/ga/latest/kernel/helpers/build/configuration_snippets/), and configures the Liberty server feature [sessionCache-1.0](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/twlp_admin_session_persistence_jcache.html) by including the XML snippet [hazelcast-sessioncache.xml](/ga/latest/kernel/helpers/build/configuration_snippets/hazelcast-sessioncache.xml). By default, the [Hazelcast Discovery Plugin for Kubernetes](https://github.com/hazelcast/hazelcast-kubernetes) will auto-discover its peers within the same Kubernetes namespace. To enable this functionality, the Docker image author can include the following Dockerfile snippet, and choose from either client-server or embedded [topology](https://docs.hazelcast.org/docs/latest-dev/manual/html-single/#hazelcast-topology).

    ```dockerfile
    ### Hazelcast Session Caching ###
    # Copy the Hazelcast libraries from the Hazelcast Docker image
    COPY --from=hazelcast/hazelcast --chown=1001:0 /opt/hazelcast/lib/*.jar /opt/ibm/wlp/usr/shared/resources/hazelcast/
    
    # Instruct configure.sh to copy the client topology hazelcast.xml
    ARG HZ_SESSION_CACHE=client
    
    # Default setting for the verbose option
    ARG VERBOSE=false
    
    # Instruct configure.sh to copy the embedded topology hazelcast.xml and set the required system property
    #ARG HZ_SESSION_CACHE=embedded
    #ENV JAVA_TOOL_OPTIONS="-Dhazelcast.jcache.provider.type=server ${JAVA_TOOL_OPTIONS}"
    
    ## This script will add the requested XML snippets and grow image to be fit-for-purpose
    RUN configure.sh
    ```

## Applying interim fixes

This section describes the process to apply interim fixes via the Dockerfile during `build` time, by adding the interim fix JAR files to `/opt/ibm/fixes` directory and calling `RUN configure.sh`. Interim fixes recommended by IBM, such as to resolve security vulnerabilities, are also included in the same directory.

Ensure that all features needed by your applications, apart from the ones that will be automatically added for the [enterprise functionalities](#optional-enterprise-functionality) you selected, are specified prior to calling `RUN configure.sh`, since interim fixes should only be applied once needed features are installed.

```dockerfile
# Add interim fixes (optional)
COPY --chown=1001:0  interim-fixes /opt/ibm/fixes/

# Default setting for the verbose option
ARG VERBOSE=false

# This script will add the requested XML snippets, grow image to be fit-for-purpose and apply interim fixes
RUN configure.sh
```

## Installing Liberty Features from local repository (19.0.0.8+)

This section describes very simple way to speed up feature installation during builds of your images

#### Locally hosting feature repository

The repository files can be downloaded from [Fix Central](https://www-945.ibm.com/support/fixcentral).


To host feature repository on-premises one of the easiest solutions could be using `nginx` docker image.

`docker run --name repo-host -v /repo-host:/usr/share/nginx/html:ro -p 8080:80 -d nginx`

You can mount and serve multiple zip files using a docker volume mount, for example repo-host folder mounted from host to nginx container above.

You can place each zip archive in versioned folders, for example repo-host/${LIBERTY_VERSION}/repo.zip

You will need a hostname/IP and mapped port to generate `FEATURE_REPO_URL`, for example above port 8080 is used.

#### Using locally hosted feautre repository in Dockerfile

Using `FEATURE_REPO_URL` build argument it is possible to provide a link to a feature repo zip file
containing all the features. You will also need to make sure to call `RUN configure.sh` in your Dockerfile

`docker build --build-arg FEATURE_REPO_URL="http://wlprepos:8080/19.0.0.x/repo.zip"`

You can also set it through Dockerfile

```dockerfile
FROM ibmcom/websphere-liberty:kernel-java8-openj9-ubi
ARG FEATURE_REPO_URL=http://wlprepos:8080/19.0.0.x/repo.zip
ARG VERBOSE=false
RUN configure.sh
```

Note: This feature requires a `curl ` command to be in the docker image.
Some base images do not provide `curl`. You can add it before calling `confiure.sh` this way:

```dockerfile
FROM ibmcom/websphere-liberty:kernel-java8-openj9-ubi
USER root
RUN apt-get update && apt-get install -y curl
USER 1001
ARG FEATURE_REPO_URL=http://wlprepos:8080/19.0.0.x/repo.zip
ARG VERBOSE=false
RUN configure.sh
```



# Issues and Contributions

For issues relating specifically to the Dockerfiles and scripts, please use the [GitHub issue tracker](https://github.com/WASdev/ci.docker/issues). For more general issue relating to IBM WebSphere Application Server Liberty you can [get help](https://developer.ibm.com/wasdev/help/) through the WASdev community or, if you have production licenses for WebSphere Application Server, via the usual support channels. We welcome contributions following [our guidelines](https://github.com/WASdev/wasdev.github.io/blob/master/CONTRIBUTING.md).

# License

The Dockerfiles and associated scripts found in this project are licensed under the [Apache License 2.0](LICENSE).

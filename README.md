# WebSphere Application Server Liberty Profile and Docker [![Build Status](https://travis-ci.org/WASdev/ci.docker.svg?branch=master)](https://travis-ci.org/WASdev/ci.docker)

This project contains the Dockerfiles for [WebSphere Application Server Liberty](https://hub.docker.com/_/websphere-liberty/). 

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

# This script will add the requested XML snippets and grow image to be fit-for-purpose
RUN configure.sh
```

This will result in a Docker image that has your application and configuration pre-loaded, which means you can spawn new fully-configured containers at any time.

## Enterprise Functionality

Please refer to the [Open Liberty documentation](https://github.com/OpenLiberty/ci.docker#enterprise-functionality), which directly applies to the WebSphere Liberty containers.


# Issues and Contributions

For issues relating specifically to the Dockerfiles and scripts, please use the [GitHub issue tracker](https://github.com/WASdev/ci.docker/issues). For more general issue relating to IBM WebSphere Application Server Liberty you can [get help](https://developer.ibm.com/wasdev/help/) through the WASdev community or, if you have production licenses for WebSphere Application Server, via the usual support channels. We welcome contributions following [our guidelines](https://github.com/WASdev/wasdev.github.io/blob/master/CONTRIBUTING.md).

# License

The Dockerfiles and associated scripts found in this project are licensed under the [Apache License 2.0](LICENSE).

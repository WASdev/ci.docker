# WebSphere Application Server Developer Edition Liberty kernel-slim image

The [Dockerfile.ubuntu.ibmjava8](Dockerfile.ubuntu.ibmjava8) in this directory is used to build the `websphere-liberty:kernel-slim` image on [Docker Hub](https://registry.hub.docker.com/_/websphere-liberty/). The image contains IBM WebSphere Application Server Developer Edition Liberty Kernel and an IBM Java Runtime Environment.

# Usage

Instructions for using the image can be found on [Docker Hub](https://registry.hub.docker.com/_/websphere-liberty/). It is possible to build the image yourself by cloning this repository, changing to the `ga/<version>/kernel-slim` directory and then issuing the command to build container image. For example, with Docker execute `docker build .`.

**Note:** Refer to [Optional Enterprise Functionality](https://github.com/WASdev/ci.docker#optional-enterprise-functionality) to ensure certain features are enabled such as monitoring or SSL.

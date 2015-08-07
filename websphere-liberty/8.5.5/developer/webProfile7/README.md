# WebSphere Application Server Developer Edition V8.5.5 Liberty Profile image for Docker

The [Dockerfile](Dockerfile) in this directory is used to build the `websphere-liberty:webProfile7` image on [Docker Hub](https://registry.hub.docker.com/_/websphere-liberty/). The image contains IBM WebSphere Application Server Developer Edition V8.5.5 with Java EE 7 Web Profile features and builds on the `java:jre` OpenJRE image.

# Usage

Instructions for using the image can be found on [Docker Hub](https://registry.hub.docker.com/_/websphere-liberty/). It is possible to build the image yourself by cloning this repository, changing to the `websphere-liberty/8.5.5/developer/webProfile7` directory and then issuing the command `docker build .`.

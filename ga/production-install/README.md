# Building a IBM WebSphere Application Server Liberty Profile production images from binaries

An IBM WebSphere Application Server Liberty Profile production image can be built by obtaining the following binaries:
* WebSphere Application Server Liberty Runtime Archive from [Passport Advantage](http://www-01.ibm.com/software/passportadvantage/pao_customer.html) / [Fix Central](http://www-933.ibm.com/support/fixcentral/)
* IBM JRE from [developerWorks](https://www.ibm.com/developerworks/java/jdk/linux/download.html)

Dockerfiles are provided for two approaches to building the image:
1. Add the binaries to the image from the local file system.
2. Host the binaries on a FTP or HTTP server and obtain via wget.

The first option is simpler and will build quicker but results in a larger Docker image as the packaged binaries are included as a layer in the final image. These Dockerfiles are not prespective and you may create your own Dockerfiles to package WebSphere Application Server.

## Add binaries from local file system

1. Clone this repository.
2. Move to the directory `websphere-liberty/8.5.5/production-install/add`.
3. Place the downloaded Liberty Runtime Archive and IBM JRE in to this directory.
3. Review the Dockerfile and modify the filenames if required,
5. Build the image using:

    ```bash
    docker build -t <image-name> .
    ```

## wget binaries from FTP or HTTP server

1. Place the downloaded Liberty Runtime Archive and IBM JRE on the FTP or HTTP server.
2. Clone this repository.
3. Move to the directory `websphere-liberty/8.5.5/production-install/wget`.
4. Review the Dockerfile and update the user credentials and URL of the server hosting the binaries.
5. Build the image using:

    ```bash
    docker build -t <image-name> .
    ```

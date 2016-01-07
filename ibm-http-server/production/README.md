# Building an IBM HTTP Server production image from binaries

An IBM HTTP Server production image can be built by obtaining the following binaries:
* IBM Installation Manager binaries from [Passport Advantage](http://www-01.ibm.com/software/passportadvantage/pao_customer.html)
* IBM HTTP Server binaries from [Passport Advantage](http://www-01.ibm.com/software/passportadvantage/pao_customer.html) / [Fix Central](http://www-933.ibm.com/support/fixcentral/)

IBM HTTP Server production install image is created in two steps using the following two Dockerfiles

1. Dockerfile.prereq
2. Dockerfile.install

Dockerfile.prereq does the following:
 
1. Installs IBM Installation Manager
2. Installs IBM HTTP Server 
3. Updates IBM HTTP Server with the Fixpack
4. Installs WebServer Plugins
5. Updates WebServer Plugins with the Fixpack
6. Installs WebSphere Customization Tools
7. Updates WebSphere Customization Tools with the Fixpack
8. When the container is started a tar file of the IBM HTTP Server, WebServer Plugins and  WCT installation is created

Dockerfile takes the values for the following variables during build time 
* URL(required) - URL from where the binaries are downloaded

Dockerfile.install does the following:                                                                                                           

1. Extracts the tar file created by Dockerfile.prereq
2. Copies the startup script to the image
3. When the container is started the IHS server is started

## Building the IBM HTTP Server production image

1. Place the downloaded IBM Installation Manager and IBM HTTP Server binaries on the FTP or HTTP server.
2. Clone this repository.
3. Move to the directory `ibm-http-server/production`.
4. Build the prereq image using:

    ```bash
    docker build --build-arg URL=<URL> -t <prereq-image-name> -f Dockerfile.prereq .
    ```

5. Run a container using the prereq image to get the tar file to the current folder using

    ```bash
    docker run -v <path>/ibm-http-server/production:/tmp -d -t <prereq-image-name>
    ```

6. Build the install image using       

    ```bash
    docker build -t <install-image-name> -f Dockerfile.install .
    ```



# Upgrading the developer liberty image from DockerHub to a production image using the license jars obtained from Passport Advantage

A IBM WebSphere Application Server Liberty Profile production image can be built by obtaining the license jar from Passport Advantage:
* WebSphere Application Server Liberty license jar from Passport Advantage / Fix Central

1. Clone this repository.
2. Move to the directory `websphere-liberty/8.5.5/production-upgrade`.
3. Place the downloaded Liberty license jar to this directory.
3. Review the Dockerfile and modify the filenames if required.
5. Build the image using:

    ```bash
    docker build -t <image-name> .
    ```

 Dockerfile can be modified and used to upgrade from Liberty Core to Liberty Base/ Liberty ND
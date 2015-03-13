# Upgrading the developer Liberty image from DockerHub to a production image using the license JARs obtained from Passport Advantage

You can build an IBM WebSphere Application Server Liberty Profile production image by obtaining the license JAR files from Passport Advantage:
* WebSphere Application Server Liberty license jar from [Passport Advantage](http://www-01.ibm.com/software/passportadvantage/pao_customer.html) / [Fix Central](http://www-933.ibm.com/support/fixcentral/)

1. Clone this repository.
2. Go to the `websphere-liberty/8.5.5/production-upgrade` directory.
3. Place the downloaded Liberty license JAR file in the directory.
3. Review the Dockerfile and modify the filenames if required.
5. Build the image using:

    ```bash
    docker build -t <image-name> .
    ```

 Dockerfile can be modified and used to upgrade from Liberty Core to Liberty Base / Liberty ND
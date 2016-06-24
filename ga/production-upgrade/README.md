# Upgrading the image from Docker Hub to a production image

If entitled, you can upgrade the `websphere-liberty:8.5.5` Developer Edition image from Docker Hub to an IBM WebSphere Application Server Liberty Profile production image using the license JAR files from [Passport Advantage](http://www-01.ibm.com/software/passportadvantage/pao_customer.html) / [Fix Central](http://www-933.ibm.com/support/fixcentral/). The steps to use the license JAR as follows:

1. Clone this repository.
2. Go to the `websphere-liberty/ga/production-upgrade` directory.
3. Place the downloaded Liberty license JAR file in the directory.
3. Review the `Dockerfile` and modify the filenames if required.
5. Build the image using the following command:

    ```bash
    docker build -t <image-name> .
    ```

The Dockerfile can also be modified and used to upgrade an image containing Liberty Core to Liberty Base / Liberty ND.

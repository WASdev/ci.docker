# Using WebSphere Liberty container images in production

Starting with WebSphere Liberty 18.0.0.3, the WebSphere Liberty container images contain an International License Agreement for Non-Warranted Programs (ILAN) license which **allows entitled** WebSphere Liberty customers to use these same images under an International Program License Agreement (IPLA) term.

If you want to omit the "development-only" message from the logs all you have to do is set the environment variable called `LICENSE` to the value `accept`.  

However, if you wish to apply a license to the image, you can do so by:

*  Download the license JAR file from [Passport Advantage](http://www-01.ibm.com/software/passportadvantage/pao_customer.html) / [Fix Central](http://www-933.ibm.com/support/fixcentral/).
*  Clone this repository.
*  Go to the `ga/production-upgrade` directory.
*  Place the downloaded Liberty license JAR file in the directory.
*  Review the `Dockerfile` and modify the filenames if required.
*  Build the image using the following command:

    ```bash
    docker build -t <image-name> .
    ```

The Dockerfile can also be modified and used to upgrade an image containing Liberty Core to Liberty Base / Liberty ND.

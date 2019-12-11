# Building and Testing images

IBM WebSphere Application Server Liberty Profile images can be built and verified using the test scripts provided

## Build and Test a specific image

1. Clone this repository.
2. Move to the directory `test/`.
3. Build and Test image using:

    ```bash
    sh build.sh <image-name> <dockerfile-location> <optional: dockerfile name>
    sh verify.sh <image-name>
    ```

## Build and Test all images for a release

1. Clone this repository.
2. Move to the directory `test/`.
3. Build and Test images using:


    ```bash
    sh buildAll.sh <Release Version /(i.e. ../ga/19.0.0.9)>
    ```

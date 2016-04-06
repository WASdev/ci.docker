# Generating a web server plug-in configuration

The files in this directory can be used to extend an IBM WebSphere Application
Server Liberty image. By using the extended image you can generate a web
server plug-in configuration file (plugin-cfg.xml).

To build an extended image follow these steps:

1. Clone this repository.
2. Change to the directory `websphere-liberty/static-topology/gen-plugin-cfg`.
3. Review the `Dockerfile` to ensure that the `FROM` command specifies the
image that you want to extend and the paths contain the location of your 
WebSphere Liberty install. The default values in the file are
configured to work with the `websphere-liberty` image on Docker Hub.
4. Build the image by using the following command:

    ```bash
    docker build -t <image-name> .
    ```

## Usage

To generate the plug-in configuration file use the extended image that you
built, ensure that the image is running, then use the following command:

   ```bash
   docker exec <container-name> /opt/ibm/wlp/bin/GenPluginCfg.sh \
     --installDir=<PATH_TO_WLP> --userDir=<PATH_TO_USR> --serverName=<SERVERNAME>
   ```
  
The plug-in configuration file is written to the following path: 
`<WLP_OUTPUT_DIR>/<SERVERNAME>/plugin-cfg.xml`.

Note: The hostname and ports in the generated file reflect those inside
the container. These might need to be updated to reflect the values exposed externally
and accessible by the web server.

To generate the plug-in configuration file when you have extended the image on Docker Hub,
use the following command:

   ```bash
   docker exec <container-name> /opt/ibm/wlp/bin/GenPluginCfg.sh \
     --installDir=/opt/ibm/wlp --userDir=/opt/ibm/wlp/usr --serverName=defaultServer
   ```

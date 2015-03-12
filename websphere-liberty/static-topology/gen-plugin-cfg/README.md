# Generating a web server plug-in configuration

The files in this directory can be used to extend an IBM WebSphere Application
Server Liberty Profile image so that, once running, a web server plug-in
configuration file (plugin-cfg.xml) can be generated.

To build an image with this capability follow these steps:

1. Clone this repository.
2. Change to the directory `websphere-liberty/static-topology/gen-plugin-cfg`.
3. Review the `Dockerfile` to ensure that the `FROM` command reflects in the
image in your registry that you want to extend and that the paths reflect the
location of your WebSphere Liberty install. The default values in the file are
configured to work with the `websphere-liberty` image on Docker Hub.
3. Build the image using:

    ```bash
    docker build -t <image-name> .
    ```

## Usage

Once the extended image is running, the plug-in configuration can be generated
using the following command:

   ```bash
   docker exec <container-name> /opt/ibm/wlp/bin/GenPluginCfg.sh \
     --installDir=<PATH_TO_WLP> --userDir=<PATH_TO_USR> --serverName=<SERVERNAME>
   ```
  
The plug-in configuration file is written to `<PATH_TO_USR>/servers/<SERVERNAME>/plugin-cfg.xml`.

For the `websphere-liberty` image on Docker Hub, the command would be as follows:

   ```bash
   docker exec <container-name> /opt/ibm/wlp/bin/GenPluginCfg.sh \
     --installDir=/opt/ibm/wlp --userDir=/opt/ibm/wlp/usr --serverName=defaultServer
   ```
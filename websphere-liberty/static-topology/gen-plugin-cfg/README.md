# Adding the plug-in generation script to the liberty image

A IBM WebSphere Application Server Liberty Profile image with plug-in generation script can be built with the scripts available

1.Clone this repository.

2.Move to the directory websphere-liberty/static-topology/gen-plugin-cfg.

3.Build the image using:

    ```bash
    docker build -t <image-name> .
    ```

The plug-in generation script generates plugin-cfg.xml which is used in configuring webserver.

### Usage

   ```bash
   docker run -d -t <image-name> 
   docker exec <image-name> /opt/ibm/wlp/bin/GenPluginCfg.sh --installDir=<PATH_TO_WLP> --userDir=<PATH_TO_USR> --serverName=<SERVERNAME>
   
   Plugin configuration file written to <PATH_TO_USR>/servers/<SERVERNAME>/plugin-cfg.xml
   
   ```

   

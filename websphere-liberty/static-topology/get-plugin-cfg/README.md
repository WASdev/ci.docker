# Getting a web server plug-in configuration

The files in this directory can be used in conjunction with those in the gen-plugin-cfg directory to generate and then retrieve the server 
plug-in configuration file (plugin-cfg.xml) of a Liberty instance running in a given container.

## Usage

To retrieve the plug-in configuration file by using the extended image that you
created in the [gen-plugin-cfg directory](/websphere-liberty/static-topology/gen-plugin-cfg), use the following command when the image is running.

Note the GenPluginCfg.sh script must be in the same directory as the GetPluginCfg.sh script.

   ```bash
   GetPluginCfg.sh <container-id> <hostname>
   ```
  
The plug-in configuration file is written to the container that the Liberty instance is running in,
the hostname and ports are then updated to reflect the values exposed externally and then the XML file
is copied into the active directory.
# Getting a web server plug-in configuration

The files in this directory can be used with those in the 
gen-plugin-cfg directory to generate, and then retrieve, the server 
plug-in configuration file (plugin-cfg.xml) of a Liberty instance
running in a given container. The script that is provided modifies the
hostname and ports specified in the plug-cfg.xml so that they reflect the
way in which the container might be accessed externally.

## Usage

To retrieve the plug-in configuration file, use the extended image that you
built in the [gen-plugin-cfg directory](/websphere-liberty/static-topology/gen-plugin-cfg), ensure the image is running, then use the following command:

   ```bash
   GetPluginCfg.sh <container-id> <hostname>
   ```
  
The `hostname` is the name of the Docker host on which the container is running, and by which the container is accessed. The plug-in configuration XML file is written to the container that the Liberty instance is running in, then copied into the current directory on the host, and then the hostname and ports are updated to reflect the values exposed externally by the container.

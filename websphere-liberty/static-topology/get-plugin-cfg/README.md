# Getting a web server plug-in configuration

The files in this directory can be used in conjunction with those in the 
gen-plugin-cfg directory to generate, and then retrieve, the server 
plug-in configuration file (plugin-cfg.xml) of a Liberty instance
running in a given container. The provided script will then modify the
hostname and ports specified in the plug-cfg.xml so that they reflect the
way in which the container may be accessed externally.

## Usage

To retrieve the plug-in configuration file by using the extended image that you
created in the [gen-plugin-cfg directory](/websphere-liberty/static-topology/gen-plugin-cfg), use the following command when the image is running:

   ```bash
   GetPluginCfg.sh <container-id> <hostname>
   ```
  
Where `hostname` is the name of the Docker host on which the container is running and via which the container is accessed. The plug-in configuration XML file is written to the container that the Liberty instance is running in, copied in to the current directory on the host, and then the hostname and ports are updated to reflect the values exposed externally by the container.

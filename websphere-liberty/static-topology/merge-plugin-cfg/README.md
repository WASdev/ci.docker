# Merging web server plug-in configurations

The script in this directory can be used to combine web server plug-in configurations produced by using a combination of the genPluginCfg.sh script inside the container and the GetPluginCfg.sh

## Usage

To merge the server configuration files place this script into the same directory as the server configuration xml files then use the pluginCfgMerge.sh to create a single xml file.

```bash
    ./pluginCfgMerge <serverConfigName1.xml> <serverConfigName2.xml> <desired merged filename>
```
  
The result of running the above script will combine the two server configuration .xml files into one file.

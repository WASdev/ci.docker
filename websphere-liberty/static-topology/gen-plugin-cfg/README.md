# Plug-in Generation Script 

The plug-in generation script generates plugin-cfg.xml which is used in configuring webserver.

###### Syntax

```bash
./GenPluginCfg.sh --installDir=<PATH_TO_WLP> --outputDir=<PATH_TO_OUTPUT> --userDir=<PATH_TO_USR> --serverName=<SERVERNAME>
```
where

 --installDir is the path of liberty installation
 
 --outputDir is the path where plugin-cfg.xml will be generated
 
 --userDir is the path of liberty user directory
 
 --serverName is the name of server for which plugin-cfg.xml needs to be generated

for example

./GenPluginCfg.sh –installDir=/opt/IBM/wlp –outputDir=/opt/IBM/wlp/usr/servers/defaultServer –userDir =/opt/IBM/wlp/usr --serverName=defaultServer

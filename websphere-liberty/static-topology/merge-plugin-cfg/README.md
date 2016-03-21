# Merging web server plug-in configurations

The script in this directory can be used to combine web server plug-in configurations produced by using a combination of the [genPluginCfg.sh](../gen-plugin-cfg) script inside the container and the [GetPluginCfg.sh](../get-plugin-cfg) script outside.

## Usage

To merge the server configuration files place this script into the same directory as the server configuration XML files then use the pluginCfgMerge.sh script to create a single XML file. For example, to merge the two files `serverConfig1.xml` and `serverConfig2.xml` in to `mergedConfig.xml`, use the following command:

```bash
    ./pluginCfgMerge serverConfig1.xml serverConfig2.xml mergedConfig.xml
```
  
The result of running the above script will be to combine the two server configuration XML files in to one file. In order for the script to run, the `WLP_HOME` environment variable must be set to point to a WebSphere Liberty installation that has the `collectiveController-1.0` feature installed. To simplify the usage of the script, a Dockerfile is provided that can be used to build an image containing the script and its pre-requisites. Build the image using the following command:

```bash
    docker build -t merge .
```

The resulting image can then be used as follows:

```bash
    docker run --rm -v $(PWD):/files merge pluginCfgMerge.sh \
      /files/serverConfig1.xml /files/serverConfig2.xml /files/mergedConfig.xml
```

This example assumes that the files `serverConfig1.xml` and `serverConfig2.xml` are in the current working directory which is mounted in to the container at the location `/files`. This is where the resulting `mergedConfig.xml` will also be written.

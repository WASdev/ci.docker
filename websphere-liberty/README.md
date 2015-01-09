# Overview 

This image contains IBM WebSphere Application Server for Developers Liberty Profile and the IBM Java Runtime Environment. For more information on WebSphere Application Server Liberty Profile, see [WASdev](https://developer.ibm.com/wasdev/docs/category/getting-started/). The Dockerfile for this image can be found on [WASdev GitHub](https://github.com/WASdev/ci.docker/blob/master/websphere-liberty/8.5.5/Dockerfile).

# Usage

In order to use the image, it is necessary to accept the terms of the WebSphere Application Server for Developers and IBM JRE licenses. This is achieved by specifying the environment variable `LICENSE` equal to `accept` when running the image. You can also view the license terms by setting this variable to `view`. Failure to set the variable will result in the termination of the container with a usage statement.

The image is designed to support a number of different usage patterns:

1. The image contains a default server configuration that specifies the `webProfile-6.0` feature and exposes ports 9080 and 9443 for HTTP and HTTPS respectively. A WAR file can therefore be mounted in to the `dropins` directory of this server and run. The following example starts a container in the background running a WAR file from the host file system with the HTTP and HTTPS ports mapped to 80 and 443 respectively.

    ```
    docker run -e LICENSE=accept -d -p 80:9080 -p 443:9443 -v /tmp/myApp.war:/opt/ibm/wlp/usr/servers/defaultServer/dropins/myApp.war wasdev/websphere-liberty
    ```
    
2. For greater flexibility over configuration, it is possible to mount an entire server configuration directory from the host and then specify the server name as a parameter to the run command. The following example uses the server configuration from the `myServer` directory on the host.

    ```
    docker run -e LICENSE=accept -p 80:9080 -p 443:9443 -v /tmp/myServer:/opt/ibm/wlp/usr/servers/myServer wasdev/websphere-liberty /opt/ibm/wlp/bin/server run myServer
    ```
    
3. It is also possible to build an application layer on top of this image using either the default server configuration or a new server configuration and, optionally, accept the license as part of that build.

    ```
    FROM wasdev/websphere-liberty
    ADD myApp.war /opt/ibm/wlp/usr/servers/defaultServer/dropins/
    ENV LICENSE accept
    ```

4. Lastly, it is possible to mount a data volume container containing the application and the server configuration on to the image. This has the benefit that it has no dependency on files from the host but still allows the application container to be easily re-mounted on a newer version of the application server image.

    Build and run the data volume container:
    
    ```
    FROM ubuntu:14.04
    ADD myServer /opt/ibm/wlp/usr/servers/myServer
    ```
    
    ```
    docker build -t app-image .
    docker run -d -v /opt/ibm/wlp/usr/servers/myServer --name app app-image true
    ```
    
    Run the WebSphere Liberty image with the volumes from the data volume container mounted:

    ```
    docker run -e LICENSE=accept -d --volumes-from app wasdev/websphere-liberty /opt/ibm/wlp/bin/server run myServer
    ```

# Issues and contributions

For issues relating specifically to this Docker image, please use the [GitHub issue tracker](https://github.com/WASdev/ci.docker/issues). For more general issue relating to IBM WebSphere Application Server Liberty Profile you can [get help](https://developer.ibm.com/wasdev/help/) through the WASdev community. We welcome contributions following [our guidelines](https://github.com/WASdev/wasdev.github.io/blob/master/CONTRIBUTING.md).

# License

The Dockerfile and associated scripts are licensed under the [Apache License 2.0](LICENSE). The IBM JRE and WebSphere Application Server for Developers are licensed under the IBM International License Agreement for Non-Warranted Programs. Those licenses may be viewed from the image using the `LICENSE=view` environment variable as described above or may be found online for the [IBM JRE](https://www14.software.ibm.com/cgi-bin/weblap/lap.pl?la_formnum=&li_formnum=L-EWOD-99YA4J&title=IBM%C2%AE+SDK%2C+Java+Technology+Edition%2C+Version+7+Release+1&l=en) and [IBM WebSphere Application Server for Developers](https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/8.5.5.3/lafiles/runtime/en.html). Note that this license does not permit further distribution.

# Overview 

This repository contains Dockerfiles for IBM WebSphere Application Server Liberty Profile utilizing the IBM Java Runtime Environment. For more information on WebSphere Application Server Liberty Profile, see [WASdev](https://developer.ibm.com/wasdev/docs/category/getting-started/). There are currently Dockerfiles for [IBM WebSphere Application Server for Developers V8.5.5 Liberty Profile](https://github.com/WASdev/ci.docker/blob/master/websphere-liberty/8.5.5/Dockerfile) and [IBM WebSphere Application Server Liberty v9 Beta with Java EE 7](https://github.com/WASdev/ci.docker/blob/master/websphere-liberty/beta/Dockerfile).

# Usage

Images built from these Dockerfiles can be found in the official [websphere-liberty](https://registry.hub.docker.com/_/websphere-liberty/) repository on Docker Hub along with instructions for their use. It is also possible to build the images yourself by cloning this repository, changing to either the `8.5.5` or `beta` directory and then issuing the command `docker build .`.

# Issues and contributions

For issues relating specifically to these Dockerfiles, please use the [GitHub issue tracker](https://github.com/WASdev/ci.docker/issues). For more general issue relating to IBM WebSphere Application Server Liberty Profile you can [get help](https://developer.ibm.com/wasdev/help/) through the WASdev community. We welcome contributions following [our guidelines](https://github.com/WASdev/wasdev.github.io/blob/master/CONTRIBUTING.md).

# License

The Dockerfile and associated scripts are licensed under the [Apache License 2.0](LICENSE). The IBM JRE and WebSphere Application Server for Developers are licensed under the IBM International License Agreement for Non-Warranted Programs and the Beta under the IBM International License Agreement for Early Release of Programs. Those licenses may be viewed from the image using the `LICENSE=view` environment variable as described above or may be found online for the [IBM JRE](https://www14.software.ibm.com/cgi-bin/weblap/lap.pl?la_formnum=&li_formnum=L-EWOD-99YA4J&title=IBM%C2%AE+SDK%2C+Java+Technology+Edition%2C+Version+7+Release+1&l=en), [IBM WebSphere Application Server for Developers](https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/8.5.5.4/lafiles/runtime/en.html) and [IBM WebSphere Application Server Liberty v9 Beta with Java EE 7](https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/beta/lafiles/en.html). Note that these licenses do not permit further distribution.

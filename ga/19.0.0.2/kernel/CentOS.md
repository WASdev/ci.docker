# WebSphere Liberty with CentOS (or RHEL)

### Build the Java CentOS (or RHEL) image using IBM Java's GitHub repo
* `git clone https://github.com/ibmruntimes/ci.docker.git`

* `cd ci.docker/ibmjava/8/jre/rhel`

* If you want to build an IBM JRE image based on RHEL, skip to the next step.  To build an IBM JRE image based on CentOS simply change the `FROM` statement to `FROM centos:latest`

`docker build -t ibmjava:8-jre .`

### Build the WebSphere Liberty CentOS (or RHEL) image
`git clone https://github.com/WASdev/ci.docker.git`

`cd ga/19.0.0.2/centos`

`docker build -t websphere-liberty:kernel .`

### Build other tags
You can then use the `websphere-liberty:kernel` image as the base of your own application Dockerfile and `installUtility` to grow the set of features, or alternatively you can build any of the other tags in the `19.0.0.2` directory, such as `javaee8`, `springBoot2`, etc.  
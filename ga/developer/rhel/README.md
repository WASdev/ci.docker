# WebSphere Application Server Developer Edition Liberty RHEL / RHEL-atomic image for Docker

The Dockerfiles in this directory build an image that contains IBM WebSphere Application Server Developer Edition Liberty Java EE7 + MicroProfile and an IBM Java Runtime Environment, built on top of the RHEL (or RHEL-atomic) operating system.

The instructions below assume you are building from a RHEL (or RHEL-atomic) operating system machine that is appropriately registered with Red Hat, and have [setup docker](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/getting_started_with_containers/get_started_with_docker_formatted_container_images#getting_docker_in_rhel_7) in RHEL.

Due to RHEL's version of docker being behind the latest docker versions we cannot use multi-stage builds (i.e. can't use `--from`) nor the integrated `chown` support for `ADD` or `COPY` instructions.

If you wish to use Docker EE instead of RHEL's docker, you can follow [Docker's instructions](https://docs.docker.com/install/linux/docker-ee/rhel/), which will allow you to use a much newer version of the docker daemon but please be aware there's currently an [issue](https://serverfault.com/questions/809544/redhat-container-on-pure-docker-engine/) where the RHEL subscription from the docker host is not propagated into the docker image.  The suggested workaround is to mount the RHEL license from the docker host into the docker container.

# Usage

## Clone this repo
`git clone https://github.com/wasDev/ci.docker.git`

## Navigate to this directory
`cd ci.docker/ga/developer/rhel/`

## Build RHEL-Liberty image
`./docker-build.sh <tag>`  

...where `<tag>` can be one of: `kernel`, `webProfile7`, `microProfile`, `javaee7`


## Build RHEL-atomic-Liberty image
`./docker-build.sh <tag> Dockerfile.rhelatomic` 

...where `<tag>` can be one of: `kernel`, `webProfile7`, `microProfile`, `javaee7`


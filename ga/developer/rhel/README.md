# WebSphere Application Server Developer Edition Liberty RHEL / RHEL-atomic image for Docker

The Dockerfiles in this directory build an image that contains IBM WebSphere Application Server Developer Edition Liberty Java EE7 + MicroProfile and an IBM Java Runtime Environment, built on top of the RHEL (or RHEL-atomic) operating system.

The instructions below assume you are building from a RHEL (or RHEL-atomic) operating system machine that is appropriately registered with Red Hat, and have [setup docker](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/getting_started_with_containers/get_started_with_docker_formatted_container_images#getting_docker_in_rhel_7) in RHEL.

Due to RHEL's version of docker being behind the latest docker versions we cannot use multi-stage builds (i.e. can't use `--from`) nor the integrated `chown` support for `ADD` or `COPY` instructions.

# Usage

## Pull files from base image
`docker create --name wlp websphere-liberty`
`docker cp wlp:/opt/ibm .`

## Build RHEL-Liberty image
`docker build -t rhel_wlp Dockerfile.rhel`

## Build RHEL-atomic-Liberty image
`docker build -t rhelatomic_wlp Dockerfile.rhelatomic`

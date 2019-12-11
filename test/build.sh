#! /bin/bash
#####################################################################################
#                                                                                   #
#  Script to build a docker image                                                   #
#                                                                                   #
#                                                                                   #
#  Usage : build.sh <Image name> <Dockerfile location> <optional: dockerfile name>  #
#                                                                                   #
#####################################################################################

image=$1
dloc=$2
dname=$3

tag=`echo $image | cut -d ":" -f2`

test=test
cname=$tag$test

if [[ $# -gt 3 || $# -lt 2 ]]
then
  echo "Usage : build.sh <Image name (e.g. websphere-liberty:19.0.0.1-kernel)> <Dockerfile location> <optional: dockerfile name>"
  exit 1
fi

# Default to podman where available, docker otherwise.
# Override by setting the DOCKER environment variable.
if test -z "$DOCKER"; then
  which podman > /dev/null 2>&1
  if [ $? != 0 ]; then
    export DOCKER=docker
  else
    export DOCKER=podman
  fi
fi

echo "******************************************************************************"
echo "           Starting docker build for $image                                   "
echo "******************************************************************************"

if [ $# -eq 3 ]; then
  $DOCKER build --no-cache=true -t $image -f $dname $dloc  > build_$tag.log
else 
  $DOCKER build --no-cache=true -t $image $dloc  > build_$tag.log
fi

if [ $? = 0 ]
then
    echo "******************************************************************************"
    echo "              $image built successfully                                       "
    echo "******************************************************************************"
else
    echo " Build failed , exiting.........."
    exit 1
fi

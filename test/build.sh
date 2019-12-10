#! /bin/bash
#####################################################################################
#                                                                                   #
#  Script to build a docker image                                                   #
#                                                                                   #
#                                                                                   #
#  Usage : build.sh <Image name> <Dockerfile location>                              #
#                                                                                   #
#####################################################################################

image=$1
versionimage=$2
dloc=$3

tag=`echo $image | cut -d ":" -f2`

test=test
cname=$tag$test

if [ $# != 3 ]
then
   if [ $# != 2 ]
   then
      echo "Usage : build.sh <Image name (e.g. websphere-liberty:kernel)> <Versioned image name (e.g. websphere-liberty:19.0.0.1-kernel)> <Dockerfile location>"
      exit 1
   else
      echo "Dockerfile location not provided, using ."
      dloc="."
   fi
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

$DOCKER build --no-cache=true -t $image -t $versionimage $dloc  > build_$tag.log

if [ $? = 0 ]
then
    echo "******************************************************************************"
    echo "              $image built successfully                                       "
    echo "******************************************************************************"
    exit 0
else
    echo " Build failed , exiting.........."
    exit 1
fi

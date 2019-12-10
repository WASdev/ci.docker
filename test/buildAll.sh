#!/bin/bash

#####################################################################################
#                                                                                   #
#  Script to build and test all websphere-liberty Docker images                     #
#                                                                                   #
#                                                                                   #
#  Usage : buildAll.sh							            # 
#                                                                                   #
#####################################################################################

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

arch=$(uname -p)
if [[ $arch == "ppc64le" || $arch == "s390x" ]]; then
  $DOCKER pull $arch/ibmjava:8-jre
  $DOCKER tag $arch/ibmjava:8-jre ibmjava:8-jre
fi

while read -r imageName versionImageName buildContextDirectory
do
  ./build.sh $imageName $versionImageName $buildContextDirectory && ./verify.sh $imageName

  if [ $? != 0 ]; then
    echo "Failed at image $imageName - exiting"
    exit 1
  fi

done < "images.txt"

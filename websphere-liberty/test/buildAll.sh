#!/bin/bash

#####################################################################################
#                                                                                   #
#  Script to build and test all websphere-liberty Docker images                     #
#                                                                                   #
#                                                                                   #
#  Usage : buildAll.sh							            # 
#                                                                                   #
#####################################################################################

arch=$(uname -p)
if [[ $arch == "ppc64le" || $arch == "s390x" ]]; then
  docker pull $arch/ubuntu:16.04
  docker tag $arch/ubuntu:16.04 ubuntu:16.04
fi

while read -r imageName buildContextDirectory
do
  ./build.sh $imageName $buildContextDirectory && ./verify.sh $imageName
   
  if [ $? != 0 ]; then
    echo "Failed at image $imageName - exiting"
    exit 1
  fi
    
done < "images.txt"

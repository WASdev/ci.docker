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
  docker pull $arch/ibmjava:8-jre
  docker tag $arch/ibmjava:8-jre ibmjava:8-jre
fi

while read -r imageName versionImageName buildContextDirectory
do
  ./build.sh $imageName $versionImageName $buildContextDirectory && ./verify.sh $imageName
   
  if [ $? != 0 ]; then
    echo "Failed at image $imageName - exiting"
    exit 1
  fi
    
done < "images.txt"

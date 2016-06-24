#!/bin/bash

#####################################################################################
#                                                                                   #
#  Script to push all websphere-liberty Docker images to repository                 #
#                                                                                   #
#                                                                                   #
#  Usage : pushAll.sh <repository> <latestTag>				            # 
#                                                                                   #
#####################################################################################

repository=$1
latestTag=$2

while IFS=': ' read -r imageName imageTag buildContextDirectory
do
  fullImageName="$imageName:$imageTag"
  repositoryImageName=$repository/$fullImageName
  echo "*** Pushing $repositoryImageName"
  docker tag $fullImageName $repositoryImageName
  docker push $repositoryImageName 

  if [ $? != 0 ]; then
    echo "Failed at image $fullImageName - exiting"
    exit 1
  fi

  if [ $imageTag == $latestTag ]; then
    latestRepositoryImageName="$repository/$imageName:latest"
    echo "*** Pushing $latestRepositoryImageName"
    docker tag $fullImageName $latestRepositoryImageName
    docker push $latestRepositoryImageName
  fi
    
done < "images.txt"

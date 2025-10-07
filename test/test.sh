#!/bin/bash

currentRelease=$1
test=$2

echo "Starting to test release $currentRelease"

# Builds up the build.sh call to build each individual docker image listed in images.txt
while read -r buildContextDirectory dockerfile repository imageTag imageTag2 imageTag3
do
    #Test the image
    testBuild="./build.sh --dir=$test --dockerfile=Dockerfile --tag=$test --from=$repository:$imageTag"
    echo "Running build script for test - $testBuild"
    eval $testBuild

    verifyCommand="./verify.sh $test"
    echo "Running verify script - $verifyCommand"
    eval $verifyCommand
  
  if [ $? != 0 ]; then
    echo "Failed at image $imageTag ($buildContextDirectory) - exiting"
    exit 1
  fi
done < "$currentRelease/images.txt"

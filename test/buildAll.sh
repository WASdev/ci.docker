#!/bin/bash

#####################################################################################
#                                                                                   #
#  Script to build and test all websphere-liberty Docker images                     #
#                                                                                   #
#                                                                                   #
#  Usage : buildAll.sh <Release Version>  						                              # 
#                                                                                   #
#####################################################################################


currentRelease=$1
readonly REPO="websphere-liberty"
readonly IMAGE_ROOT="../ga/latest"

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

$DOCKER pull registry.access.redhat.com/ubi8/ubi
## pull Dockerfile from ibmjava
mkdir java
wget https://raw.githubusercontent.com/ibmruntimes/ci.docker/master/ibmjava/8/jre/ubi/Dockerfile -O java/Dockerfile

## replace references to user 1001 as we need to build as root
sed -i.bak '/useradd -u 1001*/d' ./java/Dockerfile && sed -i.bak '/USER 1001/d' ./java/Dockerfile && rm java/Dockerfile.bak
$DOCKER build -t ibmjava:8-ubi java

while read -r imageName buildContextDirectory dockerfileName
do
  if [[ ! -z $dockerfileName ]]; then
    ./build.sh $imageName $buildContextDirectory $dockerfileName

    if [ $currentRelease == "../ga/latest" ]; then
      ./verify.sh --image=$imageName --repository=websphere-liberty
    fi
  else 
    ./build.sh $imageName $buildContextDirectory
  fi

  if [ $? != 0 ]; then
    echo "Failed at image $imageName - exiting"
    exit 1
  fi
done < $currentRelease/"images.txt"

tags=(kernel full)
for j in "${!tags[@]}"; do 
  echo "${currentRelease}"
  file_exts_ubi=(ubi.adoptopenjdk8 ubi.adoptopenjdk11 ubi.ibmjava8)
  tag_exts_ubi=(java8-openj9-ubi java11-openj9-ubi java8-ibmjava-ubi)

  for i in "${!tag_exts_ubi[@]}"; do
      docker_dir="${IMAGE_ROOT}/${tags[$j]}"
      full_path="${docker_dir}/Dockerfile.${file_exts_ubi[$i]}"
      if [[ -f "${full_path}" ]]; then
          build_tag="${REPO}:${tags[$j]}-${tag_exts_ubi[$i]}"

          echo "****** Building image ${build_tag}..."
          $DOCKER build --no-cache=true -t "${build_tag}" -f "${full_path}" "${docker_dir}"
      else
          echo "Could not find Dockerfile at path ${full_path}"
          exit 1
      fi
  done
done 
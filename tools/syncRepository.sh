#! /bin/bash
#########################################################################
#                                                                       #
# Sync the repositories                                                 # 
#                                                                       # 
# Usage :syncRepository.sh <kernel_version|beta> <target repository>    #
#                                                                       #
# Author : Kavitha                                                      #
#                                                                       #
#########################################################################

usage()
{
    echo "Usage:syncRepository.sh  <kernel_version|beta> <target repository>"
    echo "Example Usage - syncRepository.sh  kernel _8.5.5.7 ibmcom"
    exit 1
}

if [ $# -gt 2 ]
then
    usage 
elif [ $# = 2 ]
then
	tag=`echo $1 | cut -d "_" -f1`
    	version=`echo $1 | cut -d "_" -f2`
    	target=$2
        echo "Tag is $tag and version is $version and target repository is $target ."
elif [ $# != 2 ]
then
    if [ $# != 1 ]
    then
	usage
    else
	tag=`echo $1 | cut -d "_" -f1`
    	version=`echo $1 | cut -d "_" -f2`
	echo "Tag is $tag and  version is $version , using default target ibmcom "
        target="ibmcom"
    fi
fi


pullAndSync()
{
    target=$1
    tag=$2
    echo "Pulling websphere-liberty:$tag image ........"
    docker pull websphere-liberty:$tag
    if [ $? = 0 ]
    then
    	echo "Syncing websphere-liberty:$tag image......"
    	docker rmi $target/websphere-liberty:$tag
    	docker tag -f websphere-liberty:$tag $target/websphere-liberty:$tag
    	docker push $target/websphere-liberty:$tag
    	if [ $?  = 0 ]
    	then
        	echo "websphere-liberty:$tag image pushed successfully to $target repository."
    	else
        	echo "websphere-liberty:$tag image push failed , check the target repository provided."
        	echo "Target repository is valid,  check user has access to push."
    	fi  
    else
        echo "Pulling websphere-liberty:common image failed , exiting........."
        exit 1
    fi  

}

if [ $tag = "kernel" ]
then
    pullAndSync $target kernel
    pullAndSync $target $version-kernel
    pullAndSync $target common
    pullAndSync $target $version-common
    pullAndSync $target webProfile6
    pullAndSync $target $version-webProfile6
    pullAndSync $target webProfile7
    pullAndSync $target $version-webProfile7
    pullAndSync $target javaee7
    pullAndSync $target $version-javaee7
    pullAndSync $target latest
    pullAndSync $target 8.5.5
elif [ $tag = "beta" ]
then
    pullAndSync $target beta
fi




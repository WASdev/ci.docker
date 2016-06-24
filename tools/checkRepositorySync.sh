#! /bin/bash
############################################################################
#                                                                          # 
#  Script to check whether official & ibmcom repository are in sync        #
#                                                                          #  
#  Usage :checkRepositorySync.sh <kernel_version|beta> <target respository># 
#                                                                          #
#  Author : Kavitha                                                        #
#                                                                          #
############################################################################

usage()
{
    echo "Usage : checkRepositorySync.sh <kernel_version|beta> <target respository>"
    echo "Example usage -  checkRepositorySync.sh kernel_8.5.5.7 ibmcom"
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
    echo "Target Repository is $target and tag is $tag ."
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

docker pull websphere-liberty:$tag
if [ $? = 0 ]
then
        id=`docker inspect --format='{{.Id}}' websphere-liberty:$tag`
	docker pull $target/websphere-liberty:$tag
        if [ $? != 0 ]
        then
           echo "Check the target repository provided."
           usage  
           exit 1
        fi
	tid=`docker inspect --format='{{.Id}}' $target/websphere-liberty:$tag`
	if [ $id = $tid ]
	then
   		echo "Images are in sync, exiting ..........."
	else
   	        echo "Images are not in Sync , Sync the repository."
    		syncRepository.sh $1 $target
        fi
else
        echo "Check the tag provided."
        usage 
fi 


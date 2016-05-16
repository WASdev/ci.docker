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
dloc=$2

tag=`echo $image | cut -d ":" -f2`

test=test
cname=$tag$test
arch=`uname -p`

if [ $# != 2 ]
then
   if [ $# != 1 ]
   then
      echo "Usage : build.sh <Image name> <Dockerfile location>"
      exit 1
   else
      echo "Dockerfile location not provided, using ."
      dloc="."
   fi
fi

if [[ $arch == *"ppc"* ]]
then
   sed -i -e "s|^\(FROM\s*\)|\1ppc64le/|" $dloc/Dockerfile
   image="ppc64le/$image"
elif [[ $arch == *"s390x"* ]]
then
   sed -i -e "s|^\(FROM\s*\)|\1s390x/|" $dloc/Dockerfile
   image="s390x/$image"
fi

echo "******************************************************************************"
echo "           Starting docker build for $image                                   "
echo "******************************************************************************"

docker build --no-cache=true -t $image $dloc  > build_$tag.log

if [ $? = 0 ]
then
    echo "******************************************************************************"
    echo "              $image built successfully                                       "
    echo "******************************************************************************"
else
    echo " Build failed , exiting.........."
    exit 1
fi

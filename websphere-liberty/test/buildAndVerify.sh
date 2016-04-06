#! /bin/bash
#####################################################################################
#                                                                                   #
#  Script to build docker image and verify the image                                #
#                                                                                   #
#                                                                                   #
#  Usage : buildAndVerify.sh <Image name> <Dockerfile location>                     #
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
      echo "Usage : buildAndVerify.sh <Image name> <Dockerfile location>"
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

   # Switch to Debian
   sed -i -e "s|^\(FROM\s*s390x/\)ubuntu:14.04|\1debian|" $dloc/Dockerfile
   sed -i -e "s|\(apt-get install.*wget unzip\)|\1 ca-certificates|" $dloc/Dockerfile
fi

echo "******************************************************************************"
echo "           Starting docker build for $image                                   "
echo "******************************************************************************"

docker build --no-cache=true -t $image $dloc  > build_$tag.log

cleanup()
{

   echo "------------------------------------------------------------------------------"
   echo "Starting Cleanup  "

   docker ps | grep --quiet $cname
   if [ $? = 0 ]
   then
        echo "Stopping Container $cname"
        docker stop $cname
        sleep 12
        docker logs $cname | grep -i CWWKE0036I
        if ! [ $? = 0 ]
        then
             echo "Container didn't stop cleanly. Check stop_$tag.log for details."
             docker logs $cname > stop_$tag.log
        fi
   fi

   echo "Removing Container $cname"
   docker rm $cname
   echo "Cleanup Completed "
   echo "------------------------------------------------------------------------------"
}

test1()
{
   echo "******************************************************************************"
   echo "                  Executing  test1  - Container Runs                 "
   echo "******************************************************************************"

   docker ps -a | grep -i $cname
   if [ $? = 0 ]
   then
        cleanup
   fi

   cid=`docker run --name $cname -d -t $image `
   scid=${cid:0:12}
   sleep 10
   if [ $scid != "" ]
   then
         rcid=`docker ps -q | grep -i $scid `
         if [ rcid != " " ]
         then
               sleep 60
               docker logs $cname | grep -i CWWKF0011I

               if [ $? = 0 ]
               then
                    echo "Product version is"
                    docker exec $cname /opt/ibm/wlp/bin/productInfo version
                    docker logs $cname | grep --quiet ERROR
                    if [ $? = 0 ]
                    then
                         echo "The container has started successfully but there are errors:"
                         docker logs $cname | grep ERROR
                         echo "Exiting"
                         cleanup
                         exit 1
                    fi
                    cleanup
               else
                        echo " Server not started , exiting "
                        cleanup
                        exit 1
               fi
         else
               echo "Container $cname not running, exiting"
               cleanup
               exit 1
         fi
   else
         echo "Container not started successfully, exiting"
         cleanup
         exit 1
   fi

}

test2()
{
   echo "******************************************************************************"
   echo "                     Executing  test2  - feature check                        "
   echo "******************************************************************************"

   docker ps -a | grep -i $cname
   if [ $? = 0 ]
   then
        cleanup
   fi

   docker run --name $cname -t $image /opt/ibm/wlp/bin/productInfo featureInfo | cut -d " " -f1 > features_$tag.txt
   diff -u features_$tag.txt $tag.txt > diff.txt

   if [ $? = 0 ]
   then
   	echo "$tag features are installed"
   else
        echo "$tag feature info doesn't match, exiting"
        echo `cat diff.txt`
        cleanup
        exit 1
   fi

   cleanup

}


grep -i "Successfully built" build_$tag.log

if [ $? = 0 ]
then
    echo "******************************************************************************"
    echo "              $image built successfully                                       "
    echo "******************************************************************************"
    test1
    if [ $? = 0 ]
    then
    	echo "******************************************************************************"
    	echo "                       Test1 Completed Successfully                           "
    	echo "******************************************************************************"
    fi

    if [ $tag != "kernel" ]
    then
    	test2
        if [ $? = 0 ]
    	then
        	echo "******************************************************************************"
        	echo "                      Test2 Completed Successfully                            "
        	echo "******************************************************************************"
    	fi

    fi
else
    echo " Build failed , exiting.........."
    exit 1
fi

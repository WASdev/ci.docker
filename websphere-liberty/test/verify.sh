#! /bin/bash
#####################################################################################
#                                                                                   #
#  Script to verify a WebSphere Liberty image                                       #
#                                                                                   #
#                                                                                   #
#  Usage : verify.sh <Image name>                                                   #
#                                                                                   #
#####################################################################################

image=$1
tag=`echo $image | cut -d ":" -f2`
cname="${tag}test"

testContainerRuns()
{
   cid=$(docker run -d $image)
   if [ $? != 0 ]
   then
      echo "Failed to run container; exiting"
      exit 1
   fi

   while [ $(docker inspect -f {{.State.Running}} $cid) = "true" ]
   do
      docker logs $cid | grep "ERROR"
      if [ $? = 0 ]
      then
         echo "Errors found in logs for container; exiting"
         docker rm -f $cid
         exit 1
      fi
      docker logs $cid | grep -i "CWWKF0011I"
      if [ $? = 0 ]
      then
         echo "Container started successfully"

         docker stop $cid
         if [ $? != 0 ]
         then
            echo "Container failed to stop cleanly; exiting"
            docker rm -f $cid
            exit 1
         fi

         docker logs $cid | grep -i "CWWKE0036I"
         if [ $? != 0 ]
         then
            echo "Liberty failed to stop cleanly; exiting"
            docker logs $cid
            docker rm -f $cid
            exit 1
         fi

         docker rm -f $cid
         return
      fi
   done

   echo "Container exited prematurely; exiting"
   docker logs $cid
   docker rm -f $cid
   exit 1
}

testFeatureList()
{
   if [ $tag = "kernel" ]
   then
       return
   fi

   features=$(docker run --rm $image /opt/ibm/wlp/bin/productInfo featureInfo | cut -d " " -f1)
   comparison=$(diff -u <(echo "$features") "$tag.txt")

   if [ $? = 0 ]
   then
   	echo "Correct features installed"
   else
        echo "Incorrect features installed, exiting"
        echo "$comparison"
        exit 1
   fi
}

tests=$(declare -F | cut -d" " -f3 | grep "test")
for name in $tests
do
   echo "******************************************************************************"
   echo "                     Executing $name"
   echo "******************************************************************************"
   eval $name
   echo "******************************************************************************"
   echo "                       $name Completed Successfully                           "
   echo "******************************************************************************"
done

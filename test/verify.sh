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

waitForServerStart()
{
   cid=$1
   count=${2:-1}
   end=$((SECONDS+120))
   while (( $SECONDS < $end && $(docker inspect -f {{.State.Running}} $cid) == "true" ))
   do
      result=$(docker logs $cid |& grep "CWWKF0011I" | wc -l)
      if [ $result = $count ]
      then
         return 0
      fi
   done

   echo "Liberty failed to start the expected number of times"
   return 1
}

testLibertyStarts()
{
   cid=$(docker run -d $image)
   if [ $? != 0 ]
   then
      echo "Failed to run container; exiting"
      exit 1
   fi

   waitForServerStart $cid
   if [ $? != 0 ]
   then
      echo "Liberty failed to start; exiting"
      exit 1
   fi

   docker logs $cid |& grep "ERROR"
   if [ $? = 0 ]
   then
      echo "Errors found in logs for container; exiting"
      docker rm -f $cid >/dev/null
      exit 1
   fi

   docker rm -f $cid >/dev/null
}

testLibertyStops()
{
   cid=$(docker run -d $image)
   waitForServerStart $cid

   result=$(docker stop $cid)
   if [ $? != 0 ]
   then
      echo "Container failed to stop cleanly: $result; exiting"
      docker rm -f $cid >/dev/null
      exit 1
   fi

   docker logs $cid | grep -iq "CWWKE0036I"
   if [ $? != 0 ]
   then
      echo "Liberty failed to stop cleanly; exiting"
      docker logs $cid
      docker rm -f $cid >/dev/null
      exit 1
   fi

   docker rm -f $cid >/dev/null
}

testLibertyStopsAndRestarts()
{
   cid=$(docker run -d $image)
   waitForServerStart $cid
   docker stop $cid >/dev/null

   docker start $cid >/dev/null
   if [ $? != 0 ]
   then
      echo "Failed to run container; exiting"
      exit 1
   fi

   waitForServerStart $cid 2
   if [ $? != 0 ]
   then
      echo "Server failed to restart; exiting"
      exit 1
   fi

   docker logs $cid |& grep "ERROR"
   if [ $? = 0 ]
   then
      echo "Errors found in logs for container; exiting"
      docker rm -f $cid >/dev/null
      exit 1
   fi

   docker rm -f $cid >/dev/null
}


testFeatureList()
{
   if [ $tag = "kernel" ]
   then
      return
   fi

   features=$(docker run --rm $image /opt/ibm/wlp/bin/productInfo featureInfo | cut -d " " -f1)
   scriptDir="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
   comparison=$(comm -3 -2 "$scriptDir/$tag.txt" <(echo "$features"))

   if [ "$comparison" != "" ]
   then
      echo "Incorrect features installed, exiting"
      echo "$comparison"
      exit 1
   fi
}

testWorkareaRemoved()
{
   numberOfOccurences=$(docker run --rm $image find . -type d -name workarea | wc -l)

   if [ $numberOfOccurences != 0 ]
   then
      echo "Image $image contains workarea"
      exit 1
   fi
}

tests=$(declare -F | cut -d" " -f3 | grep "test")
for name in $tests
do
   echo "*** $name - Executing"
   eval $name
   echo "*** $name - Completed successfully"
done

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
      result=$(docker logs $cid 2>&1 | grep "CWWKF0011I" | wc -l)
      if [ $result = $count ]
      then
         return 0
      fi
   done

   echo "Liberty failed to start the expected number of times"
   return 1
}

waitForServerStop()
{
   cid=$1
   end=$((SECONDS+120))
   while (( $SECONDS < $end ))
   do
      result=$(docker logs $cid 2>&1 | grep "CWWKE0036I" | wc -l)
      if [ $result = 1 ]
      then
         return 0
      fi
   done

   echo "Liberty failed to stop within a reasonable time"
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

   docker logs $cid 2>&1 | grep "ERROR"
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

   waitForServerStop $cid
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

   docker logs $cid 2>&1 | grep "ERROR"
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
   version=$(docker run --rm $image sh -c 'echo $LIBERTY_VERSION')
   echo "Checking features for $image against version $version"

   case $tag in
     microProfile)
       YAML_KEY='microProfile1'
       ;;
     webProfile6)
       YAML_KEY='uri'
       ;;
     beta)
       YAML_KEY='webProfile8'
       ;;
     *)
       YAML_KEY=$tag
   esac

   LIBERTY_URL=$(wget -qO- https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/index.yml | grep $version -A 7 | sed -n "s/\s*$YAML_KEY:\s//p" | tr -d '\r' | head -n 1)
   if [ -z $LIBERTY_URL ]; then
     echo "WARNING: download not found - unable to verify features"
     return
   fi

   if [[ $LIBERTY_URL == *jar ]]; then
     required_features=$(docker run --rm ibmjava:8-jre-alpine sh -c \
       "wget -q $LIBERTY_URL -U UA-IBM-WebSphere-Liberty-Docker -O /tmp/wlp.jar
java -jar /tmp/wlp.jar --acceptLicense /opt/ibm > /dev/null
/opt/ibm/wlp/bin/productInfo featureInfo" | cut -d ' ' -f1 | sort)
   else
     required_features=$(docker run --rm ibmjava:8-jre-alpine sh -c \
       "wget -q $LIBERTY_URL -U UA-IBM-WebSphere-Liberty-Docker -O /tmp/wlp.zip
unzip -q /tmp/wlp.zip -d /opt/ibm
/opt/ibm/wlp/bin/productInfo featureInfo" | cut -d ' ' -f1 | sort)
   fi

   actual_features=$(docker run --rm $image productInfo featureInfo | cut -d " " -f1 | sort)

   additional_features=$(comm -1 -3 <(echo "$required_features") <(echo "$actual_features"))
   if [ "$additional_features" != "" ]; then
     echo "Additional features installed"
     echo "$additional_features"
   fi

   missing_features=$(comm -2 -3 <(echo "$required_features") <(echo "$actual_features"))
   if [ "$missing_features" != "" ]; then
     echo "Missing features, exiting"
     echo "$missing_features"
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

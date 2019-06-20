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

disabledTestLibertyStarts()
{
   if [ "$1" == "OpenShift" ]; then
      timestamp=$(date '+%Y/%m/%d %H:%M:%S')
      echo "$timestamp *** testLibertyStarts on OpenShift"
      cid=$(docker run -d -u 1005:0 $image)
   else
      cid=$(docker run -d $image)
   fi
   
   if [ $? != 0 ]
   then
      echo "Failed to run container; exiting"
      exit 1
   fi

   waitForServerStart $cid
   if [ $? != 0 ]
   then
      echo "Liberty failed to start; exiting"
      docker logs $cid
      docker rm -f $cid >/dev/null
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
   if [ "$1" == "OpenShift" ]; then
      timestamp=$(date '+%Y/%m/%d %H:%M:%S')
      echo "$timestamp *** testLibertyStops on OpenShift"
      cid=$(docker run -d -u 1005:0 $image)
   else
      cid=$(docker run -d $image)
   fi

   if [ $? != 0 ]
   then
      echo "Failed to run container; exiting"
      exit 1
   fi
   waitForServerStart $cid
   if [ $? != 0 ]
   then
      echo "Liberty failed to start; exiting"
      docker logs $cid
      docker rm -f $cid >/dev/null
      exit 1
   fi
   sleep 30
   docker stop $cid >/dev/null
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
      echo "DEBUG START full log"
      docker logs $cid
      echo "DEBUG END full log"
      docker rm -f $cid >/dev/null
      exit 1
   fi

   docker rm -f $cid >/dev/null
}

testLibertyStopsAndRestarts()
{
   if [ "$1" == "OpenShift" ]; then
      timestamp=$(date '+%Y/%m/%d %H:%M:%S')
      echo "$timestamp *** testLibertyStopsAndRestarts on OpenShift"
      cid=$(docker run -d -u 1005:0 $security_opt $image)
   else
      cid=$(docker run -d $security_opt $image)
   fi
   
   if [ $? != 0 ]
   then
      echo "Failed to run container; exiting"
      exit 1
   fi
   
   waitForServerStart $cid
   if [ $? != 0 ]
   then
      echo "Liberty failed to start; exiting"
      docker logs $cid
      docker rm -f $cid >/dev/null
      exit 1
   fi
   sleep 30
   docker stop $cid >/dev/null
   if [ $? != 0 ]
   then
      echo "Error stopping container or server; exiting"
      docker logs $cid
      docker rm -f $cid >/dev/null
      exit 1
   fi

   docker start $cid >/dev/null
   if [ $? != 0 ]
   then
      echo "Failed to rerun container; exiting"
      docker logs $cid
      docker rm -f $cid >/dev/null
      exit 1
   fi

   waitForServerStart $cid 2
   if [ $? != 0 ]
   then
      echo "Server failed to restart; exiting"
      docker logs $cid
      docker rm -f $cid >/dev/null
      exit 1
   fi

   docker logs $cid 2>&1 | grep "ERROR"
   if [ $? = 0 ]
   then
      echo "Errors found in logs for container; exiting"
      echo "DEBUG START full log"
      docker logs $cid
      echo "DEBUG END full log"
      docker rm -f $cid >/dev/null
      exit 1
   fi

   docker rm -f $cid >/dev/null
}


disabledTestFeatureList()
{
   if [ "$1" == "OpenShift" ]; then
      timestamp=$(date '+%Y/%m/%d %H:%M:%S')
      echo "$timestamp *** testFeatureList on OpenShift"
      version=$(docker run --rm -u 1005:0 $image sh -c 'echo $LIBERTY_VERSION')
   else
      version=$(docker run --rm $image sh -c 'echo $LIBERTY_VERSION')
   fi
   echo "Checking features for $image against version $version"

   case $tag in
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
       "apk add --no-cache wget > /dev/null
wget -q $LIBERTY_URL -U UA-IBM-WebSphere-Liberty-Docker -O /tmp/wlp.jar > /dev/null
java -jar /tmp/wlp.jar --acceptLicense /opt/ibm > /dev/null
/opt/ibm/wlp/bin/productInfo featureInfo" | cut -d ' ' -f1 | sort)
   else
     if [[ $tag == "springBoot1" || $tag == "springBoot2" ]]; then
       # Ignore missing archives for Spring Boot tags.
       required_features="IGNORE"
     else
       required_features=$(docker run --rm ibmjava:8-jre-alpine sh -c \
       "apk add --no-cache wget > /dev/null
wget -q $LIBERTY_URL -U UA-IBM-WebSphere-Liberty-Docker -O /tmp/wlp.zip > /dev/null
unzip -q /tmp/wlp.zip -d /opt/ibm
/opt/ibm/wlp/bin/productInfo featureInfo" | cut -d ' ' -f1 | sort)
     fi
   fi

   actual_features=$(docker run --rm $image productInfo featureInfo | cut -d " " -f1 | sort)

   additional_features=$(comm -1 -3 <(echo "$required_features") <(echo "$actual_features"))
   if [ "$additional_features" != "" ]; then
     echo "Additional features installed"
     echo "$additional_features"
   fi

   missing_features=$(comm -2 -3 <(echo "$required_features") <(echo "$actual_features"))
   if [ "$missing_features" != "" ]; then
    if [[ $tag == "webProfile8" || $tag == "javaee8" || $tag == "springBoot1" || $tag == "springBoot2" ]]; then
      # Ignore the missing features for EE8 and Spring Boot tags
      echo "Missing features, IGNORE"
      echo "$missing_features"
    else
      echo "Missing features, exiting"
      echo "$missing_features"
      exit 1
    fi
   fi
}

testDockerOnOpenShift()
{
   testLibertyStops "OpenShift"
   testLibertyStopsAndRestarts "OpenShift"
}

tests=$(declare -F | cut -d" " -f3 | grep "test")
for name in $tests
do
   timestamp=$(date '+%Y/%m/%d %H:%M:%S')
   echo "$timestamp *** $name - Executing"
   eval $name
   timestamp=$(date '+%Y/%m/%d %H:%M:%S')
   echo "$timestamp *** $name - Completed successfully"
done

#! /bin/sh
#####################################################################################
#                                                                                   #
#  Script to build docker image and verify the image                                #
#                                                                                   #
#                                                                                   #
#  Usage : buildAndVerify.sh <Image name> <Dockerfile location>                     # 
#                                                                                   #
#  Author : Kavitha                                                                 #
#                                                                                   #
#####################################################################################

image=$1
dloc=$2

tag=`echo $image | cut -d ":" -f2`

test=test
cname=$tag$test

if [ $# != 2 ]
then
   if [ $# != 1 ]
   then  
      echo "Usage : buildAndVerify.sh <Image name> <Dockerfile location> "
      exit 1
   else
      echo "Dockerfile location not provided, using . "
      dloc="."
   fi
fi  

echo "******************************************************************************"
echo "           Starting docker build for $image                                   "
echo "******************************************************************************"

docker build --no-cache=true -t $image $dloc

cleanup()
{

   echo "------------------------------------------------------------------------------" 
   echo "Starting Cleanup  "
   echo "Stopping Container $cname"
   docker stop $cname
   echo "Removing Container $cname"
   docker rm $cname
   echo "Cleanup Completed "
   echo "------------------------------------------------------------------------------"
} 
test1()
{
   echo "******************************************************************************"
   echo "                Executing  test1  - Without License Acceptance                "
   echo "******************************************************************************"

   docker ps -a | grep -i $cname
   if [ $? == 0 ]
   then
        cleanup
   fi

   cid=`docker run --name $cname -d -t $image `
   if [ $cid != "" ]
   then
        echo "Container $cname created "
        echo "Reviewing Container logs" 
        docker logs $cname | grep -i "Set environment variable LICENSE=accept to indicate acceptance of license terms and conditions."
   	if [ $? == 0 ]
   	then 
                docker ps -q | grep -i $cname
                if [ $? == 0 ]
                then
                        echo "Container expecting license acceptance  "
                	cleanup
                else
                        echo "Container test exited , expecting license acceptance  "
                        echo "Removing container $cname"
                        docker rm $cname
                fi
        else
                echo "Test failed no license acceptance statement in the logs"
                cleanup
                exit 1
        fi
   else
        echo "Container not created successfully, staring cleanup "
        cleanup
        exit 1
   fi
   
}

test2()
{
   echo "******************************************************************************"
   echo "                  Executing  test2  - With License Acceptance                 "
   echo "******************************************************************************"

   docker ps -a | grep -i $cname
   if [ $? == 0 ]
   then
        cleanup
   fi

   cid=`docker run --name $cname -e LICENSE=accept -d -t $image `
   scid=${cid:0:12}
   sleep 10
   if [ $scid != "" ]
   then
         rcid=`docker ps -q | grep -i $scid `
         if [ rcid != " " ]
         then
               sleep 20
               docker logs $cname | grep -i CWWKF0011I 

               if [ $? == 0 ]
               then
      			echo "Product version is"
                        docker exec $cname /opt/ibm/wlp/bin/productInfo version
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

test3()
{
   echo "******************************************************************************"
   echo "                     Executing  test3  - feature check                        "
   echo "******************************************************************************"

   docker ps -a | grep -i $cname
   if [ $? == 0 ]
   then
        cleanup
   fi

   docker run --name $cname -e LICENSE=accept -t $image /opt/ibm/wlp/bin/productInfo featureInfo | cut -d " " -f1 > features_$tag.txt
   diff -u features_$tag.txt $tag.txt > diff.txt

   if [ $? == 0 ]
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

if [ $? == 0 ]
then
    echo "******************************************************************************"
    echo "              $image built successfully                                       "
    echo "******************************************************************************"
    test1
    if [ $? == 0 ]
    then
    	echo "******************************************************************************"
    	echo "                       Test1 Completed Successfully                           "
    	echo "******************************************************************************"
    fi
    test2
    
    if [ $? == 0 ]
    then
        echo "******************************************************************************"
        echo "                       Test2 Completed Successfully                           "
        echo "******************************************************************************"
    fi

    if [ $tag != "kernel" ]
    then
    	test3
        if [ $? == 0 ]
    	then
        	echo "******************************************************************************"
        	echo "                      Test3 Completed Successfully                            "
        	echo "******************************************************************************"
    	fi

    fi
fi

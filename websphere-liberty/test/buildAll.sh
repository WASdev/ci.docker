#!/bin/bash

#####################################################################################
#                                                                                   #
#  Script to build docker image and test all images                              	#
#                                                                                   #
#                                                                                   #
#  Usage : buildAll.sh input.txt                									# 
#                                                                                   #
#####################################################################################

filename="$1"
while read -r line
do
    image=`echo $line | cut -d " " -f1`
    location=`echo $line  | cut -d " " -f2`
    ./build.sh $image $location && ./verify.sh $image
   
    if [ $? != 0 ]
    then
        echo " No point in continuing, exiting ........"
        exit 1
    fi
    
done < "$filename"

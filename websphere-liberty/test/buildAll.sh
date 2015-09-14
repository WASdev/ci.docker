#!/bin/sh

filename="$1"
while read -r line
do
    image=`echo $line | cut -d " " -f1`
    location=`echo $line  | cut -d " " -f2`
    sh buildAndVerify.sh $image $location
   
    if [ $? != 0 ]
    then
        echo " No point in continuing, exiting ........"
        exit 1
    fi
    
done < "$filename"

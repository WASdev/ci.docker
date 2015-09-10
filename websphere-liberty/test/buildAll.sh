#!/bin/sh

filename="$1"
while read -r line
do
    image=`echo $line | cut -d " " -f1`
    location=`echo $line  | cut -d " " -f2`
    ./buildAndVerify.sh $image $location
    
done < "$filename"

#!/bin/bash

echo "Hello from the update.sh script!"

for file in $(find ./ga/investigateActions -type f); do
   echo $file
done

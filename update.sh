#!/bin/bash

echo "Hello from the update.sh script!"

NEW_VERSION=23.0.0.66
OLD_VERSION=23.0.0.11

echo "Copying latest files to $NEW_VERSION"
cp -r ./ga/latest ./ga/$NEW_VERSION

# Perform the actual swaps by doing a search of the directory the script is running on
searchString="$OLD_VERSION"
for file in $(find ./ga/$NEW_VERSION -type f | xargs egrep -l "$searchString"); do
   echo "Processing $file";

   # Perform the swap for each version string/label/SHA in order
   echo "--Performing subsitutions";
   sed -i'.bak' -e "s/$OLD_VERSION/$NEW_VERSION/" $file;

    # Clean up temp files
    echo "--Removing temp files"
    rm $file.bak

    echo;
done

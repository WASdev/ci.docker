#!/bin/bash

echo "Hello from the update.sh script!"

NEW_VERSION=23.0.0.66
OLD_VERSION=23.0.0.11
OLD_SHORT_VERSION=11
BUILD_LABEL=12345

echo "Copying latest files to $NEW_VERSION"
cp -r ./ga/latest ./ga/$NEW_VERSION

# Perform the actual swaps by doing a search of the directory the script is running on
searchString="$OLD_VERSION"
for file in $(find ./ga/$NEW_VERSION -type f | xargs egrep -l "$searchString"); do
   echo "Processing $file";

   # Perform the swap for each version string/label/SHA in order
   echo "--Performing subsitutions";
   sed -i'.bak' -e "s/$OLD_VERSION/$NEW_VERSION/" $file;
   sed -i'.bak' -e "s/LIBERTY_BUILD_LABEL=*/LIBERTY_BUILD_LABEL=$BUILD_LABEL/g" $file;
   sed -i'.bak' -e "s#ARG PARENT_IMAGE=icr.io/appcafe/websphere-liberty:kernel#ARG PARENT_IMAGE=icr.io/appcafe/websphere-liberty:$NEW_VERSION-kernel#g" $file;
   sed -i'.bak' -e "s#FROM websphere-liberty:kernel#FROM websphere-liberty:$NEW_VERSION-kernel#g" $file;

    # Clean up temp files
    echo "--Removing temp files"
    rm $file.bak

    cp ga/$OLD_VERSION/images.txt ga/$NEW_VERSION/images.txt;
    sed -i'.bak' -e "s/$OLD_VERSION/$NEW_VERSION/g" ga/$NEW_VERSION/images.txt;
    rm ga/$NEW_VERSION/images.txt.bak;

    if [[ $(( $OLD_SHORT_VERSION % 3 )) -eq 0 ]]
    then
        :
    else
        rm -rf ga/$OLD_VERSION
    fi

    echo "Done processing new file updates!";
done

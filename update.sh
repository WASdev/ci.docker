#!/bin/bash

echo "Hello from the update.sh script!"
echo $(date)

. ./vNext.properties

# Try to propagate this to the workflow environment?
export NEW_VERSION=$NEW_VERSION;

echo "Copying latest files to $NEW_VERSION"
cp -r ./ga/latest ./ga/$NEW_VERSION

# Perform the substitutions by searching in newly created directory
for file in $(find ./ga/$NEW_VERSION -name Dockerfile.*); do
   echo "Processing $file";

   # Perform the swap for each version string/label/SHA in order
   sed -i'.bak' -e "s/$OLD_VERSION/$NEW_VERSION/" $file;
   sed -i'.bak' -e "s/ARG LIBERTY_BUILD_LABEL=.*/ARG LIBERTY_BUILD_LABEL=$BUILD_LABEL/g" $file;
   sed -i'.bak' -e "s/ARG PARENT_IMAGE=icr.io\/appcafe\/websphere-liberty:kernel/ARG PARENT_IMAGE=icr.io\/appcafe\/websphere-liberty:$NEW_VERSION-kernel/g" $file;
   sed -i'.bak' -e "s/FROM websphere-liberty:kernel/FROM websphere-liberty:$NEW_VERSION-kernel/g" $file;

    # Clean up temp files
    rm $file.bak

done

cp ./ga/$OLD_VERSION/images.txt ./ga/$NEW_VERSION/images.txt;
sed -i'.bak' -e "s/$OLD_VERSION/$NEW_VERSION/g" ./ga/$NEW_VERSION/images.txt;
rm ./ga/$NEW_VERSION/images.txt.bak;

if [[ $(( $OLD_SHORT_VERSION % 3 )) -eq 0 ]]
  then
      :
  else
      rm -rf ./ga/$OLD_VERSION
  fi

echo "Done processing new file updates!";

#!/bin/bash

echo "Hello from the update.sh script!"
echo $(date)

# Set variables to the positional parameters
OLD_VERSION=$1
NEW_VERSION=$2
BUILD_LABEL=$3

# See if NEW_VERSION and OLD_VERSION fit expected pattern.
if [[ $OLD_VERSION =~ 2[3-9]\.0\.0\.[0-9]+ && $NEW_VERSION =~ 2[3-9]\.0\.0\.[0-9]+ ]];
then
   echo "$OLD_VERSION and $NEW_VERSION matches expected version format."
else
   echo "Either $OLD_VERSION or $NEW_VERSION does not fit expected version format."
   exit 1;
fi

# Get last digit of old version
OLD_SHORT_VERSION=${OLD_VERSION:7}

echo "OLD_VERSION = $OLD_VERSION"
echo "NEW_VERSION = $NEW_VERSION"
echo "BUILD_LABEL = $BUILD_LABEL"
echo "OLD_SHORT_VERSION = $OLD_SHORT_VERSION"

echo "Copying latest files to $NEW_VERSION"
cp -r ./ga/latest ./ga/$NEW_VERSION

# Perform the substitutions in both latest and $NEW_VERSION directories.
for file in $(find ./ga/latest ./ga/$NEW_VERSION -name Dockerfile.*); do
   echo "Processing $file";

   sed -i'.bak' -e "s/$OLD_VERSION/$NEW_VERSION/" $file;
   sed -i'.bak' -e "s/ARG LIBERTY_BUILD_LABEL=.*/ARG LIBERTY_BUILD_LABEL=$BUILD_LABEL/g" $file;

   # Do these substitutions only in $NEW_VERSION, not latest.
   if [[ "$file" == "./ga/$NEW_VERSION/"* ]];
   then
      sed -i'.bak' -e "s/ARG PARENT_IMAGE=icr.io\/appcafe\/websphere-liberty:kernel/ARG PARENT_IMAGE=icr.io\/appcafe\/websphere-liberty:$NEW_VERSION-kernel/g" $file;
      sed -i'.bak' -e "s/FROM websphere-liberty:kernel/FROM websphere-liberty:$NEW_VERSION-kernel/g" $file;
   fi
   
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

# Finally, comment out "ga/*/*/resources/*" in .gitignore so
# newly created $NEW_VERSION/full/resources and $NEW_VERSION/kernel/resources 
# directories can be committed and pushed.
sed -i'.bak' -e "s/ga\/\*\/\*\/resources\/\*/#ga\/\*\/\*\/resources\/\*/g" .gitignore
rm ./.gitignore.bak

echo "Done performing file updates.";

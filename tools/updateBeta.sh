#!/bin/bash

# Update the Dockerfile and generate the new feature lists

# Get most recent version
version=$(wget -qO- https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/index.yml | egrep '[0-9]{4}\.[0-10]{1,2}\.0_0*' | sed 's/://' | sort -r | head -1)

# Check if the beta Liberty version is up to date
count=$(cat ../beta/Dockerfile | grep "ENV LIBERTY_VERSION $version" | wc -l)
if [ $count -eq 0 ]
    then

    # Replace version in the Dockerfile
    echo "Updating Dockerfile"
    sed -i -r -e "s@ENV LIBERTY_VERSION.*@ENV LIBERTY_VERSION $version@" ../beta/Dockerfile

    # Generate feature list
    echo "Generating feature list for testing"
    docker build -t betafeatures ../beta
    docker run --rm betafeatures /opt/ibm/wlp/bin/productInfo featureInfo | cut -d " " -f1 > ../test/beta.txt
fi

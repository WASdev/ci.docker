#!/bin/bash

##Define variables for XML snippets source and target paths
SNIPPETS_SOURCE=/opt/ibm/helpers/build/configuration_snippets
SNIPPETS_TARGET=/config/configDropins/overrides

#Check for each Liberty value-add functionality

#if [ "$MONITORING" == "true" ]
#then
# cp $SNIPPETS_SOURCE/monitoring.xml $SNIPPETS_TARGET/monitoring.xml
#fi

# Install needed features
installUtility install --acceptLicense defaultServer
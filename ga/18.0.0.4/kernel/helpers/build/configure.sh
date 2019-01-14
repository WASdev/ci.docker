#!/bin/bash

##Define variables for XML snippets source and target paths
WLP_INSTALL_DIR=/opt/ibm/wlp
SHARED_CONFIG_DIR=${WLP_INSTALL_DIR}/usr/shared/config
SHARED_RESOURCE_DIR=${WLP_INSTALL_DIR}/usr/shared/resources

SNIPPETS_SOURCE=/opt/ibm/helpers/build/configuration_snippets
SNIPPETS_TARGET=/config/configDropins/overrides



#Check for each Liberty value-add functionality

#if [ "$MONITORING" == "true" ]
#then
# cp $SNIPPETS_SOURCE/monitoring.xml $SNIPPETS_TARGET/monitoring.xml
#fi

if [ "${HZ_SESSION_CACHE}" == "client" ] || [ "${HZ_SESSION_CACHE}" == "embedded" ]
then
 cp ${SNIPPETS_SOURCE}/hazelcast-sessioncache.xml ${SNIPPETS_TARGET}/hazelcast-sessioncache.xml
 mkdir -p ${SHARED_CONFIG_DIR}/hazelcast
 cp ${SNIPPETS_SOURCE}/hazelcast-${HZ_SESSION_CACHE}.xml ${SHARED_CONFIG_DIR}/hazelcast/hazelcast.xml
fi




# Install needed features
installUtility install --acceptLicense defaultServer
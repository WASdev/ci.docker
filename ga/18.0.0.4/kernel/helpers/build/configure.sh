#!/bin/bash

##Define variables for XML snippets source and target paths
SNIPPETS_SOURCE=/opt/ibm/helpers/build/configuration_snippets
SNIPPETS_TARGET=/config/configDropins/overrides

#Check for each Liberty value-add functionality

# MicroProfile Health
if [ "$MP_HEALTH_CHECK" == "true" ]; then
  cp $SNIPPETS_SOURCE/mp_health_check.xml $SNIPPETS_TARGET/mp_health_check.xml
fi

# MicroProfile Monitoring
if [ "$MP_MONITORING" == "true" ]; then
  cp $SNIPPETS_SOURCE/mp_monitoring.xml $SNIPPETS_TARGET/mp_monitoring.xml
fi

# SSL
if [ "$SSL" == "true" ]; then
  cp $SNIPPETS_SOURCE/ssl.xml $SNIPPETS_TARGET/ssl.xml
fi

# HTTP Endpoint
if [ "$HTTP_ENDPOINT" == "true" ]; then
  if [ "$SSL" == "true" ]; then
    cp $SNIPPETS_SOURCE/https-http-endpoint.xml $SNIPPETS_TARGET/https-http-endpoint.xml
  else
    cp $SNIPPETS_SOURCE/http-endpoint.xml $SNIPPETS_TARGET/http-endpoint.xml
  fi
fi

# Install needed features
installUtility install --acceptLicense defaultServer
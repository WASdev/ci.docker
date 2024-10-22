#!/bin/bash

if [ -f "/logs/features.log" ]; then
  rm /logs/features.log
  exit 0
fi  
  
>&2 echo "WARNING: This is not an optimal build configuration. Although features in server.xml will continue to be installed correctly, the 'RUN features.sh' command should be added to the Dockerfile prior to configure.sh. See https://ibm.biz/wl-app-image-template for a sample application image template."
exit 1 

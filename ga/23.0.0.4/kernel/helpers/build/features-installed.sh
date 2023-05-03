#!/bin/bash

if [ -f "/logs/configure-liberty.log" ]; then
  rm /logs/configure-liberty.log
  exit 0
fi  
  
>&2 echo "WARNING: This is not an optimal build configuration. Although features in server.xml will continue to be installed correctly, the 'RUN features.sh' command should be added to the Dockerfile prior to configure.sh. See https://github.com/WASdev/ci.docker#building-an-application-image for a sample application image template."
exit 1 

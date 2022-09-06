#!/bin/bash

if [ -f "/opt/ibm/wlp/configure-liberty.log" ]; then
  exit 0
fi  
exit 1 

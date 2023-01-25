#!/bin/bash

if [ -f "/opt/ibm/wlp/configure-liberty.log" ]; then
    rm /opt/ibm/wlp/configure-liberty.log
    exit 0
fi  
exit 1 

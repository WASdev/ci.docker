#!/bin/bash

if [ -f "/logs/configure-liberty.log" ]; then
  rm /logs/configure-liberty.log
  exit 0
fi  
exit 1 

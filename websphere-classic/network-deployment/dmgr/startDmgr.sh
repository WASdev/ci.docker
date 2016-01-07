#!/bin/bash
/opt/IBM/WebSphere/AppServer/bin/startManager.sh

if [ $? != 0 ]
then
    echo " Dmgr startup failed , exiting....."
fi

sleep 10

while [ -f "/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/logs/dmgr/dmgr.pid" ]
do
    sleep 5
done





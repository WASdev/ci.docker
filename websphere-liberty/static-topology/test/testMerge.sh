#!/bin/bash

# (C) Copyright IBM Corporation 2015.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
HELP="--help"
        if [[ $1 -eq $HELP ]]
            then
                echo "USAGE"
                echo "            No args are required! "
                echo "DESCRIPTION"
                echo "                       "
                echo "            This test has been created to help test the static topology scripts"
                echo "            This test runs in a Docker environment so Docker must be installed on the"
                echo "            the host machine that this script is running on."
                echo "            This script will build and run two containers of WebSphere Liberty coppying in the required files"
                echo "            It will then check to see when WebSphere Liberty has started and run the GenPluginCfg.sh script to"
                echo "            generate the xml for each Liberty instance. Another Liberty container is then spun up and the XML"
                echo "            is copied into the new container and the merge script is then run to produce the final merged.xml."
            else
                # Build image with script to generate plugin XML
                docker build -t websphere-liberty:plugin ../gen-plugin-cfg

                # Build image with application on top
                docker build -t app .
                docker run -d -P --name=liberty1 app
                docker run -d -P --name=liberty2 app
                docker run -d -P --name=liberty3 app
                
                # Wait for Liberty to start otherwise the GenPluginCfg.sh script fails
                echo "  "
                echo "The test is waiting for all Liberty containers to start"
                found=1
                while [ $found != 0 ];
                do              
                    sleep 5s
                    docker logs liberty1 | grep "ready to run a smarter planet"
                    found=$?
                done
                docker exec liberty1 /opt/ibm/wlp/bin/GenPluginCfg.sh --installDir=/opt/ibm/wlp --userDir=/opt/ibm/wlp/usr --serverName=defaultServer
                
                found2=1
                while [ $found2 != 0 ];
                do
                    sleep 5s
                    docker logs liberty2 | grep "ready to run a smarter planet"
                    found2=$?
                done
                docker exec liberty2 /opt/ibm/wlp/bin/GenPluginCfg.sh --installDir=/opt/ibm/wlp --userDir=/opt/ibm/wlp/usr --serverName=defaultServer
                
                found3=1
                while [ $found3 != 0 ];
                do
                    sleep 5s
                    docker logs liberty3 | grep "ready to run a smarter planet"
                    found3=$?
                done
                docker exec liberty3 /opt/ibm/wlp/bin/GenPluginCfg.sh --installDir=/opt/ibm/wlp --userDir=/opt/ibm/wlp/usr --serverName=defaultServer
                
                ../get-plugin-cfg/GetPluginCfg.sh liberty1 default
                mv plugin-cfg.xml plugin-cfg1.xml
                
                ../get-plugin-cfg/GetPluginCfg.sh liberty2 default
                mv plugin-cfg.xml plugin-cfg2.xml
                
                ../get-plugin-cfg/GetPluginCfg.sh liberty3 default
                mv plugin-cfg.xml plugin-cfg3.xml
                
                echo "   "
                echo "Geting the port numbers of the running WebSphere-Liberty containers."
                port1=$(docker port liberty1| cut -c 21-26)
                lib1finalport1=$(echo $port1| cut -c 1-6)
                lib1finalport2=$(echo $port1| cut -c 7-13)
                port2=$(docker port liberty2| cut -c 21-26)
                lib2finalport1=$(echo $port2| cut -c 1-6)
                lib2finalport2=$(echo $port2| cut -c 7-13)
                port3=$(docker port liberty3| cut -c 21-26)
                lib3finalport1=$(echo $port3| cut -c 1-6)
                lib3finalport2=$(echo $port3| cut -c 7-13)
                
                echo "Printing ports for Liberty 1"
                echo $lib1finalport1
                echo $lib1finalport2
                
                echo "Printing ports for Liberty 2"
                echo $lib2finalport1
                echo $lib2finalport2
                
                echo "Printing ports fpr Liberty 3"
                echo $lib3finalport1
                echo $lib3finalport2
                
                echo "   "
                echo "Killing and removing each Liberty container"
                docker kill liberty1
                docker kill liberty2
                docker kill liberty3
                docker rm liberty1
                docker rm liberty2
                docker rm liberty3
                
                echo "   "
                echo "Building and running image to merge files"
                docker build -t merge ../merge-plugin-cfg
                docker run --rm -v $(pwd):/files merge pluginCfgMerge.sh /files/plugin-cfg1.xml /files/plugin-cfg2.xml /files/plugin-cfg3.xml /files/merge-cfg.xml
                
                echo "Testing to see if the final xml contains the required port numbers"
                if grep -q $lib1finalport1 merge-cfg.xml && grep -q $lib1finalport2 merge-cfg.xml; then
                    echo "The ports for Liberty1 have been written to the merged xml file"
                else
                    echo "Merge has not compleated successfully for Liberty1"
                fi
                
                if grep -q $lib2finalport1 merge-cfg.xml && grep -q $lib2finalport2 merge-cfg.xml; then
                    echo "The ports for Liberty2 have been written to the merged xml file"
                else
                    echo "Merge has not compleated successfully for Liberty2"
                fi
                
                if grep -q $lib3finalport1 merge-cfg.xml && grep -q $lib3finalport2 merge-cfg.xml; then
                    echo "The ports for Liberty3 have been written to the merged xml file"
                    echo "    "
                    echo "Test Passed!!!"
                else
                    echo "Merge has not compleated successfully for Liberty3"
                    echo "   "
                    echo "Test Failed!!!"
                fi
                
fi

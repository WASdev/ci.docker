#!/bin/bash
#
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

# Check arguments
if [ $# -ne 2 ]
  then
    echo "Parameters are incorrect. Format should be: <ContainerID> <Hostname>"
	exit 1
fi

# Copy config file to local directory
docker exec $1 /opt/ibm/wlp/bin/GenPluginCfg.sh --installDir=/opt/ibm/wlp --userDir=/opt/ibm/wlp/usr --serverName=defaultServer
docker cp $1:/opt/ibm/wlp/output/defaultServer/plugin-cfg.xml .
echo "Plugin configuration file copied to local directory"

# Get port information
IFS=' ' read -d '' -r -a array <<< `docker port $1`
P0=${array[0]%/*}
P1=${array[2]##*:}
P2=${array[3]%/*}
P3=`echo "${array[5]##*:}" | tr -d '\n'`

# Substitute in port and host information
sed -i -e "s/Port=\"$P0\"/Port=\"$P1\"/g" plugin-cfg.xml
sed -i -e "s/Port=\"$P2\"/Port=\"$P3\"/g" plugin-cfg.xml
sed -i -e "s/Hostname=\"[^\"]*\"/Hostname=\"$2\"/g" plugin-cfg.xml
echo "Plugin configuration file modified to reflect host information"

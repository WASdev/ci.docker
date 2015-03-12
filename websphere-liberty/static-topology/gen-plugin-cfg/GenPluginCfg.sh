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
if [ "$JAVA_HOME" != "" ]
then
 if [ -n "$1" ]  
 then
  if [ $1 = $HELP ]
  then
   echo "Usage of GenPluginCfg.sh ./GenPluginCfg.sh --installDir=<PATH_TO_WLP> --outputDir=<PATH_TO_OUTPUT> --userDir=<PATH_TO_USR> --serverName=<SERVERNAME>" 
  else
   JAVA_CMD=${JAVA_HOME}/bin/java
   CWD=$(pwd)
   JAVAPROGRAM=$CWD/tools/com.ibm.ws.docker.jar
   $JAVA_CMD -jar $JAVAPROGRAM $1 $2 $3 $4 
  fi
 else
 echo "Usage of GenPluginCfg.sh ./GenPluginCfg.sh --installDir=<PATH_TO_WLP> --outputDir=<PATH_TO_OUTPUT> --userDir=<PATH_TO_USR> --serverName=<SERVERNAME>"
 fi
else
 echo Please set your JAVA_HOME environment variable
fi

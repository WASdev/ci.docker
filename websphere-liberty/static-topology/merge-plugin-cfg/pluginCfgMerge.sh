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
if [ "$WLP_HOME" != "" ]
 then
  if [ "$JAVA_HOME" != "" ]
    then
     if [[ -n "$1" ]] && [[ -n "$2" ]] && [[ -n "$3" ]]  
      then
        if [ $1 = $HELP ]
          then
            echo "USAGE"
            echo "            <WLP_HOME>/bin/pluginCfgMerge.[sh|.bat] plugin-cfg1.xml plugin-cfg2.xml [...] plugin-cfg.xml"
            echo "               "
            echo "DESCRIPTION"
            echo "            The PluginCfgMerge Tool combines the plugin-cfg.xml files from two or more unbridged"
            echo "            cells such that the IBM HTTP Server Plugin will route traffic to all servers in the cells. "
            echo "            A uri is considered to be shared between two unbridged cells if the uri and  
                                                  corresponding virtual host definitions are identical."
            echo "                                                      "
            echo "            The contents of the merged plugin-cfg.xml files must be in English language"
            echo "                                                         "
            echo "            Additional parmaters:"
            echo "            -debug               = prints additional log statements"
            echo "            -sortVhostGrp        = adds VirtualHostGroup name as part of the key.  Use this if a single XML contains"
            echo "                                   two identical sets of URIs assigned to two different VirtualHostGroup Names."
            echo "            -setMatchUriAppVhost = sets the MatchUriAppVhost value."
            echo "            <WLP_HOME>/bin/pluginCfgMerge.[sh|.bat] -sortVhostGrp -debug plugin-cfg1.xml plugin-cfg2.xml [...] plugin-cfg.xml"
else
          JAVA_CMD=${JAVA_HOME}/jre/bin/java
          JAVAPROGRAM=$WLP_HOME/lib/com.ibm.ws.http.plugin.merge_1.0.9.jar
          MAINCLASS=com.ibm.ws.http.plugin.merge.internal.PluginMergeToolImpl
          VAR="-Djava.ext.dirs=$WLP_HOME/lib"
          $JAVA_CMD $VAR -cp $JAVAPROGRAM $MAINCLASS $1 $2 $3
        fi
        else
           echo "USAGE"
            echo "            <WLP_HOME>/bin/pluginCfgMerge.[sh|.bat] plugin-cfg1.xml plugin-cfg2.xml [...] plugin-cfg.xml"
            echo "               "
            echo "DESCRIPTION"
            echo "            The PluginCfgMerge Tool combines the plugin-cfg.xml files from two or more unbridged"
            echo "            cells such that the IBM HTTP Server Plugin will route traffic to all servers in the cells. "
            echo "            A uri is considered to be shared between two unbridged cells if the uri and
                                                  corresponding virtual host definitions are identical."
            echo "                                                      "
            echo "            The contents of the merged plugin-cfg.xml files must be in English language"
            echo "                                                         "
            echo "            Additional parmaters:"
            echo "            -debug               = prints additional log statements"
            echo "            -sortVhostGrp        = adds VirtualHostGroup name as part of the key.  Use this if a single XML contains"
            echo "                                   two identical sets of URIs assigned to two different VirtualHostGroup Names."
            echo "            -setMatchUriAppVhost = sets the MatchUriAppVhost value."
            echo "            <WLP_HOME>/bin/pluginCfgMerge.[sh|.bat] -sortVhostGrp -debug plugin-cfg1.xml plugin-cfg2.xml [...] plugin-cfg.xml"
fi
     else
       echo Please set your JAVA_HOME environment variable
  fi
  else
    echo Please set your WLP_HOME environment variable
fi

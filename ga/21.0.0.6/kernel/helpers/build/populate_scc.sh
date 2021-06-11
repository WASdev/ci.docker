#!/bin/bash
# (C) Copyright IBM Corporation 2020.
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
if [ "$VERBOSE" != "true" ]; then
  exec &>/dev/null
fi

set -Eeox pipefail

SCC_SIZE="80m"  # Default size of the SCC layer.
ITERATIONS=2    # Number of iterations to run to populate it.
TRIM_SCC=yes    # Trim the SCC to eliminate any wasted space.

# If this directory exists and has at least ug=rwx permissions, assume the base image includes an SCC called 'openj9_system_scc' and build on it.
# If not, build on our own SCC.
if [[ -d "/opt/java/.scc" ]] && [[ `stat -L -c "%a" "/opt/java/.scc" | cut -c 1,2` == "77" ]]
then
  SCC="-Xshareclasses:name=openj9_system_scc,cacheDir=/opt/java/.scc"
else
  SCC="-Xshareclasses:name=liberty,cacheDir=/output/.classCache"
fi

# For JDK8, as of OpenJ9 0.20.0 the criteria for determining the max heap size (-Xmx) has changed
# and the JVM has freedom to choose larger max heap sizes.
# Currently in compressedrefs mode there is a dependency between heap size and position and the AOT code stored in the
# SCC, such that if the max heap size/position changes too drastically the AOT code in the SCC becomes invalid and will
# not be loaded. Also, new AOT code will not be generated.
# In order to reduce the chances of this happening we use the -XX:+OriginalJDK8HeapSizeCompatibilityMode
# option to revert to the old criteria, which results in AOT code that is more compatible, on average, with typical heap sizes/positions.
# The option has no effect on later JDKs.
export OPENJ9_JAVA_OPTIONS="-XX:+OriginalJDK8HeapSizeCompatibilityMode $SCC"
export IBM_JAVA_OPTIONS="$OPENJ9_JAVA_OPTIONS"
CREATE_LAYER="$OPENJ9_JAVA_OPTIONS,createLayer,groupAccess"
DESTROY_LAYER="$OPENJ9_JAVA_OPTIONS,destroy"
PRINT_LAYER_STATS="$OPENJ9_JAVA_OPTIONS,printTopLayerStats"

while getopts ":i:s:tdh" OPT
do
  case "$OPT" in
    i)
      ITERATIONS="$OPTARG"
      ;;
    s)
      [ "${OPTARG: -1}" == "m" ] || ( echo "Missing m suffix." && exit 1 )
      SCC_SIZE="$OPTARG"
      ;;
    t)
      TRIM_SCC=yes
      ;;
    d)
      TRIM_SCC=no
      ;;
    h)
      echo \
"Usage: $0 [-i iterations] [-s size] [-t] [-d]
  -i <iterations> Number of iterations to run to populate the SCC. (Default: $ITERATIONS)
  -s <size>       Size of the SCC in megabytes (m suffix required). (Default: $SCC_SIZE)
  -t              Trim the SCC to eliminate most of the free space, if any.
  -d              Don't trim the SCC.

  Trimming enabled=$TRIM_SCC"
      exit 1
      ;;
    \?)
      echo "Unrecognized option: $OPTARG" 1>&2
      exit 1
      ;;
    :)
      echo "Missing argument for option: $OPTARG" 1>&2
      exit 1
      ;;
  esac
done

OLD_UMASK=`umask`
umask 002 # 002 is required to provide group rw permission to the cache when `-Xshareclasses:groupAccess` options is used

# Explicity create a class cache layer for this image layer here rather than allowing
# `server start` to do it, which will lead to problems because multiple JVMs will be started.
java $CREATE_LAYER -Xscmx$SCC_SIZE -version

if [ $TRIM_SCC == yes ]
then
  echo "Calculating SCC layer upper bound, starting with initial size $SCC_SIZE."
  # Populate the newly created class cache layer.
  /opt/ibm/wlp/bin/server start && /opt/ibm/wlp/bin/server stop
  # Find out how full it is.
  FULL=`( java $PRINT_LAYER_STATS || true ) 2>&1 | awk '/^Cache is [0-9.]*% .*full/ {print substr($3, 1, length($3)-1)}'`
  echo "SCC layer is $FULL% full. Destroying layer."
  # Destroy the layer once we know roughly how much space we need.
  java $DESTROY_LAYER || true
  # Remove the m suffix.
  SCC_SIZE="${SCC_SIZE:0:-1}"
  # Calculate the new size based on how full the layer was (rounded to nearest m).
  SCC_SIZE=`awk "BEGIN {print int($SCC_SIZE * $FULL / 100.0 + 0.5)}"`
  # Make sure size is >0.
  [ $SCC_SIZE -eq 0 ] && SCC_SIZE=1
  # Add the m suffix back.
  SCC_SIZE="${SCC_SIZE}m"
  echo "Re-creating layer with size $SCC_SIZE."
  # Recreate the layer with the new size.
  java $CREATE_LAYER -Xscmx$SCC_SIZE -version
fi

# Populate the newly created class cache layer.
# Server start/stop to populate the /output/workarea and make subsequent server starts faster.
for ((i=0; i<$ITERATIONS; i++))
do
  /opt/ibm/wlp/bin/server start && /opt/ibm/wlp/bin/server stop
done

# restore umask
umask ${OLD_UMASK}

rm -rf /output/messaging /logs/* $WLP_OUTPUT_DIR/.classCache && chmod -R g+rwx /output/workarea

if [[ -d "/output/resources" ]]
then
    chmod -R g+rwx /output/resources
fi

# Tell the user how full the final layer is.
FULL=`( java $PRINT_LAYER_STATS || true ) 2>&1 | awk '/^Cache is [0-9.]*% .*full/ {print substr($3, 1, length($3)-1)}'`
echo "SCC layer is $FULL% full."

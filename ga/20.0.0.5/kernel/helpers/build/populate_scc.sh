#!/bin/bash
if [ "$VERBOSE" != "true" ]; then
  exec &>/dev/null
fi

set -Eeox pipefail

SCC_SIZE="80m"  # Default size of the SCC layer.
ITERATIONS=2    # Number of iterations to run to populate it.
TRIM_SCC=yes    # Trim the SCC to eliminate any wasted space.

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

# Make sure the following Java commands don't disturb our class cache until we're ready to populate it
# by unsetting IBM_JAVA_OPTIONS if it is currently defined.
unset IBM_JAVA_OPTIONS

# Explicity create a class cache layer for this image layer here rather than allowing
# `server start` to do it, which will lead to problems because multiple JVMs will be started.
java -Xshareclasses:name=liberty,cacheDir=/output/.classCache/,createLayer -Xscmx$SCC_SIZE -version

if [ $TRIM_SCC == yes ]
then
  echo "Calculating SCC layer upper bound, starting with initial size $SCC_SIZE."
  # Populate the newly created class cache layer.
  export IBM_JAVA_OPTIONS="-Xshareclasses:name=liberty,cacheDir=/output/.classCache/"
  /opt/ibm/wlp/bin/server start && /opt/ibm/wlp/bin/server stop
  # Find out how full it is.
  unset IBM_JAVA_OPTIONS
  FULL=`( java -Xshareclasses:name=liberty,cacheDir=/output/.classCache/,printTopLayerStats || true ) 2>&1 | awk '/^Cache is [0-9.]*% .*full/ {print substr($3, 1, length($3)-1)}'`
  echo "SCC layer is $FULL% full. Destroying layer."
  # Destroy the layer once we know roughly how much space we need.
  java -Xshareclasses:name=liberty,cacheDir=/output/.classCache/,destroy || true
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
  java -Xshareclasses:name=liberty,cacheDir=/output/.classCache/,createLayer -Xscmx$SCC_SIZE -version
fi

# Populate the newly created class cache layer.
export IBM_JAVA_OPTIONS="-Xshareclasses:name=liberty,cacheDir=/output/.classCache/"

# Server start/stop to populate the /output/workarea and make subsequent server starts faster.
for ((i=0; i<$ITERATIONS; i++))
do
  /opt/ibm/wlp/bin/server start && /opt/ibm/wlp/bin/server stop
done

rm -rf /output/messaging /logs/* $WLP_OUTPUT_DIR/.classCache && chmod -R g+rwx /opt/ibm/wlp/output/*

unset IBM_JAVA_OPTIONS
# Tell the user how full the final layer is.
FULL=`( java -Xshareclasses:name=liberty,cacheDir=/output/.classCache/,printTopLayerStats || true ) 2>&1 | awk '/^Cache is [0-9.]*% .*full/ {print substr($3, 1, length($3)-1)}'`
echo "SCC layer is $FULL% full."

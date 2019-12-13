#! /bin/bash
#####################################################################################
#                                                                                   #
#  Script to verify a WebSphere Liberty image                                       #
#                                                                                   #
#                                                                                   #
#  Usage : verify.sh <Image name>                                                   #
#                                                                                   #
#####################################################################################

set -Eeo pipefail

readonly USAGE="Usage: ./test.sh --image=<local-image> --repository=<docker-registry-repo>"

main () {
   parse_args $@


   case "$(uname -p)" in
       "ppc64le")
           readonly arch="ppc64le"
           ;;
       "s390x")
           readonly arch="s390x"
           ;;
       *)
           readonly arch="amd64"
           ;;
   esac

   local tests=$(declare -F | cut -d" " -f3 | grep "^test")
   echo "****** Testing ${IMAGE}..."
   for name in "${tests}"; do
       timestamp=$(date '+%Y/%m/%d %H:%M:%S')
       echo "${timestamp} *** ${name} - Executing"
       eval "${name}"
       timestamp=$(date '+%Y/%m/%d %H:%M:%S')
       echo "${timestamp} *** ${name} - Completed Successfully"
   done
}

## tests from all liberty docker repos
waitForServerStart()
{
   local cid=$1
   local count=${2:-1}
   local end=$((SECONDS+120))
   while (( $SECONDS < $end && $(docker inspect -f {{.State.Running}} "${cid}") == "true" ))
   do
      local result=$(docker logs "${cid}" 2>&1 | grep "CWWKF0011I" | wc -l)
      if [ "${result}" = "${count}" ]
      then
         return 0
      fi
   done

   echo "Liberty failed to start the expected number of times"
   return 1
}

waitForServerStop()
{
   local cid=$1
   local end=$((SECONDS+120))
   while (( $SECONDS < $end ))
   do
      local result=$(docker logs "${cid}" 2>&1 | grep "CWWKE0036I" | wc -l)
      if [ $result = 1 ]
      then
         return 0
      fi
   done

   echo "Liberty failed to stop within a reasonable time"
   return 1
}

testDockerOnOpenShift()
{
   testLibertyStopsAndRestarts "OpenShift"
}

testLibertyStopsAndRestarts()
{
    echo "Running image: ${IMAGE}"
    if [ "$1" == "OpenShift" ]; then
        timestamp=$(date '+%Y/%m/%d %H:%M:%S')
        echo "$timestamp *** testLibertyStopsAndRestarts on OpenShift"
        cid=$(docker run -d -u 1001:0 $IMAGE)
    else
    local cid=$(docker run -d $IMAGE)
    fi
    echo "Waiting for server to start..."
    waitForServerStart "${cid}" \
        || handle_test_failure "${cid}" "starting"
    ## give server time to start up
    sleep 30

    echo "Stopping server..."
    docker stop "${cid}" >/dev/null \
        || handle_test_failure "${cid}" "stopping"
    ## give server time to stop
    sleep 30

    echo "Starting the server again..."
    docker restart "${cid}" >/dev/null \
        || handle_test_failure "${cid}" "starting"

    echo "Waiting for server to restart..."
    waitForServerStart "${cid}" 2 \
        || handle_test_failure "${cid}" "starting"

    echo "Checking container logs for errors..."
    ## if it finds NO errors the grep "fails" as it found nothing
    ## therefore we make the conditional true in the catch
    local pass
    docker logs "${cid}" 2>&1 | grep "ERROR" \
        || pass="passed"; true

    if [[ -z "${pass}" ]]; then
        echo "Errors found in logs for container; exiting"
        echo "DEBUG START full log"
        docker logs "${cid}"
        echo "DEBUG END full log"
        docker rm -f "${cid}" >/dev/null
        exit 1
    fi
    echo "Removing container: ${cid}"
    docker rm -f "${cid}" >/dev/null
}

handle_test_failure () {
    local cid="$1"; shift
    local process="$1"
    echo "Error ${process} container or server; exiting"
    docker logs "${cid}"
    docker rm -f "${cid}" >/dev/null
    exit 1
}
parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --repository=*)
                readonly REPO="${1#*=}"
                ;;
            --image=*)
                ## currently unused variable but ideally dockerfiles take as arg
                readonly IMAGE="${1#*=}"
                ;;
            *)
                echo "Error: Invalid argument - $1"
                echo "$USAGE"
                exit 1
        esac
        shift
    done

    if [[ -z "${REPO}" || -z "${IMAGE}" ]]; then
        echo "****** Error: missing required params"
        echo "${USAGE}"
        exit 1
    fi
}
main $@

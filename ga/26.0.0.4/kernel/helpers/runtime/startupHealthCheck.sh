#!/bin/bash

#Default to 1s - Can change through parameter or server env
timeout_seconds=1
timeout_milliseconds=$((timeout_seconds * 1000))

#Default location for 'started' file - Can change through parameter or server env
started_file=/output/health/started

#Static values - will not be changed
sleep_seconds=0.01
sleep_milliseconds=10


# Evaluate if there is a env var for timeoutSeconds
if [ -n "${STARTUP_PROBE_TIMEOUT_SECONDS}" ]
then
  #Check input is numerical only
  if [[ ${STARTUP_PROBE_TIMEOUT_SECONDS} =~ ^[0-9]+$ ]]
  then
    timeout_seconds=${STARTUP_PROBE_TIMEOUT_SECONDS}
    timeout_milliseconds=$((timeout_seconds * 1000))
  else
    echo "Expected only a numerical value for STARTUP_PROBE_TIMEOUT_SECONDS environment variable, but recieved: ${STARTUP_PROBE_TIMEOUT_SECONDS}. This value will not be used."
  fi
fi

# Evaluate if there is a env var for 'started' file location
if [ -n "${STARTED_FILE_LOCATION}" ]
then
  started_file=${STARTED_FILE_LOCATION}
fi


while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--timeout-seconds)
      #Check input is numerical only
      if [[ $2 =~ ^[0-9]+$ ]]
      then
        timeout_seconds=$2
        timeout_milliseconds=$((timeout_seconds*1000))
      else
        echo "Expected only a numerical value for the -t/--timeout-seconds parameter, but recieved: $2. Defaulting to 1 second timeoutSeconds or environment variable defined value if valid."
      fi
      shift
      shift
      ;;
    -f|--file)
      started_file=$2
      shift
      shift
      ;;
	--help)
	  printf "This script is used to query the 'started' health check file to determine if the container is started. The default location is '/output/health/started' but can be configured with the '-f' or '--file' option or the environment variable 'STARTED_FILE_LOCATION' if the file exists in another location. This script will check until the timeout duration has expired (default is 1 second) unless configured otherwise. Configuring the timeout option for this script is important if the 'timeoutSeconds' field of the Kubernetes startup probe is configured. This can be achieved by using the '-t' or '--timeout-seconds' option or with the environment variable 'STARTUP_PROBE_TIMEOUT_SECONDS'. Failure to do so will result in the script not being able to capture a successful startup response as soon as possible.\n\nNote that the options passed directly into the script will supersede the environment variable configuration.\n\nUsage: ./startupHealthCheck.sh <option>...\nOptions:\n\n\t-t/--timeout-seconds\n\t\t A numerical value that must match the 'timeoutSeconds' field of the Kubernetes startup probe configuration. The timeout value is used by this script to establish a timeout duration. Defaults to 1 (second).\n\n\t-f/--file\n\t\tThis value is used to inform the script of the location of the 'started' health-check file. The default is '/output/health/started'\n"
	  exit 1
	  ;;
    *)
     shift
     ;;
  esac
done

countdown=$timeout_milliseconds
while [ $countdown -gt 0 ]
do
  cat ${started_file}
  #Succesful `cat`, return 0
  if [ $? -eq 0 ]
  then
    # Delete file before returning 0. Avoid issues where image/pod crashes and /output is a PV. 
	# This would lead to a pre-existing file when pod is restarted
    rm ${started_file}
    exit 0
  fi
  sleep ${sleep_seconds}
  countdown=$((countdown - sleep_milliseconds))
done

#Default to 1 if we never achieved succesful check.
exit 1
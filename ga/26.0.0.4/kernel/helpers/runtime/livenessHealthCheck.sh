#!/bin/bash

#Default to Kubernetes default for periodSeconds of 10 seconds
period_seconds=10
period_milliseconds=$((period_seconds * 1000))

#Default location for 'live' file - Can change through parameter or server env
live_file=/output/health/live


# Evaluate if there is a env var for periodSeconds
if [ -n "${LIVENESS_PROBE_PERIOD_SECONDS}" ]
then
  #Check input is numerical only
  if [[ ${LIVENESS_PROBE_PERIOD_SECONDS} =~ ^[0-9]+$ ]]
  then
    period_seconds=${LIVENESS_PROBE_PERIOD_SECONDS}
    period_milliseconds=$((period_seconds * 1000))
  else
    echo "Expected only a numerical value for LIVENESS_PROBE_PERIOD_SECONDS environment variable, but recieved: ${LIVENESS_PROBE_PERIOD_SECONDS}. This value will not be used."
  fi
fi

# Evaluate if there is a env var for 'live' file location
if [ -n "${LIVE_FILE_LOCATION}" ]
then
  live_file=${LIVE_FILE_LOCATION}
fi


while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--period-seconds)
      #Check input is numerical only
      if [[ $2 =~ ^[0-9]+$ ]]
      then
        period_seconds=$2
        period_milliseconds=$((period_seconds*1000))
      else
        echo "Expected only a numerical value for the -p/--period-seconds parameter, but recieved: $2. Defaulting to 10 second period seconds or environment variable defined value if valid."
      fi
      shift
      shift
      ;;
    -f|--file)
      live_file=$2
      shift
      shift
      ;;
	--help)
	  printf "This script is used to query the 'live' health check file to determine if the container is live or not. The default location is '/output/health/live' but can be configured with the '-f' or '--file' option or with the environment variable 'LIVE_FILE_LOCATION' if the file exists in another location. This script will check whether the file has been updated or not within the last 'period seconds' (default is 10 seconds). This value can be configured with the '-p' or '--period-seconds' option or with the 'LIVENESS_PROBE_PERIOD_SECONDS' environment variable. It is important to configure the period seconds option for this script if the Kubernetes 'periodSeconds' field of the liveness probe is configured. Failure to do so will result in misreporting of the liveness status of the container.\n\nNote that the options passed directly in to the script will supersede the environment variable configuration.\n\nUsage: ./livenessHealthCheck.sh <option>...\nOptions:\n\n\t-p/--period-seconds\n\t\t A numerical value that must match the periodSeconds field of the Kubernetes liveness probe configuration. The period seconds value is used by this script to determine if the container is live or not. Default is 10 (seconds).\n\n\t-f/--file\n\t\tThis value is used to inform the script of the location of the 'live' health-check file. The default is '/output/health/live'\n"
	  exit 1
	  ;;
    *)
     shift
     ;;
  esac
done

cat $live_file

if [ $? -ne 0 ]
then  
  exit 1
fi

#What is the last modified time of the file
modified_time=$(stat --format=%.3Y $live_file | tr -d ".") 


if [ $(expr $(date +%s%3N) - $modified_time) -gt $period_milliseconds ]
then
  #File has not been updated within the last period_milliseconds; fail
  exit 1
else
  #File has been updated within the last period_milliseconds; success!
  exit 0
fi

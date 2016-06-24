#! /bin/bash
#########################################################################
#                                                                       #
# Echo the list of package licenses for a Ubuntu instance               #
#                                                                       #
# Usage (In a running container) : getPackages.sh                       #
#                                                                       #
# Author : Liam White                                                   #
#                                                                       #
#########################################################################


# Make sure there is some repo information
apt-get -qq update

# Get the list of installed packages
PACKAGES=$(dpkg --get-selections | awk '{print $1}')

# Echo header
echo "package,version,repository,licenses"

# Process each package
for package in ${PACKAGES}; do

    # Cut off any arch info
    if [ "echo ${package} | grep ':amd64'" ]
    then
        package=`echo ${package} | cut -d ':' -f 1`
    fi

    # Get the license
    COPYRIGHT_FILE=$(dpkg -L $package | grep -e "copyright")
    if [ $? != 0 ]
        then LICENSES="others" # If theres no copyright file then we have no hope of finding a license
        else
            # Search for any references to a license in the copyright file
            LICENSES=$(grep -e "License: " ${COPYRIGHT_FILE} | sed -e 's/License: //g' )
            if [ "$LICENSES" == "" ]
                then
                # If there aren't any references to a license then do a blind check for a GPL license
                grep "GPL" ${COPYRIGHT_FILE} > /dev/null
                if [ $? -eq 0 ]
                    then
                        LICENSES="GPL"
                    else # Just give up and set to others
                        LICENSES="others"
                fi
            else
                # Put the licenses array into a single string
                TEMP_LICENSES=""
                for line in ${LICENSES}; do
                    # Filter out multiple occurences
                    if [ $(echo $TEMP_LICENSES | grep -e $line | wc -l) -lt 1 ]
                        then TEMP_LICENSES="$TEMP_LICENSES $line"
                    fi
                done
                LICENSES=$(echo $TEMP_LICENSES | sed 's/^ //')
                LICENSES=$(echo $LICENSES | sed 's/,/ /')
            fi
    fi

    # Get the version
    VERSION=$(dpkg -s $package | egrep "^Version:" | cut -f 2 -d " ")

    # Get the start of the REPO_INFO
    REPO_INFO=$(apt-cache policy $package)

    # Echo out result
    if [ $(echo $REPO_INFO | grep -e "main" | wc -l) -gt 0 ]
        then echo "$package,$VERSION,main,$LICENSES"
    elif [ $(echo $REPO_INFO | grep -e "restricted" | wc -l) -gt 0 ]
        then echo "$package,$VERSION,restriced,$LICENSES"
    elif [ $(echo $REPO_INFO | grep -e "multiverse" | wc -l) -gt 0 ]
        then echo "$package,$VERSION,multiverse,$LICENSES"
    elif [ $(echo $REPO_INFO | grep -e "universe" | wc -l) -gt 0 ]
        then echo "$package,$VERSION,universe,$LICENSES"
    fi
done

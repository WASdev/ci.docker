#! /bin/bash
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

############################################################################
#                                                                          #
#  Script to check whether official & ibmcom repository are in sync        #
#                                                                          #
#  Usage :checkRepositorySync.sh <kernel|beta> <target respository>#
#                                                                          #
#  Author : Kavitha                                                        #
#                                                                          #
############################################################################

usage()
{
    echo "Usage : checkRepositorySync.sh <kernel|beta> <target respository>"
    echo "Example usage -  checkRepositorySync.sh kernel ibmcom"
    exit 1
}

if [ $# -gt 2 ]
then
    usage
elif [ $# = 2 ]
then
    tag=$1
    target=$2
    echo "Target Repository is $target and tag is $tag."
elif [ $# != 2 ]
then
    if [ $# != 1 ]
    then
        usage
    else
        tag=$1
        echo "Tag is $tag, using default target ibmcom"
        target="ibmcom"
    fi
fi

docker pull websphere-liberty:$tag
if [ $? = 0 ]
then
    id=`docker inspect --format='{{.Id}}' websphere-liberty:$tag`
    docker pull $target/websphere-liberty:$tag
    if [ $? != 0 ]
    then
        echo "Check the target repository provided."
        usage
        exit 1
    fi
    tid=`docker inspect --format='{{.Id}}' $target/websphere-liberty:$tag`
    if [ $id = $tid ]
    then
        echo "Images are in sync, exiting ..........."
    else
        echo "Images are not in sync - sync the repository."
        syncRepository.sh $tag $target
    fi
else
    echo "Check the tag provided."
    usage
fi

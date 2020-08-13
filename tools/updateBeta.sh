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

# Update the Dockerfile and generate the new feature lists

# Get most recent version
version=$(wget -qO- https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/index.yml | egrep '[0-9]{4}\.[0-9]{1,2}\.0_0*' | sed 's/://' | sort -rV | head -1 | tr -d '\r')

# Check if the beta Liberty version is up to date
count=$(cat ../beta/Dockerfile | grep "ENV LIBERTY_VERSION $version" | wc -l)
if [ $count -eq 0 ]; then

    # Replace version in the Dockerfile
    echo "Updating Dockerfile"
    sed -i -r -e "s@ENV LIBERTY_VERSION.*@ENV LIBERTY_VERSION $version@" ../beta/Dockerfile

fi

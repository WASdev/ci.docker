#!/bin/bash
# (C) Copyright IBM Corporation 2025.
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

function main() {
    if [ "$VERBOSE" != "true" ]; then
        exec >/dev/null
    fi
}

function hideLogs() {
    exec 3>&1 >/dev/null 4>&2 2>/dev/null
}

function showLogs() {
    exec 1>&3 3>&- 2>&4 4>&-
}

function logDeprecationNotice() {
    echo "Deprecation notice: IBM expects the last version of the UBI-based WebSphere Liberty container image in Docker Hub ('ibmcom/websphere-liberty') to be 25.0.0.3. To continue to receive updates and security fixes after 25.0.0.3, you must switch to using the images from the IBM Container Registry (ICR). To switch, simply update 'FROM ibmcom/websphere-liberty' in your Dockerfiles to 'FROM icr.io/appcafe/websphere-liberty'. The same image tags from Docker Hub are also available in ICR. Ubuntu-based Liberty container images will continue to be available from Docker Hub. For more information, see https://ibm.biz/wl-ubi-containers-dh-deprecation"
}

logDeprecationNotice

main
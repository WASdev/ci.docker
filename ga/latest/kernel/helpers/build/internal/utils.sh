#!/bin/bash
# (C) Copyright IBM Corporation 2025, 2026.
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
    WLP_TYPE=ibm
    WLP_INSTALL_DIR=/opt/$WLP_TYPE/wlp
    if [ "$VERBOSE" != "true" ]; then
        exec >/dev/null
    else
        set -x
    fi
}

function hideLogs() {
    exec 3>&1 >/dev/null 4>&2 2>/dev/null
}

function showLogs() {
    exec 1>&3 3>&- 2>&4 4>&-
}

function installFixes() {
    if [ ! -f "/logs/fixes.log" ] && ls "/opt/$WLP_TYPE/fixes"/*.jar 1> /dev/null 2>&1; then
        find /opt/$WLP_TYPE/fixes -type f -name "*.jar"  -print0 | sort -z | xargs -0 -n 1 -r -I {} java -jar {} --installLocation $WLP_INSTALL_DIR
        echo "installFixes has been run" > /logs/fixes.log
    fi 
}

function removeBuildArtifacts() {
    rm -f /logs/fixes.log
}

main

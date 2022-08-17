#!/bin/bash
# (C) Copyright IBM Corporation 2022.
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

# Determine if featureUtility ran in an earlier build step
if [ -f "/opt/ibm/wlp/configure-liberty.log" ]; then
    FEATURES_INSTALLED=true
else
    FEATURES_INSTALLED=false
    # Resolve liberty server symlinks and creation for server name changes
    /opt/ibm/helpers/runtime/configure-liberty.sh
    if [ $? -ne 0 ]; then
        exit
    fi
fi

##Define variables for XML snippets source and target paths
SNIPPETS_SOURCE=/opt/ibm/helpers/build/configuration_snippets
SNIPPETS_TARGET=/config/configDropins/overrides
SNIPPETS_TARGET_DEFAULTS=/config/configDropins/defaults
mkdir -p ${SNIPPETS_TARGET}
mkdir -p ${SNIPPETS_TARGET_DEFAULTS}

# Session Caching
if [ -n "$INFINISPAN_SERVICE_NAME" ] || [ "${HZ_SESSION_CACHE}" == "client" ] || [ "${HZ_SESSION_CACHE}" == "embedded" ]; then
  cp ${SNIPPETS_SOURCE}/sessioncache-features.xml ${SNIPPETS_TARGET}/sessioncache-features.xml
  chmod g+rw $SNIPPETS_TARGET/sessioncache-features.xml
fi

# SSO
if [[ -n "$SEC_SSO_PROVIDERS" ]]; then
  cp $SNIPPETS_SOURCE/sso-features.xml $SNIPPETS_TARGET_DEFAULTS
fi

# Key Store
if [ "$SSL" == "true" ] || [ "$TLS" == "true" ]; then
  cp $SNIPPETS_SOURCE/tls.xml $SNIPPETS_TARGET/tls.xml
fi

# Install necessary features using featureUtility
if [ "$FEATURES_INSTALLED" == "false" ]; then
  featureUtility installServerFeatures --acceptLicense defaultServer --noCache
  find /opt/ibm/wlp/lib /opt/ibm/wlp/bin ! -perm -g=rw -print0 | xargs -0 -r chmod g+rw
fi

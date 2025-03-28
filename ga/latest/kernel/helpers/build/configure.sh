#!/bin/bash
# (C) Copyright IBM Corporation 2020, 2025.
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

# Determine if featureUtility ran in an earlier build step
if /opt/ibm/helpers/build/internal/features-installed.sh; then
  FEATURES_INSTALLED=true
else
  FEATURES_INSTALLED=false
fi

. /opt/ibm/helpers/build/internal/logger.sh

set -Eeox pipefail

function main() {
  ##Define variables for XML snippets source and target paths
  WLP_INSTALL_DIR=/opt/ibm/wlp
  SHARED_CONFIG_DIR=${WLP_INSTALL_DIR}/usr/shared/config
  SHARED_RESOURCE_DIR=${WLP_INSTALL_DIR}/usr/shared/resources

  SNIPPETS_SOURCE=/opt/ibm/helpers/build/configuration_snippets
  SNIPPETS_TARGET=/config/configDropins/overrides
  SNIPPETS_TARGET_DEFAULTS=/config/configDropins/defaults
  mkdir -p ${SNIPPETS_TARGET}
  mkdir -p ${SNIPPETS_TARGET_DEFAULTS}

  # Check for each Liberty value-add functionality
  if [ "$FEATURES_INSTALLED" == "false" ]; then
    # HTTP Endpoint
    if [ "$HTTP_ENDPOINT" == "true" ]; then
      if [ "$SSL" == "true" ] || [ "$TLS" == "true" ]; then
        cp $SNIPPETS_SOURCE/http-ssl-endpoint.xml $SNIPPETS_TARGET/http-ssl-endpoint.xml
      else
        cp $SNIPPETS_SOURCE/http-endpoint.xml $SNIPPETS_TARGET/http-endpoint.xml
      fi
    fi

    # MicroProfile Health
    if [ "$MP_HEALTH_CHECK" == "true" ]; then
      cp $SNIPPETS_SOURCE/mp-health-check.xml $SNIPPETS_TARGET/mp-health-check.xml
    fi

    # MicroProfile Monitoring
    if [ "$MP_MONITORING" == "true" ]; then
      cp $SNIPPETS_SOURCE/mp-monitoring.xml $SNIPPETS_TARGET/mp-monitoring.xml
    fi

    # IIOP Endpoint
    if [ "$IIOP_ENDPOINT" == "true" ]; then
      if [ "$SSL" == "true" ] || [ "$TLS" == "true" ]; then
        cp $SNIPPETS_SOURCE/iiop-ssl-endpoint.xml $SNIPPETS_TARGET/iiop-ssl-endpoint.xml
      else
        cp $SNIPPETS_SOURCE/iiop-endpoint.xml $SNIPPETS_TARGET/iiop-endpoint.xml
      fi
    fi

    # JMS Endpoint
    if [ "$JMS_ENDPOINT" == "true" ]; then
      if [ "$SSL" == "true" ] || [ "$TLS" == "true" ]; then
        cp $SNIPPETS_SOURCE/jms-ssl-endpoint.xml $SNIPPETS_TARGET/jms-ssl-endpoint.xml
      else
        cp $SNIPPETS_SOURCE/jms-endpoint.xml $SNIPPETS_TARGET/jms-endpoint.xml
      fi
    fi

    # OpenIdConnect Client
    if [ "$OIDC" == "true" ]  || [ "$OIDC_CONFIG" == "true" ]; then
      cp $SNIPPETS_SOURCE/oidc.xml $SNIPPETS_TARGET/oidc.xml
    fi
    if [ "$OIDC_CONFIG" == "true" ]; then
      cp $SNIPPETS_SOURCE/oidc-config.xml $SNIPPETS_TARGET/oidc-config.xml
    fi

    # Infinispan Session Caching (Full)
    if [[ -n "$INFINISPAN_SERVICE_NAME" ]]; then
      cp ${SNIPPETS_SOURCE}/infinispan-client-sessioncache.xml ${SNIPPETS_TARGET}/infinispan-client-sessioncache.xml
      chmod g+rw $SNIPPETS_TARGET/infinispan-client-sessioncache.xml
    fi

    # Hazelcast Session Caching (Full)
    if [ "${HZ_SESSION_CACHE}" == "client" ] || [ "${HZ_SESSION_CACHE}" == "embedded" ]; then
      cp ${SNIPPETS_SOURCE}/hazelcast-sessioncache.xml ${SNIPPETS_TARGET}/hazelcast-sessioncache.xml
      mkdir -p ${SHARED_CONFIG_DIR}/hazelcast
      cp ${SNIPPETS_SOURCE}/hazelcast-${HZ_SESSION_CACHE}.xml ${SHARED_CONFIG_DIR}/hazelcast/hazelcast.xml
    fi

    # SSO
    if [[ -n "$SEC_SSO_PROVIDERS" ]]; then
      cp $SNIPPETS_SOURCE/sso-features.xml $SNIPPETS_TARGET_DEFAULTS
    fi

    # Key Store
    if [ "$SSL" == "true" ] || [ "$TLS" == "true" ]; then
      cp $SNIPPETS_SOURCE/tls.xml $SNIPPETS_TARGET/tls.xml
    fi
  else
    # Otherwise, load XML for addons that have features already installed
    # Infinispan Session Caching
    if [[ -n "$INFINISPAN_SERVICE_NAME" ]]; then
      cp ${SNIPPETS_SOURCE}/infinispan-client-sessioncache-config.xml ${SNIPPETS_TARGET}/infinispan-client-sessioncache-config.xml
      chmod g+rw $SNIPPETS_TARGET/infinispan-client-sessioncache-config.xml
    fi

    # Hazelcast Session Caching
    if [ "${HZ_SESSION_CACHE}" == "client" ] || [ "${HZ_SESSION_CACHE}" == "embedded" ]; then
      cp ${SNIPPETS_SOURCE}/hazelcast-sessioncache-config.xml ${SNIPPETS_TARGET}/hazelcast-sessioncache-config.xml
      mkdir -p ${SHARED_CONFIG_DIR}/hazelcast
      cp ${SNIPPETS_SOURCE}/hazelcast-${HZ_SESSION_CACHE}.xml ${SHARED_CONFIG_DIR}/hazelcast/hazelcast.xml
    fi
  fi

  # Key Store
  keystorePath="$SNIPPETS_TARGET_DEFAULTS/keystore.xml"
  if [ "$SSL" != "false" ] && [ "$TLS" != "false" ]; then
    if [ ! -e $keystorePath ]; then
      # Generate the keystore.xml
      hideLogs
      KEYSTOREPWD=$(openssl rand -base64 32)
      sed "s|REPLACE|$KEYSTOREPWD|g" $SNIPPETS_SOURCE/keystore.xml > $SNIPPETS_TARGET_DEFAULTS/keystore.xml
      showLogs
      chmod g+w $SNIPPETS_TARGET_DEFAULTS/keystore.xml
    fi
  fi

  # SSO
  if [[ -n "$SEC_SSO_PROVIDERS" ]]; then
    parseProviders $SEC_SSO_PROVIDERS
  fi

  if [ "$SKIP_FEATURE_INSTALL" != "true" ] && [ "$FEATURES_INSTALLED" == "false" ]; then
    # Install needed features
    if [ "$FEATURE_REPO_URL" ]; then
      curl -k --fail $FEATURE_REPO_URL > /tmp/repo.zip
      installUtility install --acceptLicense defaultServer --from=/tmp/repo.zip || rc=$?; if [ $rc -ne 22 ]; then exit $rc; fi
      rm -rf /tmp/repo.zip
    else
      installUtility install --acceptLicense defaultServer || rc=$?; if [ $rc -ne 22 ]; then exit $rc; fi
    fi
  fi

  # Apply interim fixes found in /opt/ibm/fixes
  # Fixes recommended by IBM, such as to resolve security vulnerabilities, are also included in /opt/ibm/fixes
  # Note: This step should be done once needed features are enabled and installed using installUtility.

  # Do not create a SCC
  if [ -n "${IBM_JAVA_OPTIONS}" ]; then
    IBM_JAVA_OPTIONS="${IBM_JAVA_OPTIONS} -Xshareclasses:none"
  fi

  if [ -n "${OPENJ9_JAVA_OPTIONS}" ]; then
    OPENJ9_JAVA_OPTIONS="${OPENJ9_JAVA_OPTIONS} -Xshareclasses:none"
  fi

  find /opt/ibm/fixes -type f -name "*.jar"  -print0 | sort -z | xargs -0 -n 1 -r -I {} java -jar {} --installLocation $WLP_INSTALL_DIR
  #Make sure that group write permissions are set correctly after installing new features
  find /opt/ibm/wlp ! -perm -g=rw -print0 | xargs -r -0 chmod g+rw

  # Force the server.xml to be processed by updating its timestamp
  touch /config/server.xml

  # Create a new SCC layer
  if [ "$OPENJ9_SCC" == "true" ]; then
    cmd="populate_scc.sh -i 1"
    if [ "$TRIM_SCC" == "false" ]; then
      cmd+=" -d"
    fi
    if [ ! "$SCC_SIZE" = "" ]; then
      cmd+=" -s $SCC_SIZE"
    fi
    if [ "$WARM_ENDPOINT" = "false" ]; then
      cmd+=" -c"
    fi
    if [ ! "$WARM_ENDPOINT_URL" = "" ]; then
      cmd+=" -u $WARM_ENDPOINT_URL"
    fi
    if [ "$WARM_OPENAPI_ENDPOINT" = "false" ]; then
      cmd+=" -l"
    fi
    if [ ! "$WARM_OPENAPI_ENDPOINT_URL" = "" ]; then
      cmd+=" -o $WARM_OPENAPI_ENDPOINT_URL"
    fi
    eval $cmd
  fi
}

## parse provider list to generate files into configDropins
function parseProviders() {
  while [ $# -gt 0 ]; do
    case "$1" in
    oidc:*)
      parseCommaList oidc "${1#*:}"
      ;;
    oauth2:*)
      parseCommaList oauth2 "${1#*:}"
      ;;
    *)
      if [[ $(ls $SNIPPETS_SOURCE | grep "$1") ]]; then
        cp $SNIPPETS_SOURCE/sso-${1}.xml $SNIPPETS_TARGET_DEFAULTS
      fi
      ;;
    esac
    shift
  done
}

## process the comma delimitted oauth2/oidc source lists
function parseCommaList() {
  local type="$1"
  local list=$(echo "$2" | tr , " ")

  for current in ${list}; do
    if [[ "${type}" = "oidc" ]]; then
      # replace oidc identifiers with custom name
      sed -e 's/=\"oidc/=\"'${current}'/g' -e 's/_OIDC_/_'${current^^}'_/g' $SNIPPETS_SOURCE/sso-oidc.xml > $SNIPPETS_TARGET_DEFAULTS/sso-${current}.xml
    else
      # replace oauth2 identifiers with custom name
      sed -e 's/=\"oauth2/=\"'${current}'/g' -e 's/_OAUTH2_/_'${current^^}'_/g' $SNIPPETS_SOURCE/sso-oauth2.xml > $SNIPPETS_TARGET_DEFAULTS/sso-${current}.xml
    fi
  done
}

main "$@"
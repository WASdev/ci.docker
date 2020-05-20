#!/bin/bash
if [ "$VERBOSE" != "true" ]; then
  exec &>/dev/null
fi

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


  #Check for each Liberty value-add functionality

  # MicroProfile Health
  if [ "$MP_HEALTH_CHECK" == "true" ]; then
    cp $SNIPPETS_SOURCE/mp-health-check.xml $SNIPPETS_TARGET/mp-health-check.xml
  fi

  # MicroProfile Monitoring
  if [ "$MP_MONITORING" == "true" ]; then
    cp $SNIPPETS_SOURCE/mp-monitoring.xml $SNIPPETS_TARGET/mp-monitoring.xml
  fi

  # OpenIdConnect Client
  if [ "$OIDC" == "true" ]  || [ "$OIDC_CONFIG" == "true" ]
  then
    cp $SNIPPETS_SOURCE/oidc.xml $SNIPPETS_TARGET/oidc.xml
  fi

  if [ "$OIDC_CONFIG" == "true" ]; then
    cp $SNIPPETS_SOURCE/oidc-config.xml $SNIPPETS_TARGET/oidc-config.xml
  fi

  # HTTP Endpoint
  if [ "$HTTP_ENDPOINT" == "true" ]; then
    if [ "$SSL" == "true" ] || [ "$TLS" == "true" ]; then
      cp $SNIPPETS_SOURCE/http-ssl-endpoint.xml $SNIPPETS_TARGET/http-ssl-endpoint.xml
    else
      cp $SNIPPETS_SOURCE/http-endpoint.xml $SNIPPETS_TARGET/http-endpoint.xml
    fi
  fi

  # Hazelcast Session Caching
  if [ "${HZ_SESSION_CACHE}" == "client" ] || [ "${HZ_SESSION_CACHE}" == "embedded" ]
  then
  cp ${SNIPPETS_SOURCE}/hazelcast-sessioncache.xml ${SNIPPETS_TARGET}/hazelcast-sessioncache.xml
  mkdir -p ${SHARED_CONFIG_DIR}/hazelcast
  cp ${SNIPPETS_SOURCE}/hazelcast-${HZ_SESSION_CACHE}.xml ${SHARED_CONFIG_DIR}/hazelcast/hazelcast.xml
  fi

  # Infinispan Session Caching
  if [[ -n "$INFINISPAN_SERVICE_NAME" ]]; then
  cp ${SNIPPETS_SOURCE}/infinispan-client-sessioncache.xml ${SNIPPETS_TARGET}/infinispan-client-sessioncache.xml
  chmod g+rw $SNIPPETS_TARGET/infinispan-client-sessioncache.xml
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

  # Key Store
  keystorePath="$SNIPPETS_TARGET_DEFAULTS/keystore.xml"
  if [ "$SSL" == "true" ] || [ "$TLS" == "true" ]
  then
    cp $SNIPPETS_SOURCE/tls.xml $SNIPPETS_TARGET/tls.xml
  fi

  if [ "$SSL" != "false" ] && [ "$TLS" != "false" ]
  then
    if [ ! -e $keystorePath ]
    then
      # Generate the keystore.xml
      export KEYSTOREPWD=$(openssl rand -base64 32)
      sed "s|REPLACE|$KEYSTOREPWD|g" $SNIPPETS_SOURCE/keystore.xml > $SNIPPETS_TARGET_DEFAULTS/keystore.xml
      chmod g+w $SNIPPETS_TARGET_DEFAULTS/keystore.xml
    fi
  fi

  # SSO Support
  if [[ -n "$SEC_SSO_PROVIDERS" ]]; then
    cp $SNIPPETS_SOURCE/sso-features.xml $SNIPPETS_TARGET_DEFAULTS
    parseProviders $SEC_SSO_PROVIDERS
  fi

  # Install needed features
  if [ "$FEATURE_REPO_URL" ]; then
    curl -k --fail $FEATURE_REPO_URL > /tmp/repo.zip
    installUtility install --acceptLicense defaultServer --from=/tmp/repo.zip || if [ $? -ne 22 ]; then exit $?; fi
    rm -rf /tmp/repo.zip
  else
    installUtility install --acceptLicense defaultServer || if [ $? -ne 22 ]; then exit $?; fi
  fi

  # Apply interim fixes found in /opt/ibm/fixes
  # Fixes recommended by IBM, such as to resolve security vulnerabilities, are also included in /opt/ibm/fixes
  # Note: This step should be done once needed features are enabled and installed using installUtility.
  find /opt/ibm/fixes -type f -name "*.jar"  -print0 | sort -z | xargs -0 -n 1 -r -I {} java -jar {} --installLocation $WLP_INSTALL_DIR
  #Make sure that group write permissions are set correctly after installing new features
  find /opt/ibm/wlp -perm -g=w -print0 | xargs -0 -r chmod -R g+rw
  # Create a new SCC layer
  if [ "$OPENJ9_SCC" == "true" ]
  then
    populate_scc.sh
  fi
  #Make folder executable for a group
  find /opt/ibm/wlp -type d -perm -g=x -print0 | xargs -0 -r chmod -R g+rwx
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
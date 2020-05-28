#!/bin/bash

function importKeyCert() {
  local CERT_FOLDER="${TLS_DIR:-/etc/x509/certs}"
  local CRT_FILE="tls.crt"
  local KEY_FILE="tls.key"
  local CA_FILE="ca.crt"
  local PASSWORD=$(openssl rand -base64 32 2>/dev/null)
  local TRUSTSTORE_PASSWORD=$(openssl rand -base64 32 2>/dev/null)
  local TMP_CERT=ca-bundle-temp.crt
  local -r CRT_DELIMITER="/-----BEGIN CERTIFICATE-----/"
  local KUBE_SA_FOLDER="/var/run/secrets/kubernetes.io/serviceaccount"
  local KEYSTORE_FILE="/output/resources/security/key.p12"
  local TRUSTSTORE_FILE="/output/resources/security/trust.p12"

  # Import the private key and certificate into new keytore
  if [ -f "${CERT_FOLDER}/${KEY_FILE}" ] && [ -f "${CERT_FOLDER}/${CRT_FILE}" ]; then
    echo "Found mounted TLS certificates, generating keystore"
    mkdir -p /output/resources/security
    openssl pkcs12 -export \
      -name "defaultKeyStore" \
      -inkey "${CERT_FOLDER}/${KEY_FILE}" \
      -in "${CERT_FOLDER}/${CRT_FILE}" \
      -out "${KEYSTORE_FILE}" \
      -password pass:"${PASSWORD}" >&/dev/null

     # Since we are creating new keystore, always write new password to a file
    sed "s|REPLACE|$PASSWORD|g" $SNIPPETS_SOURCE/keystore.xml > $SNIPPETS_TARGET_DEFAULTS/keystore.xml

    # Add mounted CA to the truststore
    if [ -f "${CERT_FOLDER}/${CA_FILE}" ]; then
        echo "Found mounted TLS CA certificate, adding to truststore"
        keytool -import -storetype pkcs12 -noprompt -keystore "${TRUSTSTORE_FILE}" -file "${CERT_FOLDER}/${CA_FILE}" \
          -storepass "${TRUSTSTORE_PASSWORD}" -alias "service-ca" >&/dev/null    
    fi
  fi

  # Add kubernetes CA certificates to the truststore
  # CA bundles need to be split and added as individual certificates
  if [ "$SEC_IMPORT_K8S_CERTS" = "true" ] && [ -d "${KUBE_SA_FOLDER}" ]; then
    mkdir /tmp/certs
    pushd /tmp/certs >&/dev/null
    cat ${KUBE_SA_FOLDER}/*.crt >${TMP_CERT}
    csplit -s -z -f crt- "${TMP_CERT}" "${CRT_DELIMITER}" '{*}'
    for CERT_FILE in crt-*; do
      keytool -import -storetype pkcs12 -noprompt -keystore "${TRUSTSTORE_FILE}" -file "${CERT_FILE}" \
        -storepass "${TRUSTSTORE_PASSWORD}" -alias "service-sa-${CERT_FILE}" >&/dev/null
    done
    popd >&/dev/null
    rm -rf /tmp/certs
  fi

  # Add the keystore password to server configuration
  if [ ! -e $keystorePath ]; then
    sed "s|REPLACE|$PASSWORD|g" $SNIPPETS_SOURCE/keystore.xml > $SNIPPETS_TARGET_DEFAULTS/keystore.xml
  fi
  if [ -e $TRUSTSTORE_FILE ]; then
    sed "s|PWD_TRUST|$TRUSTSTORE_PASSWORD|g" $SNIPPETS_SOURCE/truststore.xml > $SNIPPETS_TARGET_OVERRIDES/truststore.xml
  elif [ ! -z $SEC_TLS_TRUSTDEFAULTCERTS ]; then 
    cp $SNIPPETS_SOURCE/trustDefault.xml $SNIPPETS_TARGET_OVERRIDES/trustDefault.xml  
  fi
}

case "${LICENSE,,}" in
  "accept" ) # Suppress license message in logs
    grep -s -F "com.ibm.ws.logging.hideMessage" /config/bootstrap.properties \
      && sed -i 's/^\(com.ibm.ws.logging.hideMessage=.*$\)/\1,CWWKE0100I/' /config/bootstrap.properties \
      || echo "com.ibm.ws.logging.hideMessage=CWWKE0100I" >> /config/bootstrap.properties
    ;;
  "view" ) # Display license file
    cat /opt/ibm/wlp/lafiles/LI_${LANG:-en}
    exit 1
    ;;
  "" ) # Continue, displaying license message in logs
    true
    ;;
  *) # License not accepted
    echo -e "Set environment variable LICENSE=accept to indicate acceptance of license terms and conditions.\n\nLicense agreements and information can be viewed by running this image with the environment variable LICENSE=view.  You can also set the LANG environment variable to view the license in a different language."
    exit 1
    ;;
esac

SNIPPETS_SOURCE=/opt/ibm/helpers/build/configuration_snippets
SNIPPETS_TARGET_DEFAULTS=/config/configDropins/defaults
SNIPPETS_TARGET_OVERRIDES=/config/configDropins/overrides

keystorePath="$SNIPPETS_TARGET_DEFAULTS/keystore.xml"

importKeyCert

# Infinispan Session Caching
if [[ -n "$INFINISPAN_SERVICE_NAME" ]]; then
 echo "INFINISPAN_SERVICE_NAME(original): ${INFINISPAN_SERVICE_NAME}"
 INFINISPAN_SERVICE_NAME=$(echo ${INFINISPAN_SERVICE_NAME} | sed 's/-/_/g' | sed 's/./\U&/g')
 echo "INFINISPAN_SERVICE_NAME(normalized): ${INFINISPAN_SERVICE_NAME}"

 if [[ -z "$INFINISPAN_HOST" ]]; then
  eval INFINISPAN_HOST=\$${INFINISPAN_SERVICE_NAME}_SERVICE_HOST
  export INFINISPAN_HOST
 fi
 echo "INFINISPAN_HOST: ${INFINISPAN_HOST}"

 if [[ -z "$INFINISPAN_PORT" ]]; then
  eval INFINISPAN_PORT=\$${INFINISPAN_SERVICE_NAME}_SERVICE_PORT
  export INFINISPAN_PORT
 fi
 echo "INFINISPAN_PORT: ${INFINISPAN_PORT:=11222}"

 if [[ -z "$INFINISPAN_USER" ]]; then
  export INFINISPAN_USER=$(cat ${LIBERTY_INFINISPAN_SECRET_DIR:=/platform/bindings/infinispan/secret}/identities.yaml | grep -m 1 username | sed 's/username://' | sed 's/[[:space:]]*//g' | sed 's/^-//')
 fi
 echo "INFINISPAN_USER: ${INFINISPAN_USER:=developer}"

 if [[ -z "$INFINISPAN_PASS" ]]; then
  export INFINISPAN_PASS=$(cat ${LIBERTY_INFINISPAN_SECRET_DIR:=/platform/bindings/infinispan/secret}/identities.yaml | grep -m 1 password | sed 's/password://' | sed 's/[[:space:]]*//g')
 fi
 echo "INFINISPAN_PASS: ${INFINISPAN_PASS}"
fi


# Pass on to the real server run
exec "$@"

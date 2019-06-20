#!/bin/bash

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

SNIPPETS_SOURCE=/opt/ol/helpers/build/configuration_snippets
SNIPPETS_TARGET=/config/configDropins/overrides

keystorePath="$SNIPPETS_TARGET/keystore.xml"

if [ "$KEYSTORE_REQUIRED" == "true" ]
then
  # Check if the password is set already
  if [ ! -e $keystorePath ]
  then
    # Generate the keystore.xml
    export KEYSTOREPWD=$(openssl rand -base64 32)
    sed -i.bak "s|REPLACE|$KEYSTOREPWD|g" $SNIPPETS_SOURCE/keystore.xml
    cp $SNIPPETS_SOURCE/keystore.xml $SNIPPETS_TARGET/keystore.xml
  fi
fi


# Pass on to the real server run
exec "$@"

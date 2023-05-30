#!/bin/bash

# If the Liberty server name is not defaultServer and defaultServer still exists migrate the contents
if [ "$SERVER_NAME" != "defaultServer" ] && [ -d "/opt/ibm/wlp/usr/servers/defaultServer" ]; then
  # Create new Liberty server
  /opt/ibm/wlp/bin/server create >/tmp/serverOutput
  rc=$?
  if [ $rc -ne 0 ]; then
    cat /tmp/serverOutput
    rm /tmp/serverOutput
    exit $rc
  fi
  rm /tmp/serverOutput

  # Verify server creation
  if [ ! -d "/opt/ibm/wlp/usr/servers/$SERVER_NAME" ]; then
    echo "The server name contains a character that is not valid."
    exit 1
  fi
  chmod -R g+w /opt/ibm/wlp/usr/servers/$SERVER_NAME

  # Delete old symlinks
  rm /opt/ibm/links/output
  rm /opt/ibm/links/config

  # Add new output folder symlink and resolve group write permissions
  mkdir -p $WLP_OUTPUT_DIR/$SERVER_NAME
  ln -s $WLP_OUTPUT_DIR/$SERVER_NAME /opt/ibm/links/output
  chmod g+w $WLP_OUTPUT_DIR/$SERVER_NAME
  mkdir -p $WLP_OUTPUT_DIR/$SERVER_NAME/resources
  mkdir -p $WLP_OUTPUT_DIR/$SERVER_NAME/workarea
  mkdir -p $WLP_OUTPUT_DIR/$SERVER_NAME/logs
  chmod -R g+w $WLP_OUTPUT_DIR/$SERVER_NAME/workarea
  chmod -R g+w,o-rwx $WLP_OUTPUT_DIR/$SERVER_NAME/resources
  chmod -R g+w,o-rwx $WLP_OUTPUT_DIR/$SERVER_NAME/logs

  # Hand over the SCC
  if [ "$OPENJ9_SCC" = "true" ] && [ -d "/opt/ibm/wlp/output/defaultServer/.classCache" ]; then
    mv /opt/ibm/wlp/output/defaultServer/.classCache $WLP_OUTPUT_DIR/$SERVER_NAME/
  fi
  rm -rf /opt/ibm/wlp/output/defaultServer

  # Add new server symlink and populate folder
  mv /opt/ibm/wlp/usr/servers/defaultServer/* /opt/ibm/wlp/usr/servers/$SERVER_NAME/
  ln -s /opt/ibm/wlp/usr/servers/$SERVER_NAME /opt/ibm/links/config
  mkdir -p /config/configDropins/defaults
  mkdir -p /config/configDropins/overrides
  chmod -R g+w /config

  rm -rf /opt/ibm/wlp/usr/servers/defaultServer
fi

echo "configure-liberty.sh script has been run" > /opt/ibm/wlp/configure-liberty.log
exit 0

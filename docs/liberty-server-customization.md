
# How to customize your Liberty Server

## Provide a custom server name

You can provide a custom name for your Liberty server by specifying the `SERVER_NAME` environment variable at container image **build-time**.

### Building from a new image

Specifying the `ENV SERVER_NAME=<your-server-name>` variable allows you to run a Liberty server with a custom name, as in the Dockerfile below.
```Dockerfile
FROM icr.io/appcafe/websphere-liberty:kernel-java17-openj9-ubi

ENV SERVER_NAME=liberty1

RUN features.sh

RUN configure.sh
```
Running this container will produce output similar to:
```
Launching liberty1 (WebSphere Application Server 23.0.0.5/wlp-1.0.77.cl230520230514-1901) on Eclipse OpenJ9 VM, version 17.0.7+7 (en_US)
[AUDIT   ] CWWKE0001I: The server liberty1 has been launched.
[AUDIT   ] CWWKE0100I: This product is licensed for development, and limited production use. The full license terms can be viewed here: https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/license/base_ilan/ilan/23.0.0.5/lafiles/en.html
[AUDIT   ] CWWKG0093A: Processing configuration drop-ins resource: /opt/ibm/wlp/usr/servers/liberty1/configDropins/defaults/keystore.xml
[WARNING ] CWWKF0009W: The server has not been configured to install any features.
[AUDIT   ] CWWKF0012I: The server installed the following features: [].
[AUDIT   ] CWWKF0011I: The liberty1 server is ready to run a smarter planet. The liberty1 server started in 0.473 seconds.
```

### Renaming an existing Liberty server

Liberty server configurations and existing output data under `/config` and `/output`, respectively, will be relocated to the server with new name, allowing you to **rename** servers `FROM` any Liberty image.

```Dockerfile
FROM icr.io/appcafe/websphere-liberty:kernel-java17-openj9-ubi as staging

ENV SERVER_NAME=liberty1

# Initialize server configuration
COPY --chown=1001:0  server.xml /config/

RUN features.sh

RUN configure.sh

# From an existing Liberty server
FROM staging

# Rename liberty1 to liberty2, retaining /config/server.xml from above
ENV SERVER_NAME=liberty2

RUN features.sh

RUN configure.sh
```

### Notes

The new server name changes the directory of stored configurations and server output. For example, for a custom server name `liberty1`.
- `/config -> /opt/ol/wlp/usr/servers/liberty1`
- `/output -> /opt/ol/wlp/output/liberty1`

By using the symbolic links `/config` and `/output`, you can always ensure a correct mapping to the Liberty server's directories. 



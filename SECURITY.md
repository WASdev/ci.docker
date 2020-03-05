# Configuring Security

## TLS certificate configuration

### Automatically trust known certificate authorities (`20.0.0.3+`)

To enable trust certificates from known certificate authorities `SEC_TLS_TRUSTDEFAULTCERTS` environment variable can be set.
Default value is `false`. If set to true, then the default certificates are used in addition to the configured truststore file to establish trust.

### Providing custom certificates (`20.0.0.3+`)

It is possible to provide custom PEM certifacates by mounting the files into the container. Files that will be imported are `tls.key`, `tls.crt` and `ca.crt`.

The location can be specified by `TLS_DIR` environment variable. Default location
for certificates is `/etc/x509/certs/`.

The container will automatically convert PEM file and create a keystore and truststore files (key.p12 and trust.p12).

Container also can import certificates from Kubernetes.
If `SEC_IMPORT_K8S_CERTS` is set to `true` and `/var/run/secrets/kubernetes.io/serviceaccount` folder is mounted into container the `.crt` files will be imported into the the truststore file. Default value is `false`.


### Providing custom keystore

A custom keystore can be provided during the application image's build phase by simply copying the keystore into the image's  `/output/resources/security/key.p12` location. 

You must then override the keystore's password by including your copy of the `keystore.xml` file inside the `/config/configDropins/defaults/` directory.

# Applying interim fixes

This section describes the process to apply interim fixes (iFix) via the Dockerfile during `build` time, by adding the interim fix JAR files to `/opt/ibm/fixes` directory and calling `RUN configure.sh`. Interim fixes recommended by IBM, such as to resolve security vulnerabilities, are also included in the same directory. 

Ensure that all features needed by your applications, apart from the ones that will be automatically added for the [enterprise functionalities](https://github.com/WASdev/ci.docker#enterprise-functionality) you selected, are specified prior to calling `RUN configure.sh`, since interim fixes should only be applied once needed features are installed.

```dockerfile
# Add interim fixes (optional)
COPY --chown=1001:0  interim-fixes /opt/ibm/fixes/

# This script will add the requested XML snippets, grow image to be fit-for-purpose and apply interim fixes
RUN configure.sh
```
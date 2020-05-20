FROM ibmcom/websphere-liberty:kernel-java8-openj9-ubi

# Add my app and config
COPY --chown=1001:0  server.xml /config/
COPY --chown=1001:0  server.env /config/

# Default setting for the verbose option
ARG VERBOSE=true

# Optional functionality
ARG TLS=true
# trust certificates from well known CA's
ENV SEC_TLS_TRUSTDEFAULTCERTS=true
# trust certificates from within the cluster, such as Red Hat SSO.
ENV SEC_IMPORT_K8S_CERTS=true

# Enable single sign on app security using an OIDC provider and Github.  
# Further configuration is deferred until image deployment.
ARG SEC_SSO_PROVIDERS="oidc github"

# copy secured app
COPY --chown=1001:0 formlogin.war /config/apps
# copy another app
RUN mkdir -p /config/dropins
COPY --chown=1001:0 URLchecker.war /config/dropins

# This script will add the requested XML snippets and grow image to be fit-for-purpose.
RUN configure.sh
# (C) Copyright IBM Corporation 2023.
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

FROM ibm-semeru-runtimes:open-11-jre-focal

USER root

ARG VERBOSE=false
ARG OPENJ9_SCC=true

ARG LIBERTY_VERSION=23.0.0.6
ARG LIBERTY_BUILD_LABEL=cl230620230612-1100

LABEL org.opencontainers.image.authors="Leo Christy Jesuraj, Thomas Watson, Wendy Raschke, Michal Broz" \
      org.opencontainers.image.vendor="IBM" \
      org.opencontainers.image.url="https://github.com/WASdev/ci.docker" \
      org.opencontainers.image.documentation="https://www.ibm.com/support/knowledgecenter/SSAW57_liberty/com.ibm.websphere.wlp.nd.multiplatform.doc/ae/cwlp_about.html" \
      org.opencontainers.image.version="$LIBERTY_VERSION" \
      org.opencontainers.image.revision="$LIBERTY_BUILD_LABEL" \
      org.opencontainers.image.description="This image contains the WebSphere Liberty runtime with IBM Semeru Runtime Open Edition OpenJDK with OpenJ9 and Ubuntu as the base OS.  For more information on this image please see https://ibm.biz/wl-app-image-template" \
      org.opencontainers.image.title="IBM WebSphere Liberty"

ENV PATH=$PATH:/opt/ibm/wlp/bin:/opt/ibm/helpers/build

# Add labels for consumption by IBM Product Insights
LABEL "ProductID"="fbf6a96d49214c0abc6a3bc5da6e48cd" \
      "ProductName"="WebSphere Application Server Liberty" \
      "ProductVersion"="$LIBERTY_VERSION" \
      "BuildLabel"="$LIBERTY_BUILD_LABEL"

# Install dumb-init
RUN set -eux; \
    ARCH="$(dpkg --print-architecture)"; \
    case "${ARCH}" in \
       aarch64|arm64) \
         DUMB_INIT_URL='https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_aarch64'; \
         DUMB_INIT_SHA256=b7d648f97154a99c539b63c55979cd29f005f88430fb383007fe3458340b795e; \
         ;; \
       amd64|x86_64) \
         DUMB_INIT_URL='https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64'; \
         DUMB_INIT_SHA256=e874b55f3279ca41415d290c512a7ba9d08f98041b28ae7c2acb19a545f1c4df; \
         ;; \
       ppc64el|ppc64le) \
         DUMB_INIT_URL='https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_ppc64le'; \
         DUMB_INIT_SHA256=3d15e80e29f0f4fa1fc686b00613a2220bc37e83a35283d4b4cca1fbd0a5609f; \
         ;; \
       s390x) \
         DUMB_INIT_URL='https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_s390x'; \
         DUMB_INIT_SHA256=47e4601b152fc6dcb1891e66c30ecc62a2939fd7ffd1515a7c30f281cfec53b7; \
         ;;\
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    curl -LfsSo /usr/bin/dumb-init ${DUMB_INIT_URL}; \
    echo "${DUMB_INIT_SHA256} */usr/bin/dumb-init" | sha256sum -c -; \
    chmod +x /usr/bin/dumb-init;

# Install WebSphere Liberty
ARG LIBERTY_URL
ARG DOWNLOAD_OPTIONS=""
RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip openssl wget \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /licenses/ \
    && useradd -u 1001 -r -g 0 -s /usr/sbin/nologin default \
    && LIBERTY_URL=${LIBERTY_URL:-$(wget -q -O - https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/index.yml | grep -E "^\s*kernel:.*${LIBERTY_VERSION}\.zip" | sed -n 's/\s*kernel:\s//p' | tr -d '\r' )}  \
    && wget $DOWNLOAD_OPTIONS $LIBERTY_URL -U UA-IBM-WebSphere-Liberty-Docker -O /tmp/wlp.zip \
    && unzip -q /tmp/wlp.zip -d /opt/ibm \
    && rm /tmp/wlp.zip \
    && chown -R 1001:0 /opt/ibm/wlp \
    && chmod -R g+rw /opt/ibm/wlp \
    && cp -a /opt/ibm/wlp/lafiles/. /licenses/ \
    && apt-get purge --auto-remove -y unzip \
    && apt-get purge --auto-remove -y wget \
    && rm -rf /var/lib/apt/lists/*

# Set Path Shortcuts
ENV LOG_DIR=/logs \
    WLP_OUTPUT_DIR=/opt/ibm/wlp/output \
    OPENJ9_SCC=$OPENJ9_SCC

# Configure WebSphere Liberty
RUN /opt/ibm/wlp/bin/server create \
    && rm -rf $WLP_OUTPUT_DIR/.classCache /output/workarea \
    && rm -rf /opt/ibm/wlp/usr/servers/defaultServer/server.env

COPY NOTICES /opt/ibm/NOTICES
COPY helpers/ /opt/ibm/helpers/
COPY fixes/ /opt/ibm/fixes/

# Create symlinks && set permissions for non-root user
RUN mkdir /logs \
    && mkdir /etc/wlp \
    && mkdir -p /opt/ibm/wlp/usr/shared/resources/lib.index.cache \
    && mkdir -p /home/default \
    && mkdir /output \
    && chmod -t /output \
    && rm -rf /output \
    && ln -s $WLP_OUTPUT_DIR/defaultServer /output \
    && ln -s /opt/ibm/wlp/usr/servers/defaultServer /config \
    && ln -s /opt/ibm /liberty \
    && ln -s /opt/ibm/fixes /fixes \
    && ln -s /opt/ibm/wlp/usr/shared/resources/lib.index.cache /lib.index.cache \
    && mkdir -p /config/configDropins/defaults \
    && mkdir -p /config/configDropins/overrides \
    && chown -R 1001:0 /config \
    && chmod -R g+rw /config \
    && chown -R 1001:0 /opt/ibm/helpers \
    && chmod -R g+rwx /opt/ibm/helpers \
    && chown -R 1001:0 /opt/ibm/fixes \
    && chmod -R g+rwx /opt/ibm/fixes \
    && chown -R 1001:0 /opt/ibm/wlp/usr \
    && chmod -R g+rw /opt/ibm/wlp/usr \
    && chown -R 1001:0 /opt/ibm/wlp/output \
    && chmod -R g+rw /opt/ibm/wlp/output \
    && chown -R 1001:0 /logs \
    && chmod -R g+rw /logs \
    && chown -R 1001:0 /etc/wlp \
    && chmod -R g+rw /etc/wlp \
    && chown -R 1001:0 /home/default \
    && chmod -R g+rw /home/default 

# Create a new SCC layer
RUN if [ "$OPENJ9_SCC" = "true" ]; then populate_scc.sh; fi \
    && rm -rf /output/messaging /output/resources/security /logs/* $WLP_OUTPUT_DIR/.classCache \
    && chown -R 1001:0 /opt/ibm/wlp/output \
    && chmod -R g+rwx /opt/ibm/wlp/output

# These settings are needed so that we can run as a different user than 1001 after server warmup
ENV RANDFILE=/tmp/.rnd \
    OPENJ9_JAVA_OPTIONS="-XX:+IgnoreUnrecognizedVMOptions -XX:+IdleTuningGcOnIdle -Xshareclasses:name=openj9_system_scc,cacheDir=/opt/java/.scc,readonly,nonFatal -Dosgi.checkConfiguration=false"

USER 1001

EXPOSE 9080 9443

ENTRYPOINT ["/opt/ibm/helpers/runtime/docker-server.sh"]
CMD ["/opt/ibm/wlp/bin/server", "run", "defaultServer"]

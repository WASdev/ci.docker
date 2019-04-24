# (C) Copyright IBM Corporation 2015,2019.
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

FROM ibmjava:8-jre

LABEL maintainer="Arthur De Magalhaes <arthurdm@ca.ibm.com> (@arthurdm)"

RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /licenses/ \
    && useradd -u 1001 -r -g 0 -s /usr/sbin/nologin default

COPY *.html /licenses/

# Install WebSphere Liberty
ENV LIBERTY_VERSION 18.0.0_03
ARG LIBERTY_URL
ARG DOWNLOAD_OPTIONS=""
RUN LIBERTY_URL=${LIBERTY_URL:-$(wget -q -O - https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/index.yml  | grep $LIBERTY_VERSION -A 6 | sed -n 's/\s*kernel:\s//p' | tr -d '\r' )}  \
    && wget $DOWNLOAD_OPTIONS $LIBERTY_URL -U UA-IBM-WebSphere-Liberty-Docker -O /tmp/wlp.zip \
    && unzip -q /tmp/wlp.zip -d /opt/ibm \
    && rm /tmp/wlp.zip \
    && chown -R 1001:0 /opt/ibm/wlp \
    && chmod -R g+rw /opt/ibm/wlp
ENV PATH=/opt/ibm/wlp/bin:$PATH

# Add labels for consumption by IBM Product Insights
LABEL "ProductID"="fbf6a96d49214c0abc6a3bc5da6e48cd" \
      "ProductName"="WebSphere Application Server Liberty" \
      "ProductVersion"="18.0.0.3" \
      "BuildLabel"="cl180320180905-2337"

# Set Path Shortcuts
ENV LOG_DIR=/logs \
    WLP_OUTPUT_DIR=/opt/ibm/wlp/output

# Configure WebSphere Liberty
RUN /opt/ibm/wlp/bin/server create \
    && rm -rf $WLP_OUTPUT_DIR/.classCache /output/workarea

COPY docker-server /opt/ibm/docker/

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
    && ln -s /opt/ibm/wlp/usr/shared/resources/lib.index.cache /lib.index.cache \
    && mkdir -p /config/configDropins/defaults \
    && chown -R 1001:0 /config \
    && chmod -R g+rw /config \
    && chown -R 1001:0 /opt/ibm/docker/docker-server \
    && chmod -R g+rwx /opt/ibm/docker/docker-server \
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

#These settings are needed so that we can run as a different user than 1001 after server warmup
ENV RANDFILE=/tmp/.rnd \
    IBM_JAVA_OPTIONS="-Xshareclasses:name=liberty,nonfatal,cacheDir=/output/.classCache/ ${IBM_JAVA_OPTIONS}"

USER 1001

EXPOSE 9080 9443

ENV KEYSTORE_REQUIRED true

ENTRYPOINT ["/opt/ibm/docker/docker-server"]
CMD ["/opt/ibm/wlp/bin/server", "run", "defaultServer"]

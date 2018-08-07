# (C) Copyright IBM Corporation 2015,2018.
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

FROM ibmjava:8-jre-rhel

#Add labels to the image
LABEL maintainer="Arthur De Magalhaes <arthurdm@ca.ibm.com> (@arthurdm)" \
      name="WebSphere Liberty" \
      vendor="IBM" \
      version="1.0" \
      release="18.0.0.2" \
      summary="Image for WebSphere Liberty with IBM's JRE and RHEL" \
      description="This image contains the WebSphere Liberty runtime with IBM's JRE and Red Hat Enterprise Linux as the base OS.  For more information on this image please see https://github.com/WASdev/ci.docker"

# Operating System update
RUN yum makecache fast \
    && yum update -y \
    && yum -y install unzip \
    && yum clean packages \
    && yum clean headers \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && rm -rf /var/tmp/yum-*


#Add license file for certification
RUN mkdir /licenses \
    && curl -s https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/license/base_ilan/ilan/18.0.0.2/lafiles/en.html > /licenses/en.html

# Install WebSphere Liberty
ENV LIBERTY_VERSION 18.0.0_02
ARG LIBERTY_URL
ARG DOWNLOAD_OPTIONS=""
RUN LIBERTY_URL=${LIBERTY_URL:-$(wget -q -O - https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/index.yml  | grep $LIBERTY_VERSION -A 6 | sed -n 's/\s*kernel:\s//p' | tr -d '\r' )}  \
    && wget $DOWNLOAD_OPTIONS $LIBERTY_URL -U UA-IBM-WebSphere-Liberty-Docker -O /tmp/wlp.zip \
    && unzip -q /tmp/wlp.zip -d /opt/ibm \
    && rm /tmp/wlp.zip
ENV PATH=/opt/ibm/wlp/bin:$PATH

# Add labels for consumption by IBM Product Insights
LABEL "ProductID"="fbf6a96d49214c0abc6a3bc5da6e48cd" \
      "ProductName"="WebSphere Application Server Liberty" \
      "ProductVersion"="18.0.0.2"

# Set Path Shortcuts
ENV LOG_DIR=/logs \
    WLP_OUTPUT_DIR=/opt/ibm/wlp/output \
    RANDFILE=/tmp/.rnd \
    JVM_ARGS="-Xshareclasses:name=liberty,nonfatal,cacheDir=/output/.classCache/"

# Configure WebSphere Liberty
RUN /opt/ibm/wlp/bin/server create \
    && rm -rf $WLP_OUTPUT_DIR/.classCache /output/workarea

COPY docker-server /opt/ibm/docker/

# Create symlinks && set permissions for non-root user
RUN mkdir /logs \
    && ln -s $WLP_OUTPUT_DIR/defaultServer /output \
    && ln -s /opt/ibm/wlp/usr/servers/defaultServer /config  \
    && ln -s /opt/ibm /liberty \
    && useradd -u 1001 -r -g 0 -s /sbin/nologin default \
    && chown -R 1001:0 /config \
    && chmod -R g+rw /config \
    && chown -R 1001:0 /opt/ibm/docker/docker-server \
    && chmod -R g+rwx /opt/ibm/docker/docker-server \
    && chown -R 1001:0 /opt/ibm/wlp \
    && chmod -R g+rw /opt/ibm/wlp \
    && chown -R 1001:0 /logs \
    && chmod -R g+rw /logs
USER 1001

EXPOSE 9080 9443

ENV KEYSTORE_REQUIRED true

ENTRYPOINT ["/opt/ibm/docker/docker-server"]
CMD ["/opt/ibm/wlp/bin/server", "run", "defaultServer"]

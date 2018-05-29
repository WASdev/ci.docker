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

FROM ibmjava:8-jre

LABEL maintainer="Arthur De Magalhaes <arthurdm@ca.ibm.com> (@arthurdm)"

RUN apt-get update \
    && apt-get install -y --no-install-recommends unzip \
    && rm -rf /var/lib/apt/lists/*

# Install WebSphere Liberty
ENV LIBERTY_VERSION 18.0.0_01
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
      "ProductVersion"="18.0.0.1"

# Set Path Shortcuts
ENV LOG_DIR=/logs \
    WLP_OUTPUT_DIR=/opt/ibm/wlp/output
RUN mkdir /logs \
    && ln -s $WLP_OUTPUT_DIR/defaultServer /output \
    && ln -s /opt/ibm/wlp/usr/servers/defaultServer /config \
    && ln -s /opt/ibm /liberty

# Configure WebSphere Liberty
RUN /opt/ibm/wlp/bin/server create \
    && rm -rf $WLP_OUTPUT_DIR/.classCache /output/workarea
COPY docker-server /opt/ibm/docker/
EXPOSE 9080 9443

ENV KEYSTORE_REQUIRED true

ENTRYPOINT ["/opt/ibm/docker/docker-server"]
CMD ["/opt/ibm/wlp/bin/server", "run", "defaultServer"]

# (C) Copyright IBM Corporation 2018.
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

FROM registry.access.redhat.com/rhel7

LABEL maintainer="Arthur De Magalhaes <arthurdm@ca.ibm.com> (@arthurdm)"

# Operating System update
RUN yum makecache fast \
    && yum update \
    && yum -y install openssl \
    && yum clean packages \
    && yum clean headers \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && rm -rf /var/tmp/yum-*

# Create a non-root user
RUN useradd -m wlp \
    && mkdir /opt/ibm

# Create directories we'll copy artifacts into
RUN mkdir -p /opt/ibm/java && mkdir -p /opt/ibm/wlp && mkdir -p /opt/ibm/docker
    
# Copy IBM Java, WebSphere Liberty and docker-server into the image
ADD ibm /opt/ibm
RUN chmod -R 777 /opt/ibm

ENV JAVA_HOME=/opt/ibm/java
ENV PATH=/opt/ibm/wlp/bin:$PATH


# Set Path Shortcuts
ENV LOG_DIR=/logs \
    WLP_OUTPUT_DIR=/opt/ibm/wlp/output

RUN mkdir /logs \
    && ln -s $WLP_OUTPUT_DIR/defaultServer /output \
    && ln -s /opt/ibm/wlp/usr/servers/defaultServer /config  \
    && mkdir /config/configDropins \ 
    && chmod -R 777 /output \
    && chmod -R 777 /config/configDropins \
    && chmod -R 777 /logs

USER wlp

EXPOSE 9080 9443
ENTRYPOINT ["/opt/ibm/docker/docker-server"]
CMD ["/opt/ibm/wlp/bin/server", "run", "defaultServer"]

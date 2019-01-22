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

FROM centos:latest

LABEL maintainer="Arthur De Magalhaes <arthurdm@ca.ibm.com> (@arthurdm)"

# Operating System update
RUN yum makecache fast \
    && yum update -y \
    && yum -y install openssl \
    && yum clean packages \
    && yum clean headers \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && rm -rf /var/tmp/yum-*
    
# Copy IBM Java, WebSphere Liberty and docker-server into the image
COPY --from=websphere-liberty:18.0.0.3-kernel /opt/ibm/java /opt/ibm/java
COPY --from=websphere-liberty:18.0.0.3-kernel /opt/ibm/wlp /opt/ibm/wlp
COPY --from=websphere-liberty:18.0.0.3-kernel /opt/ibm/docker /opt/ibm/docker


# Set environment vars and shorcuts
ENV JAVA_HOME=/opt/ibm/java \
    PATH=/opt/ibm/wlp/bin:$PATH \
    LOG_DIR=/logs \
    WLP_OUTPUT_DIR=/opt/ibm/wlp/output \
    RANDFILE=/tmp/.rnd \
    JVM_ARGS="-Xshareclasses:name=liberty,nonfatal,cacheDir=/output/.classCache/"

# Install MicroProfile features
RUN installUtility install --acceptLicense microProfile-1.4 \
    && rm -rf /output/workarea /output/logs

# Create symlinks && set permissions for non-root user
RUN mkdir /logs \
    && ln -s $WLP_OUTPUT_DIR/defaultServer /output \
    && ln -s /opt/ibm/wlp/usr/servers/defaultServer /config  \
    && ln -s /opt/ibm /liberty \
    && mkdir /config/configDropins \
    && useradd -u 1001 -r -g 0 -s /usr/sbin/nologin default \
    && chown -R 1001:0 /config \
    && chmod -R g+rw /config \
    && chown -R 1001:0 /opt/ibm/docker/docker-server \
    && chmod -R g+rwx /opt/ibm/docker/docker-server \
    && chown -R 1001:0 /opt/ibm/wlp/usr/servers/defaultServer \
    && chmod -R g+rw /opt/ibm/wlp/usr/servers/defaultServer \
    && chown -R 1001:0 /opt/ibm/wlp/output \
    && chmod -R g+rw /opt/ibm/wlp/output \
    && chown -R 1001:0 /logs \
    && chmod -R g+rw /logs

USER 1001

# Add server.xml
COPY server.xml /config/

EXPOSE 9080 9443
ENTRYPOINT ["/opt/ibm/docker/docker-server"]
CMD ["/opt/ibm/wlp/bin/server", "run", "defaultServer"]

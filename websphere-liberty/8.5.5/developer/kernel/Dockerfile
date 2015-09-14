# (C) Copyright IBM Corporation 2015.
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

FROM java:jre

MAINTAINER Kavitha Suresh Kumar <kavisuresh@in.ibm.com> (@kavi2002suresh)

RUN apt-get update \
    && apt-get install -y wget unzip \
    && rm -rf /var/lib/apt/lists/*

# Install WebSphere Liberty
ENV LIBERTY_VERSION 8.5.5_07
RUN LIBERTY_URL=$(wget -q -O - https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wlp/index.yml  | grep $LIBERTY_VERSION -A 6 | sed -n 's/\s*kernel:\s//p' | tr -d '\r')  \
    && wget -q $LIBERTY_URL -U UA-IBM-WebSphere-Liberty-Docker -O /tmp/wlp.zip \
    && unzip -q /tmp/wlp.zip -d /opt/ibm \
    && rm /tmp/wlp.zip 	
COPY view-wlp-license /opt/ibm/docker/licenses/	
COPY license-check /opt/ibm/docker/
COPY liberty-run /opt/ibm/wlp/bin/
ENV PATH /opt/ibm/wlp/bin:$PATH

# Configure WebSphere Liberty
RUN /opt/ibm/wlp/bin/server create \
    && rm -rf /opt/ibm/wlp/usr/servers/.classCache
EXPOSE 9080 9443

ENTRYPOINT ["liberty-run"]
CMD ["/opt/ibm/wlp/bin/server", "run", "defaultServer"]

# (C) Copyright IBM Corporation 2014,2015.
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

FROM websphere-liberty:kernel

ARG REPOSITORIES_PROPERTIES=""

COPY server.xml /config/
COPY docker-server /opt/ibm/docker/
RUN if [ ! -z $REPOSITORIES_PROPERTIES ]; then mkdir /opt/ibm/wlp/etc/ \
    && echo $REPOSITORIES_PROPERTIES > /opt/ibm/wlp/etc/repositories.properties; fi \
    && installUtility install --acceptLicense \
    collectiveMember-1.0 monitor-1.0 webCache-1.0 ldapRegistry-3.0 appSecurity-2.0 localConnector-1.0 restConnector-1.0 ssl-1.0 requestTiming-1.0 sessionDatabase-1.0 \
    appSecurity-1.0 blueprint-1.0 concurrent-1.0 oauth-2.0 osgiConsole-1.0 serverStatus-1.0 wab-1.0 timedOperations-1.0 \
    webProfile-6.0 \
    && if [ ! -z $REPOSITORIES_PROPERTIES ] ; then rm /opt/ibm/wlp/etc/repositories.properties; fi \
    && rm -rf /output/workarea /output/logs

CMD ["/opt/ibm/docker/docker-server", "run", "defaultServer"]

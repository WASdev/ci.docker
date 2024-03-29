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

FROM websphere-liberty:kernel

ARG REPOSITORIES_PROPERTIES=""

RUN if [ ! -z $REPOSITORIES_PROPERTIES ]; then mkdir /opt/ibm/wlp/etc/ \
  && echo $REPOSITORIES_PROPERTIES > /opt/ibm/wlp/etc/repositories.properties; fi \
  && installUtility install --acceptLicense \
    appSecurity-2.0 ldapRegistry-3.0 \
    localConnector-1.0  \
    samlWeb-2.0 \
    openidConnectServer-1.0 \
    socialLogin-1.0 \
    openidConnectClient-1.0 \
  && if [ ! -z $REPOSITORIES_PROPERTIES ]; then rm /opt/ibm/wlp/etc/repositories.properties; fi \
  && rm -rf /output/workarea /output/logs \
  && chmod -R g+rwx /opt/ibm/wlp/output/*

COPY --chown=1001:0 server.xml /config/

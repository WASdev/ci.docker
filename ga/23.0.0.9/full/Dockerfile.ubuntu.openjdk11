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

FROM websphere-liberty:23.0.0.9-kernel-java11-openj9

ARG VERBOSE=false
ARG REPOSITORIES_PROPERTIES=""

# Install the base bundle
RUN set -eux; \
  if [ ! -z "$REPOSITORIES_PROPERTIES" ]; then \
    mkdir /opt/ibm/wlp/etc/; \
    echo "$REPOSITORIES_PROPERTIES" > /opt/ibm/wlp/etc/repositories.properties; \
  fi; \
  installUtility install --acceptLicense baseBundle; \
  if [ ! -z "$REPOSITORIES_PROPERTIES" ]; then \
    rm /opt/ibm/wlp/etc/repositories.properties; \
  fi; \
  rm -rf /output/workarea /output/logs; \
  find /opt/ibm/wlp ! -perm -g=rw -print0 | xargs -r -0 chmod g+rw;

COPY --chown=1001:0 server.xml /config/

# Create a new SCC layer
RUN if [ "$OPENJ9_SCC" = "true" ]; then populate_scc.sh; fi \
    && rm -rf /output/messaging /output/resources/security /logs/* $WLP_OUTPUT_DIR/.classCache \
    && find /opt/ibm/wlp/output ! -perm -g=rwx -print0 | xargs -0 -r chmod g+rwx

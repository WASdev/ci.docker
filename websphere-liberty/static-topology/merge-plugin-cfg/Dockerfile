# (C) Copyright IBM Corporation 2016.
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

# Install the collectiveController feature to get the required com.ibm.ws.http.plugin.merge_1.0.11.jar 
RUN installUtility install --acceptLicense collectiveController-1.0
ENV WLP_HOME=/opt/ibm/wlp
COPY pluginCfgMerge.sh /opt/ibm/wlp/bin/pluginCfgMerge.sh
CMD /opt/ibm/wlp/bin/pluginCfgMerge.sh

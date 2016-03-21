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

FROM websphere-liberty:plugin

RUN wget https://www.ibm.com/developerworks/mydeveloperworks/blogs/wasdev/resource/DefaultServletEngine.zip \
  && unzip DefaultServletEngine.zip -d /tmp/ \
  && mv /tmp/DefaultServletEngine/dropins/Sample1.war /opt/ibm/wlp/usr/servers/defaultServer/dropins/Sample1.war \
  && rm DefaultServletEngine.zip \
  && rm -rf /tmp/DefaultServletEngine

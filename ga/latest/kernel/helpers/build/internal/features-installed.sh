#!/bin/bash
# (C) Copyright IBM Corporation 2025, 2026.
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

if [ -f "/logs/features.log" ]; then
  rm /logs/features.log
  exit 0
fi  
  
>&2 echo "WARNING: This is not an optimal build configuration. Although features in server.xml will continue to be installed correctly, the 'RUN features.sh' command should be added to the Dockerfile prior to configure.sh. See https://ibm.biz/wl-app-image-template for a sample application image template."
exit 1 

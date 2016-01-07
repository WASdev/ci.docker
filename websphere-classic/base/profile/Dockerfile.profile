############################################################################
# (C) Copyright IBM Corporation 2015.                                      #
#                                                                          #
# Licensed under the Apache License, Version 2.0 (the "License");          #
# you may not use this file except in compliance with the License.         #
# You may obtain a copy of the License at                                  #
#                                                                          #
#      http://www.apache.org/licenses/LICENSE-2.0                          #
#                                                                          #
# Unless required by applicable law or agreed to in writing, software      #
# distributed under the License is distributed on an "AS IS" BASIS,        #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. #
# See the License for the specific language governing permissions and      #
# limitations under the License.                                           #
#                                                                          #
############################################################################

FROM ubuntu:14.04

MAINTAINER Kavitha Suresh Kumar <kavisuresh@in.ibm.com>

ARG user=was 

ARG group=was

COPY start.sh update*.py /work/

RUN groupadd $group && useradd $user -g $group -m \
    && chown -R $user:$group /work \
    && chmod +x /work/*.*

USER $user

ADD was.tar /

ENV PATH /opt/IBM/WebSphere/AppServer/bin:$PATH

ARG PROFILE_NAME=AppSrv01

ARG CELL_NAME=DefaultCell01

ARG NODE_NAME=DefaultNode01

ARG HOST_NAME=localhost

RUN /opt/IBM/WebSphere/AppServer/bin/manageprofiles.sh -create -templatePath /opt/IBM/WebSphere/AppServer/profileTemplates/default/ \
     -profileName $PROFILE_NAME -profilePath /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME  \
     -templatePath /opt/IBM/WebSphere/AppServer/profileTemplates/default -nodeName $NODE_NAME -cellName $CELL_NAME \
     -hostName $HOST_NAME

CMD ["/work/start.sh"]

#!/bin/bash
# (C) Copyright IBM Corporation 2020, 2025.
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
. /opt/ibm/helpers/build/internal/logger.sh

set -Eeox pipefail

pkgcmd=yum
if ! command $pkgcmd
then
  pkgcmd=microdnf
fi

$pkgcmd update -y
$pkgcmd install -y maven
mkdir -p /opt/ibm/wlp/usr/shared/resources/infinispan
echo '<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">  <modelVersion>4.0.0</modelVersion>   <groupId>io.openliberty</groupId>  <artifactId>openliberty-infinispan-client</artifactId>  <version>1.0</version>  <!-- https://mvnrepository.com/artifact/org.infinispan/infinispan-jcache-remote -->  <dependencies>    <dependency>      <groupId>org.infinispan</groupId>      <artifactId>infinispan-jcache-remote</artifactId>      <version>10.1.3.Final</version>    </dependency>  </dependencies></project>' > /opt/ibm/wlp/usr/shared/resources/infinispan/pom.xml
mvn -f /opt/ibm/wlp/usr/shared/resources/infinispan/pom.xml versions:use-latest-releases -DallowMajorUpdates=false
mvn -f /opt/ibm/wlp/usr/shared/resources/infinispan/pom.xml dependency:copy-dependencies -DoutputDirectory=/opt/ibm/wlp/usr/shared/resources/infinispan
# This fails with dependency errors using microdnf on ubi-minimal, but it is okay to let it fail
yum remove -y maven || true
rm -f /opt/ibm/wlp/usr/shared/resources/infinispan/pom.xml
rm -f /opt/ibm/wlp/usr/shared/resources/infinispan/jboss-transaction-api*.jar
rm -f /opt/ibm/wlp/usr/shared/resources/infinispan/reactive-streams-*.jar
rm -f /opt/ibm/wlp/usr/shared/resources/infinispan/rxjava-*.jar
rm -rf ~/.m2
chown -R 1001:0 /opt/ibm/wlp/usr/shared/resources/infinispan
chmod -R g+rw /opt/ibm/wlp/usr/shared/resources/infinispan


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

set -Eeo pipefail

# Recommended stable baseline for Jakarta EE 10 / JDK 17+ environments.
INFINISPAN_DEFAULT_VERSION="15.2.6.Final"
INFINISPAN_CLIENT_VERSION=${INFINISPAN_CLIENT_VERSION:-$INFINISPAN_DEFAULT_VERSION}

# Resolves the latest patch release (x.y.Z) within the specified major.minor version.
INFINISPAN_USE_LATEST_PATCH=${INFINISPAN_USE_LATEST_PATCH:-false}
# Required for Infinispan 11+ on Liberty. Hard dependency for Liberty sessionCache-1.0.
INFINISPAN_ENABLE_REACTIVE_STREAMS=${INFINISPAN_ENABLE_REACTIVE_STREAMS:-true}

pkgcmd=yum
if ! command $pkgcmd
then
  pkgcmd=microdnf
fi

$pkgcmd update -y
$pkgcmd install -y maven

CLIENT_JARS_DIR="/opt/ibm/wlp/usr/shared/resources/infinispan"
mkdir -p "${CLIENT_JARS_DIR}"

cat << EOF > ${CLIENT_JARS_DIR}/pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>io.openliberty</groupId>
  <artifactId>openliberty-infinispan-client</artifactId>
  <version>1.0</version>

  <!-- https://mvnrepository.com/artifact/org.infinispan/infinispan-jcache-remote -->
  <dependencies>
    <dependency>
      <groupId>org.infinispan</groupId>
      <artifactId>infinispan-jcache-remote</artifactId>
      <version>${INFINISPAN_CLIENT_VERSION}</version>
    </dependency>
  </dependencies>
</project>
EOF

if [ "${INFINISPAN_USE_LATEST_PATCH}" = "true" ]; then
  echo "Resolving latest Infinispan client patch release (no major upgrades)..."
  mvn -f "${CLIENT_JARS_DIR}/pom.xml" versions:use-latest-releases -DallowMajorUpdates=false
fi

mvn -f "${CLIENT_JARS_DIR}/pom.xml" dependency:copy-dependencies -DoutputDirectory="${CLIENT_JARS_DIR}"
# This fails with dependency errors using microdnf on ubi-minimal, but it is okay to let it fail
yum remove -y maven || true
rm -f "${CLIENT_JARS_DIR}/pom.xml"

# Remove unnecessary spec jars
rm -f "${CLIENT_JARS_DIR}"/jboss-transaction-api*.jar
rm -f "${CLIENT_JARS_DIR}"/jakarta.transaction-api*.jar

# Reactive streams are required for Infinispan 11+ on Liberty sessionCache-1.0
# Only remove if explicitly disabled (default: enabled)
if [ "${INFINISPAN_ENABLE_REACTIVE_STREAMS}" != "true" ]; then
  echo "Removing reactive-streams and rxjava jars as INFINISPAN_ENABLE_REACTIVE_STREAMS is not set to true..."
  rm -f "${CLIENT_JARS_DIR}"/reactive-streams-*.jar
  rm -f "${CLIENT_JARS_DIR}"/rxjava-*.jar
fi

rm -rf ~/.m2
chown -R 1001:0 "${CLIENT_JARS_DIR}"
chmod -R g+rw "${CLIENT_JARS_DIR}"

INSTALLED_VERSION=$(find "${CLIENT_JARS_DIR}/" -name "infinispan-jcache-remote-*.jar" -printf "%f" | sed 's/infinispan-commons-\(.*\).jar/\1/')

if [ -n "$INSTALLED_VERSION" ]; then
  echo "Successfully installed Infinispan client version: ${INSTALLED_VERSION}"
fi

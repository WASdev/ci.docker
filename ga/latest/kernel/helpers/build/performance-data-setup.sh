#!/bin/bash

. /opt/ibm/helpers/build/internal/logger.sh

set -Eeox pipefail

pkgcmd=yum
if ! command $pkgcmd
then
  pkgcmd=microdnf
fi

$pkgcmd update -y
$pkgcmd install -y procps-ng net-tools ncurses hostname
#!/bin/bash

set -e

#
# Source configuration environment variables
#
source ./config.sh

echo "Configuring ua attach config"
cat <<EOF >> ua-attach-config.yaml
token: $(cat /run/secrets/TOKEN)
enable_services:
- usg
- esm-infra

EOF

echo "Updating system timezone"
ln -sf "/usr/share/zoneinfo/$SYSTEM_TIMEZONE" /etc/localtime

apt-get update
apt-get -y -q install \
  ubuntu-advantage-tools ca-certificates \
  tzdata

echo "Updating system timezone"
ln -sf "/usr/share/zoneinfo/$SYSTEM_TIMEZONE" /etc/localtime

echo "UA attaching"
ua attach --attach-config ua-attach-config.yaml

apt-get -y -q install \
  usg

echo "Create dockerenv file"
touch /.dockerenv

addgroup syslog

echo "UA hardening"
usg fix disa_stig

echo "Cleaning up ua"

rm ua-attach-config.yaml

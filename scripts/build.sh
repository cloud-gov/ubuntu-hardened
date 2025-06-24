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
apt-get -y -qq install \
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

chgrp syslog /var/log

if [ -e /bin/mail-touchlock ]; then
  chgrp root /bin/mail-touchlock
fi
if [ -e /bin/mail-lock ]; then
  chgrp root /bin/mail-lock
fi
if [ -e /bin/mail-unlock ]; then
  chgrp root /bin/mail-unlock
fi
if [ -e /usr/bin/mail-touchlock ]; then
  chgrp root /usr/bin/mail-touchlock
fi
if [ -e /usr/bin/mail-lock ]; then
  chgrp root /usr/bin/mail-lock
fi
if [ -e /usr/bin/mail-unlock ]; then
  chgrp root /usr/bin/mail-unlock
fi

echo "UA hardening"
usg fix disa_stig

echo "Cleaning up ua"
rm ua-attach-config.yaml

echo "Update /var/log permissions"

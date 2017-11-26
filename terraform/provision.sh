#!/usr/bin/env bash

# Update hostname
NEW_HOSTNAME=$(ifconfig eth0 | grep 'inet addr' | cut -d ':' -f 2 | cut -d ' ' -f 1 | sed -e 's|\.|-|g'| awk '{printf "ip-%s", $0}')
sudo hostname $NEW_HOSTNAME
sed -i 's|ubuntu|'"$NEW_HOSTNAME"'|g' /etc/hostname
sed -i 's|ubuntu|'"$NEW_HOSTNAME"'|g' /etc/hosts
systemctl restart systemd-logind.service
hostnamectl set-hostname $NEW_HOSTNAME

# Start Consul
systemctl enable consul.service
systemctl start consul

# Start Nomad
systemctl enable nomad.service
systemctl start nomad

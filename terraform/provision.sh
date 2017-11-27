#!/usr/bin/env bash

# Update hostname
NEW_HOSTNAME=$(ifconfig eth0 | grep 'inet addr' | cut -d ':' -f 2 | cut -d ' ' -f 1 | sed -e 's|\.|-|g' | awk '{printf "ip-%s", $0}')
hostname $NEW_HOSTNAME
sed -i 's|ubuntu|'"$NEW_HOSTNAME"'|g' /etc/hostname
sed -i 's|ubuntu|'"$NEW_HOSTNAME"'|g' /etc/hosts
systemctl restart systemd-logind.service
hostnamectl set-hostname $NEW_HOSTNAME

# Update resolv.conf
echo "nameserver 127.0.0.1" | tee -a /etc/resolvconf/resolv.conf.d/head 
resolvconf -u

# Start Consul
systemctl enable consul.service
systemctl start consul

# Start Nomad
systemctl enable nomad.service
systemctl start nomad

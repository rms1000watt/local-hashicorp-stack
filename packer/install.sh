#!/usr/bin/env bash

echo "Installing here!"
echo "Hello world" > /home/packer/helloWorld.txt
echo $USER

# Passwordless sudo?
echo 'packer ALL=NOPASSWD:ALL' > /etc/sudoers.d/packer || true

# Disable udev persistent net rules
rm /etc/udev/rules.d/70-persistent-net.rules || true
mkdir /etc/udev/rules.d/70-persistent-net.rules || true
rm /lib/udev/rules.d/75-persistent-net-generator.rules || true
rm -rf /dev/.udev/ /var/lib/dhcp3/* || true
echo "pre-up sleep 2" >> /etc/network/interfaces || true

# Disable DNS reverse lookup
echo "UseDNS no" >> /etc/ssh/sshd_config || true

# Install and configure cloud-config
apt-get -y install cloud-init || true
sed -i 's/name: ubuntu/name: packer/g' /etc/cloud/cloud.cfg || true
sed -i 's/lock_passwd: True/lock_passwd: False/g' /etc/cloud/cloud.cfg || true

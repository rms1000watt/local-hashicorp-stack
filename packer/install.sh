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

echo "auto eth0" >> /etc/network/interfaces || true
echo "iface eth0 inet dhcp" >> /etc/network/interfaces || true

echo "auto eth1" >> /etc/network/interfaces || true
echo "iface eth1 inet dhcp" >> /etc/network/interfaces || true

sed -i 's|GRUB_CMDLINE_LINUX=""|GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"|g' /etc/default/grub
update-grub

# Disable DNS reverse lookup
echo "UseDNS no" >> /etc/ssh/sshd_config || true

#!/usr/bin/env bash

# Passwordless sudo
echo "packer ALL=NOPASSWD:ALL" > /etc/sudoers.d/packer

# Update grub to use eth0, eth1 naming convention
sed -i 's|GRUB_CMDLINE_LINUX=""|GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"|g' /etc/default/grub
update-grub

# Add eth0, eth1 network interfaces
echo "auto eth0" >> /etc/network/interfaces
echo "iface eth0 inet dhcp" >> /etc/network/interfaces

echo "auto eth1" >> /etc/network/interfaces
echo "iface eth1 inet dhcp" >> /etc/network/interfaces

# Install useful tools
apt-get -y install curl software-properties-common

# Install VirtualBox Guest Tools
apt-get -y install virtualbox-guest-dkms

#!/usr/bin/env bash

DOCKER_VERSION=17.06.2~ce-0~ubuntu
DOCKER_COMPOSE_VERSION=1.16.1

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

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get -y install docker-ce=$DOCKER_VERSION
gpasswd -a packer docker
newgrp docker

# Install Docker Compose
curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

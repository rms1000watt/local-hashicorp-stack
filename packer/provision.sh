#!/usr/bin/env bash

# Vars
DOCKER_VERSION=17.06.2~ce-0~ubuntu
DOCKER_COMPOSE_VERSION=1.16.1
NOMAD_VERSION=0.7.0
CONSUL_VERSION=1.0.0
HADOOP_VERSION=2.7.4

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

# Install dependencies
apt-get -y install software-properties-common
apt-get update
apt-get install -y curl wget unzip tree redis-tools jq

# Install VirtualBox Guest Tools
apt-get -y install virtualbox-guest-dkms

# Numpy (for Spark)
apt-get install -y python-setuptools
easy_install pip
pip install numpy

# Consul
if [ ! -f /bin/consul ]; then
  curl -L -o consul_${CONSUL_VERSION}_linux_amd64.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
  unzip -d /bin consul_${CONSUL_VERSION}_linux_amd64.zip
  rm consul_${CONSUL_VERSION}_linux_amd64.zip
  chmod +x /bin/consul
fi

# Nomad
if [ ! -f /bin/nomad ]; then
  curl -L -o nomad_${NOMAD_VERSION}_linux_amd64.zip https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip
  unzip -d /bin nomad_${NOMAD_VERSION}_linux_amd64.zip
  rm nomad_${NOMAD_VERSION}_linux_amd64.zip
  chmod +x /bin/nomad
fi

# Install Docker
if [ ! -f /usr/bin/docker ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  apt-get update
  apt-get -y install docker-ce=$DOCKER_VERSION
  gpasswd -a packer docker
  newgrp docker
fi

# Install Docker Compose
if [ ! -f /usr/local/bin/docker-compose ]; then
  curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
fi

# Java
sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get update 
sudo apt-get install -y openjdk-8-jdk
JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")

# Spark with Nomad scheduling
if [ ! -f /usr/local/bin/spark ]; then
  sudo wget -P /ops/examples/spark https://s3.amazonaws.com/nomad-spark/spark-2.2.0-bin-nomad-0.7.0.tgz
  sudo tar -xvf /ops/examples/spark/spark-2.2.0-bin-nomad-0.7.0.tgz --directory /ops/examples/spark
  sudo mv /ops/examples/spark/spark-2.2.0-bin-nomad-0.7.0 /usr/local/bin/spark
  sudo chown -R root:root /usr/local/bin/spark
fi

# Hadoop (to enable the HDFS CLI)
wget -O - http://apache.mirror.iphh.net/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | sudo tar xz -C /usr/local/

# Update ~/.bashrc for Spark
echo "export PATH=$PATH:/usr/local/bin/spark/bin:/usr/local/hadoop-$HADOOP_VERSION/bin" | sudo tee --append /home/packer/.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre" | sudo tee --append /home/packer/.bashrc

#!/usr/bin/env bash

DOCKER_VERSION=17.06.2~ce-0~ubuntu
DOCKER_COMPOSE_VERSION=1.16.1
NOMAD_VERSION=0.7.0
CONSUL_VERSION=1.0.0

# Install packages
apt-get -y install unzip

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

# Install Nomad
if [ ! -f /bin/nomad ]; then
  curl -L -o nomad_${NOMAD_VERSION}_linux_amd64.zip https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip
  unzip -d /bin nomad_${NOMAD_VERSION}_linux_amd64.zip
  chmod +x /bin/nomad
  systemctl enable nomad.service
  systemctl start nomad
fi

# Install Consul
if [ ! -f /bin/consul ]; then
  curl -L -o consul_${CONSUL_VERSION}_linux_amd64.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
  unzip -d /bin consul_${CONSUL_VERSION}_linux_amd64.zip
  chmod +x /bin/consul
  # systemctl enable consul.service
  # systemctl start consul
fi


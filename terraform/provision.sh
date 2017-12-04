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

# TODO: Remove this and provision at Packer time
# Update ~/.bashrc for Spark
if ! grep -q "/usr/local/bin/spark/bin" ~/.bashrc; then 
  echo "export PATH=$PATH:/usr/local/bin/spark/bin:/usr/local/hadoop-2.7.4/bin" | sudo tee -a ~/.bashrc
fi

if ! grep -q "java-8-openjdk-amd64" ~/.bashrc; then 
  echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre" | sudo tee -a ~/.bashrc 
fi

# Update ~/.bashrc for Spark
if ! grep -q "NOMAD_ADDR" ~/.bashrc; then 
  echo "export NOMAD_ADDR=http://server-1:4646" | sudo tee -a ~/.bashrc
fi

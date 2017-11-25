#!/usr/bin/env bash

# TODO: Update hostname

# Start Consul
systemctl enable consul.service
systemctl start consul

# Start Nomad
systemctl enable nomad.service
systemctl start nomad

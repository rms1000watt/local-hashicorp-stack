# Local HashiCorp Stack

## Introduction

HashiCorp tools enable you to build/maintain multi-datacenter systems with ease. However, you usually don't have datacenters to play with. This project builds VirtualBox VMs that you can run Terraform against to play with Nomad, Consul, etc.

The workflow is:
- Build ISOs (Packer)
- Deploy VMs to your local machine (Terraform + 3rd Party Provider)
- Play with Nomad, Consul, etc.

(Packer is used directly instead of Vagrant so the pipeline is the same when you build & deploy against hypervisors and clouds)

## Contents

- [Prerequisites](#prerequisites)
- [Build](#build)
- [Deploy](#deploy)
- [Jobs](#jobs)
- [UI](#ui)
- [Attributions](#attributions)

## Prerequisites

- OS X
- [Homebrew](https://brew.sh/)
- `brew install packer terraform nomad`
- `brew cask install virtualbox`

## Build

```bash
cd packer
packer build -on-error=abort -force packer.json
cd output-virtualbox-iso
tar -zcvf ubuntu-16.04-docker.box *.ovf *.vmdk
cd ../..
```

## Deploy

```bash
cd terraform
terraform init
terraform apply
cd ..
```

## Jobs

Take the IP Address of the server deployment and run Nomad jobs:

```bash
cd nomad
nomad run -address http://192.168.0.118:4646 redis-job.nomad
nomad run -address http://192.168.0.118:4646 echo-job.nomad
cd ..
```

At a later time, you can stop the nomad jobs (but first look at [the UI](#ui)!):

```bash
cd nomad
nomad stop -address http://192.168.0.118:4646 Echo-Job
nomad stop -address http://192.168.0.118:4646 Redis-Job
cd ..
```

## UI

Using the IP Address of the server deployment, you can:

- view the Nomad UI at: [http://192.168.0.118:4646/ui](http://192.168.0.118:4646/ui)
- view the Consul UI at: [http://192.168.0.118:8500/ui](http://192.168.0.118:8500/ui)

## Attributions

- [https://github.com/geerlingguy/packer-ubuntu-1604](https://github.com/geerlingguy/packer-ubuntu-1604)
- [https://github.com/ccll/terraform-provider-virtualbox](https://github.com/ccll/terraform-provider-virtualbox)

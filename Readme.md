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
- [Play](#play)
- [Attributions](#attributions)

## Prerequisites

- OS X
- Homebrew
- `brew install packer terraform`
- Install VirtualBox manually (`brew cask install virutalbox` was breaking on High Sierra)

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

## Play

Take the IP Address from the Terraform output then SSH into the VM, for example:

```bash
ssh packer@192.168.0.118
```

## Attributions

- [https://github.com/geerlingguy/packer-ubuntu-1604](https://github.com/geerlingguy/packer-ubuntu-1604)
- [https://github.com/ccll/terraform-provider-virtualbox](https://github.com/ccll/terraform-provider-virtualbox)

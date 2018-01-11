# Local HashiCorp Stack

## Introduction

This projects lets you run a 3 Server + 3 Client Nomad/Consul cluster in 6 Virtualbox VMs on OS X using Packer & Terraform

## Contents

- [Motivation](#motivation)
- [Prerequisites](#prerequisites)
- [Build](#build)
- [Deploy](#deploy)
- [Jobs](#jobs)
- [UI](#ui)
- [HDFS](#hdfs)
- [Spark](#spark)
- [Attributions](#attributions)

## Motivation

HashiCorp tools enable you to build/maintain multi-datacenter systems with ease. However, you usually don't have datacenters to play with. This project builds VirtualBox VMs that you can run Terraform against to play with Nomad, Consul, etc.

The workflow is:
- Build ISOs (Packer)
- Deploy VMs to your local machine (Terraform + 3rd Party Provider)
- Play with Nomad, Consul, etc.

(Packer is used directly instead of Vagrant so the pipeline is the same when you build & deploy against hypervisors and clouds)

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
# Remove any cached golden images before redeploying
rm -rf ~/.terraform/virtualbox/gold/ubuntu-16.04-docker 
terraform init
terraform apply
cd ..
```

You can ssh onto a host by running:

```bash
ssh -o 'IdentitiesOnly yes' packer@192.168.0.118
# password: packer
```

## Jobs

Take the IP Address of the server deployment and run Nomad jobs:

```bash
cd jobs
nomad run -address http://192.168.0.118:4646 redis-job.nomad
nomad run -address http://192.168.0.118:4646 echo-job.nomad
nomad run -address http://192.168.0.118:4646 golang-redis-pg.nomad
cd ..
```

You can view the logs of an `allocation`:

```bash
nomad logs -address http://192.168.0.118:4646 bf90d9cb
```

At a later time, you can stop the nomad jobs (but first look at [the UI](#ui)):

```bash
cd jobs
nomad stop -address http://192.168.0.118:4646 Echo-Job
nomad stop -address http://192.168.0.118:4646 Redis-Job
nomad stop -address http://192.168.0.118:4646 Golang-Redis-PG
cd ..
```

## UI

Using the IP Address of the server deployment, you can:

- view the Nomad UI at: [http://192.168.0.118:4646/ui](http://192.168.0.118:4646/ui)
- view the Consul UI at: [http://192.168.0.118:8500/ui](http://192.168.0.118:8500/ui)

## HDFS

You can deploy HDFS by running:

```bash
cd jobs
nomad run -address http://192.168.0.118:4646 hdfs.nomad
cd ..
```

(Give it a minute to download the docker image..)

Then you can view the UI at: [http://192.168.0.118:50070/](http://192.168.0.118:50070/)

## Spark

SSH into a server node then start PySpark:

```bash
pyspark \
--master nomad \
--conf spark.executor.instances=2 \
--conf spark.nomad.datacenters=dc-1 \
--conf spark.nomad.sparkDistribution=local:///usr/local/bin/spark
```

Then run some PySpark commands:

```python
df = spark.read.json("/usr/local/bin/spark/examples/src/main/resources/people.json")
df.show()
df.printSchema()
df.createOrReplaceTempView("people")
sqlDF = spark.sql("SELECT * FROM people")
sqlDF.show()
```

## Attributions

- [https://github.com/geerlingguy/packer-ubuntu-1604](https://github.com/geerlingguy/packer-ubuntu-1604)
- [https://github.com/ccll/terraform-provider-virtualbox](https://github.com/ccll/terraform-provider-virtualbox)
- [https://github.com/hashicorp/nomad/tree/master/terraform](https://github.com/hashicorp/nomad/tree/master/terraform)

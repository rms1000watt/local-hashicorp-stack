resource "virtualbox_vm" "server" {
    count = 3
    name = "${format("server-%02d", count.index+1)}"
    image = "../packer/output-virtualbox-iso/ubuntu-16.04-docker.box"
    cpus = 1
    memory = "512 mb"
    network_adapter {
        type = "bridged"
        host_interface = "en0"
    }
}

resource "virtualbox_vm" "client" {
    count = 3
    name = "${format("client-%02d", count.index+1)}"
    image = "../packer/output-virtualbox-iso/ubuntu-16.04-docker.box"
    cpus = 1
    memory = "2048 mb"
    network_adapter {
        type = "bridged"
        host_interface = "en0"
    }
}

resource "null_resource" "server-provisioner" {
    # Run server-provisioner if the mac address changes (if machine is deleted not just turned off)
    triggers {
        mac_addresses = "${join(",", virtualbox_vm.server.*.network_adapter.0.mac_address)}"
    }

    count = "${virtualbox_vm.server.count}"
    connection {
        type     = "ssh"
        host     = "${element(virtualbox_vm.server.*.network_adapter.0.ipv4_address, count.index)}"
        user     = "packer"
        password = "packer"
        timeout  = "1m"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo mkdir /nomad",
            "sudo mkdir /consul",
            "sudo chmod 777 /nomad",
            "sudo chmod 777 /consul",
        ]
    }

    provisioner "file" {
        source      = "../nomad/server.hcl"
        destination = "/nomad/server.hcl"
    }

    provisioner "file" {
        source      = "../nomad/systemd-nomad-server.service"
        destination = "/nomad/systemd-nomad-server.service"
    }

    provisioner "file" {
        source      = "../consul/server.json"
        destination = "/consul/server.json"
    }

    provisioner "file" {
        source      = "../consul/systemd-consul-server.service"
        destination = "/consul/systemd-consul-server.service"
    }

    provisioner "file" {
        source      = "provision.sh"
        destination = "/home/packer/provision.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "echo '${element(virtualbox_vm.server.*.network_adapter.0.ipv4_address, 1)} server-1' | sudo tee -a /etc/hosts",
            "echo '${element(virtualbox_vm.server.*.network_adapter.0.ipv4_address, 2)} server-2' | sudo tee -a /etc/hosts",
            "echo '${element(virtualbox_vm.server.*.network_adapter.0.ipv4_address, 3)} server-3' | sudo tee -a /etc/hosts",
            "sudo mv /nomad/systemd-nomad-server.service /etc/systemd/system/nomad.service",
            "sudo mv /consul/systemd-consul-server.service /etc/systemd/system/consul.service",
            "chmod a+x /home/packer/provision.sh",
            "sudo /home/packer/provision.sh",
        ]
    }
}

resource "null_resource" "client-provisioner" {
    # Run client-provisioner if the mac address changes (if machine is deleted not just turned off)
    triggers {
        mac_addresses = "${join(",", virtualbox_vm.client.*.network_adapter.0.mac_address)}"
    }

    count = "${virtualbox_vm.client.count}"
    connection {
        type     = "ssh"
        host     = "${element(virtualbox_vm.client.*.network_adapter.0.ipv4_address, count.index)}"
        user     = "packer"
        password = "packer"
        timeout  = "1m"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo mkdir /nomad",
            "sudo mkdir /consul",
            "sudo chmod 777 /nomad",
            "sudo chmod 777 /consul",
        ]
    }

    provisioner "file" {
        source      = "../nomad/client.hcl"
        destination = "/nomad/client.hcl"
    }

    provisioner "file" {
        source      = "../nomad/systemd-nomad-client.service"
        destination = "/nomad/systemd-nomad-client.service"
    }

    provisioner "file" {
        source      = "../consul/client.json"
        destination = "/consul/client.json"
    }

    provisioner "file" {
        source      = "../consul/systemd-consul-client.service"
        destination = "/consul/systemd-consul-client.service"
    }

    provisioner "file" {
        source      = "provision.sh"
        destination = "/home/packer/provision.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "echo '${element(virtualbox_vm.server.*.network_adapter.0.ipv4_address, 1)} server-1' | sudo tee -a /etc/hosts",
            "echo '${element(virtualbox_vm.server.*.network_adapter.0.ipv4_address, 2)} server-2' | sudo tee -a /etc/hosts",
            "echo '${element(virtualbox_vm.server.*.network_adapter.0.ipv4_address, 3)} server-3' | sudo tee -a /etc/hosts",
            "sudo mv /nomad/systemd-nomad-client.service /etc/systemd/system/nomad.service",
            "sudo mv /consul/systemd-consul-client.service /etc/systemd/system/consul.service",
            "chmod a+x /home/packer/provision.sh",
            "sudo /home/packer/provision.sh",
        ]
    }
}

output "Servers" {
    value = ["${virtualbox_vm.server.*.network_adapter.0.ipv4_address}"]
}

output "Clients" {
    value = ["${virtualbox_vm.client.*.network_adapter.0.ipv4_address}"]
}

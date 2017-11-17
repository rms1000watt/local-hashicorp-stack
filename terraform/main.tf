resource "virtualbox_vm" "server" {
    count = 1
    name = "${format("server-%02d", count.index+1)}"
    image = "../packer/output-virtualbox-iso/ubuntu-16.04-docker.box"
    cpus = 2
    memory = "1.0 gib"
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

    connection {
        type     = "ssh"
        host     = "${element(virtualbox_vm.server.*.network_adapter.0.ipv4_address, 1)}"
        user     = "packer"
        password = "packer"
        timeout  = "1m"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo mkdir /nomad",
            "sudo chmod 777 /nomad",
            "sudo mkdir /consul",
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
        source      = "provision-server.sh"
        destination = "/home/packer/provision-server.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo mv /nomad/systemd-nomad-server.service /etc/systemd/system/nomad.service",
            "sudo mv /consul/systemd-consul-server.service /etc/systemd/system/consul.service",
            "chmod a+x /home/packer/provision-server.sh",
            "sudo /home/packer/provision-server.sh",
        ]
    }
}

output "Server Connection" {
    value = "ssh packer@${element(virtualbox_vm.server.*.network_adapter.0.ipv4_address, 1)}"
}

# output "Client Connections" {
#     value = ["ssh packer@${virtualbox_vm.client.*.network_adapter.0.ipv4_address}"]
# }

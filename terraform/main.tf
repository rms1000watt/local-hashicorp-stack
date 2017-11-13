resource "virtualbox_vm" "node" {
    count = 1
    name = "${format("node-%02d", count.index+1)}"
    image = "../packer/output-virtualbox-iso/ubuntu-16.04-docker.box"
    cpus = 2
    memory = "1024mib"
    network_adapter {
        type = "bridged"
        host_interface = "en0"
    }
}

resource "null_resource" "node-provisioner" {
    connection {
        type     = "ssh"
        host     = "${element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 1)}"
        user     = "packer"
        password = "packer"
    }

    provisioner "file" {
        source      = "provision.sh"
        destination = "/home/packer/provision.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod a+x /home/packer/provision.sh",
            "/home/packer/provision.sh",
        ]
    }
}

output "IP Address" {
    value = "${element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 1)}"
}

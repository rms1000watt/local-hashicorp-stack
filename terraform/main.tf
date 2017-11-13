resource "virtualbox_vm" "node" {
    count = 1
    name = "${format("node-%02d", count.index+1)}"
    image = "../packer/output-virtualbox-iso/ubuntu-16.04-docker.box"
    cpus = 2
    memory = "1024mib"
    # user_data = "${file("install.sh")}"
    network_adapter {
        type = "bridged"
        host_interface = "en0"
    }
}

output "IP Address" {
    value = "${element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 1)}"
}

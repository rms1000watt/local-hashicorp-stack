resource "virtualbox_vm" "node" {
    count = 1
    name = "${format("node-%02d", count.index+1)}"
    image = "../packer/output-virtualbox-iso/test-ubuntu-xenial-5.box"
    cpus = 2
    memory = "1024mib"
    # user_data = "${file("install.sh")}"

    network_adapter {
      type = "nat"
    }

    network_adapter {
        type = "bridged"
        host_interface = "en0"
    }
}

output "IPAddr" {
    value = "${element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 1)}"
}

output "IPAddr_2" {
    value = "${element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 2)}"
}


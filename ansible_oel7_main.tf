terraform {
  required_providers {
    virtualbox = {
      source  = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

resource "virtualbox_vm" "node" {
  name   = "ansnode1"
  image  = "oel7.box"
  cpus   = 1
  memory = "1512 mib"


  network_adapter {
    type           = "bridged"
    host_interface = "Realtek RTL8188CU Wireless LAN 802.11n USB 2.0 Network Adapter"
  }


}

output "IPAddr" {
  value = element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 1)
}

resource "null_resource" "execute_script" {
  depends_on = [virtualbox_vm.node]

  connection {
    type     = "ssh"
    host     = element(virtualbox_vm.node.*.network_adapter.0.ipv4_address, 1)
    user     = "vagrant"
    password = "vagrant"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y yum-utils",
      "sudo yum install -y oracle-epel-release-el7",
      "sudo yum-config-manager --enable ol7_developer_EPEL",
      "sudo yum install git -y",
      "cd /tmp",
      "sudo git clone https://github.com/NithinSunke/ansible-script.git",
      "cd /tmp/ansible-script",
      "sudo chown -R 777 *",
      "sudo sh install_ansible.sh",
      "sudo hostnamectl set-hostname ansibles1.scs.com"
    ]
  }
}

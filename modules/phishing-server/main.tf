terraform {
  required_version = ">= 0.11.0"
}

provider "azurerm" {
  version = ">=1.20.0"
}

resource "tls_private_key" "ssh" {
  algorithm   = "RSA"
  rsa_bits    = "4096"
}

resource "azurerm_virtual_machine" "phish_vm" {
  name                  = "gophish-${var.domain}"
  location              = "australiaeast"
  resource_group_name   = "${var.resource_group}"
  network_interface_ids = ["${var.nic_id}"]
  vm_size               = "Standard_B2s"
  delete_os_disk_on_termination = true

  storage_os_disk {
    name              = "osdisk-${var.domain}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "gophish-${var.customer}"
    admin_username = "gophishadm"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/gophishadm/.ssh/authorized_keys"
      key_data = "${tls_private_key.ssh.public_key_openssh}"
    }
  }

  provisioner "file" {
    source = "${var.certificate_file_path}"
    destination = "/tmp/cert.pem"

    connection {
      host = "${var.public_ip}"
      type = "ssh"
      user = "gophishadm"
      private_key = "${tls_private_key.ssh.private_key_pem}"
    }
  }

  provisioner "file" {
    source = "${var.certificate_private_key_file_path}"
    destination = "/tmp/privkey.pem"

    connection {
      host = "${var.public_ip}"
      type = "ssh"
      user = "gophishadm"
      private_key = "${tls_private_key.ssh.private_key_pem}"
    }
  }

  provisioner "file" {
    source = "./scripts/gophish_install.sh"
    destination = "/tmp/gophish_install.sh"

    connection {
      host = "${var.public_ip}"
      type = "ssh"
      user = "gophishadm"
      private_key = "${tls_private_key.ssh.private_key_pem}"
    }
  }

  provisioner "file" {
    source = "./scripts/gophish.service"
    destination = "/tmp/gophish.service"

    connection {
      host = "${var.public_ip}"
      type = "ssh"
      user = "gophishadm"
      private_key = "${tls_private_key.ssh.private_key_pem}"
    }
  }

  provisioner "file" {
    source = "./scripts/gophish_service.sh"
    destination = "/tmp/gophish_service.sh"

    connection {
      host = "${var.public_ip}"
      type = "ssh"
      user = "gophishadm"
      private_key = "${tls_private_key.ssh.private_key_pem}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y unzip curl jq",
      "sudo chmod +x /tmp/gophish_install.sh",
      "sudo /tmp/gophish_install.sh"
    ]

    connection {
      host = "${var.public_ip}"
      type = "ssh"
      user = "gophishadm"
      private_key = "${tls_private_key.ssh.private_key_pem}"
    }
  }

  // make the ssh_keys folder if it doesn't exist.
  provisioner "local-exec" {
    command = "mkdir -p ./ssh_keys" 
  }

  // setup ssh keys in the ssh_keys folder.  add Aliasing support for easy to use ssh
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.ssh.private_key_pem}\" > ./ssh_keys/phishing_server_${var.customer} && echo \"${tls_private_key.ssh.public_key_openssh}\" > ./ssh_keys/phishing_server_${var.customer}.pub" 
  }

  provisioner "local-exec" {
    command = "chmod 600 ./ssh_keys/phishing_server_${var.customer}"
  }

  // remove the keys from the ssh_keys server and remove any aliasing
  provisioner "local-exec" {
    when = "destroy"
    command = "rm ./ssh_keys/phishing_server_${var.customer}*"
  }

  tags = {
    customer = "${var.customer}"
    campaign = "${var.domain}"
  }
}

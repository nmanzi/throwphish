output "nic_id" {
  value = "${azurerm_network_interface.phish_nic.id}"
}

output "public_ip" {
  value = "${azurerm_public_ip.phish_pip.ip_address}"
}
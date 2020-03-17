output "name_servers" {
  value = "${azurerm_dns_zone.phish_dns_zone.name_servers}"
}

output "acme_id" {
  value = "${azurerm_dns_txt_record.phish_dns_acme.id}"
}
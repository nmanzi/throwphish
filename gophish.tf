// --------------------------------------
// Minimum required TF version is 0.11.0

terraform {
  required_version = ">= 0.11.0"
}

// Create Resource Group

resource "azurerm_resource_group" "phish_rg" {
  name     = "RG-PHISH-${var.domain}"
  location = "australiaeast"

  tags = {
    customer = "${var.customer}"
    campaign = "${var.domain}"
  }
}

// Create prerequisite networking

module "create_networking" {
  source = "./modules/azure_networking"
  domain = "${var.domain}"
  resource_group = "${azurerm_resource_group.phish_rg.name}"
  customer = "${var.customer}"
}

// Create DNS Zone and Records

module "create_dns" {
  source = "./modules/azure_dns"
  domain = "${var.domain}"
  resource_group = "${azurerm_resource_group.phish_rg.name}"
  hostname = "${var.hostname}"
  ip_address = "${module.create_networking.public_ip}"
  customer = "${var.customer}"
  azure_client_id = "${var.azure_client_id}"
  azure_client_secret = "${var.azure_client_secret}"
}

// Create ACME Certificate for domain

module "create_letsencrypt_cert" {
  source = "./modules/letsencrypt"
  domain = "${var.domain}"
  hostname = "${var.hostname}"
  reg_email = "${var.support_email}"
  resource_group = "${azurerm_resource_group.phish_rg.name}"
  acme_id = "${module.create_dns.acme_id}"
  azure_client_id = "${var.azure_client_id}"
  azure_client_secret = "${var.azure_client_secret}"
}

// Create the Phishing Server

module "phishing_server" {
  source = "./modules/phishing-server"
  nic_id = "${module.create_networking.nic_id}"
  domain = "${var.domain}"
  customer = "${var.customer}"
  resource_group = "${azurerm_resource_group.phish_rg.name}"
  public_ip = "${module.create_networking.public_ip}"
  certificate_file_path = "${module.create_letsencrypt_cert.certificate_file_path}"
  certificate_private_key_file_path = "${module.create_letsencrypt_cert.certificate_private_key_file_path}"
}

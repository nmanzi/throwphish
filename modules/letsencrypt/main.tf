terraform {
  required_version = ">= 0.11.0"
}

provider "azurerm" {
  version = ">=1.20.0"
}

data "azurerm_client_config" "current_client" {}

# Create the private key for the registration (not the certificate)
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits = "${var.key_type}"
}

provider "acme" {
  server_url = "${lookup(var.server_urls, var.server_url)}"
}

# Set up a registration using a private key from tls_private_key
resource "acme_registration" "reg" {
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address   = "${var.reg_email}"
}

# Create a certificate
resource "acme_certificate" "certificate" {
  account_key_pem           = "${acme_registration.reg.account_key_pem}"
  common_name               = "${var.hostname}.${var.domain}"
  depends_on                = [var.acme_id]

  dns_challenge {
    provider = "azure"

    config = {
      AZURE_CLIENT_ID         = "${var.azure_client_id}"
      AZURE_CLIENT_SECRET     = "${var.azure_client_secret}"
      AZURE_SUBSCRIPTION_ID   = "${data.azurerm_client_config.current_client.subscription_id}"
      AZURE_TENANT_ID         = "${data.azurerm_client_config.current_client.tenant_id}"
      AZURE_RESOURCE_GROUP    = "${var.resource_group}"
    }
  }

  provisioner "local-exec" {
    command = "mkdir -p ./data/certificates"
  }

  provisioner "local-exec" {
    command = "echo \"${self.private_key_pem}\" > ./data/certificates/${self.common_name}_privkey.pem && echo \"${self.certificate_pem}\" > ./data/certificates/${self.common_name}_cert.pem"
  }

  provisioner "local-exec" {
    when = "destroy"
    command = "rm ./data/certificates/${self.common_name}*"
  }
}

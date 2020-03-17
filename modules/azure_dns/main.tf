terraform {
  required_version = ">= 0.11.0"
}

provider "azurerm" {
  version = ">=1.20.0"
}

resource "azurerm_dns_zone" "phish_dns_zone" {
  name                = "${var.domain}"
  resource_group_name = "${var.resource_group}"
  // Defaults to public zone type
  
  tags = {
    customer = "${var.customer}"
    campaign = "${var.domain}"
  }
}

// Phishing Server Record

resource "azurerm_dns_a_record" "phish_dns_a_record" {
  name                = "${var.hostname}"
  zone_name           = "${azurerm_dns_zone.phish_dns_zone.name}"
  resource_group_name = "${var.resource_group}"
  ttl                 = 300
  records             = ["${var.ip_address}"]

  tags = {
    customer = "${var.customer}"
    campaign = "${var.domain}"
  }
}

// SPF Record

resource "azurerm_dns_txt_record" "phish_dns_spf" {
  name                = "@"
  zone_name           = "${azurerm_dns_zone.phish_dns_zone.name}"
  resource_group_name = "${var.resource_group}"
  ttl                 = 300

  record {
    value = "v=spf1 a mx include:sendgrid.net ~all"
  }

  tags = {
    customer = "${var.customer}"
    campaign = "${var.domain}"
  }
}

// LetsEncrypt Record

resource "azurerm_dns_txt_record" "phish_dns_acme" {
  name                = "_acme-challenge.${var.hostname}"
  zone_name           = "${azurerm_dns_zone.phish_dns_zone.name}"
  resource_group_name = "${var.resource_group}"
  ttl                 = 300

  record {
    value = "validation"
  }

  tags = {
    customer = "${var.customer}"
    campaign = "${var.domain}"
  }
}
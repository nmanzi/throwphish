terraform {
  required_version = ">= 0.11.0"
}

provider "azurerm" {
  version = ">=1.20.0"
}

data "external" "get_public_ip" {
  program = ["bash", "./scripts/get_public_ip.sh" ]
}

resource "azurerm_virtual_network" "phish_vnet" {
  name                = "vnet_${var.domain}"
  address_space       = ["10.0.0.0/16"]
  location            = "australiaeast"
  resource_group_name = "${var.resource_group}"

  tags = {
    customer = "${var.customer}"
    campaign = "${var.domain}"
  }
}

resource "azurerm_subnet" "phish_subnet" {
  name                 = "snet_${var.domain}"
  resource_group_name  = "${var.resource_group}"
  virtual_network_name = "${azurerm_virtual_network.phish_vnet.name}"
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_public_ip" "phish_pip" {
  name                         = "pip_${var.domain}"
  location                     = "australiaeast"
  resource_group_name          = "${var.resource_group}"
  allocation_method            = "Static"

  tags = {
    customer = "${var.customer}"
    campaign = "${var.domain}"
  }
}

resource "azurerm_network_security_group" "phish_nsg" {
  name                = "nsg_${var.domain}"
  location            = "australiaeast"
  resource_group_name = "${var.resource_group}"
  
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "${data.external.get_public_ip.result["ip"]}/32"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "GoPhish-Admin"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3333"
    source_address_prefix      = "${data.external.get_public_ip.result["ip"]}/32"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "GoPhish-HTTP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "GoPhish-HTTPS"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    customer = "${var.customer}"
    campaign = "${var.domain}"
  }
}

resource "azurerm_network_interface" "phish_nic" {
  name                = "nic_${var.domain}"
  location            = "australiaeast"
  resource_group_name = "${var.resource_group}"
  network_security_group_id = "${azurerm_network_security_group.phish_nsg.id}"

  ip_configuration {
    name                          = "nicConfig"
    subnet_id                     = "${azurerm_subnet.phish_subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.phish_pip.id}"
  }

  tags = {
    customer = "${var.customer}"
    campaign = "${var.domain}"
  }
}
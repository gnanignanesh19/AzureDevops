terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.80.0"
    }
  }
}

provider "azurerm" {
  features {}
}


locals {
  rg_name     = azurerm_resource_group.rgname.name
  rg_location = azurerm_resource_group.rgname.location
}

locals {
  prefix = "NextOps"
}

resource "azurerm_resource_group" "rgname" {
  name     = local.rg_name
  location = local.rg_name
}

resource "azurerm_virtual_network" "nextopsvnet04" {
  name                  = var.vnet_name
  resource_group_name   = local.rg_name
  location              = local.rg_location
  address_space         = ["10.4.0.0/16"]  
}

resource "azurerm_subnet" "subnet01" {
  name                 = var.subnet01_name
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.nextopsvnet04.name
  address_prefixes     = ["10.4.1.0/24"]
}

resource "azurerm_subnet" "subnet02" {
  name                 = var.subnet02_name
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.nextopsvnet04.name
  address_prefixes     = ["10.4.0.0/24"]
}

resource "azurerm_network_security_group" "nsg01" {
  name                = "nextopsnsgt04"
  resource_group_name = local.rg_name
  location            = local.rg_location
  depends_on          = [ azurerm_subnet.subnet01, azurerm_subnet.subnet02 ]
}

resource "azurerm_network_security_rule" "rule01" {
  name                        = "AllowRDPInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = local.rg_name
  network_security_group_name = azurerm_network_security_group.nsg01.name
}

resource "azurerm_subnet_network_security_group_association" "subnet01assoc" {
  subnet_id                 = azurerm_subnet.subnet01.id
  network_security_group_id = azurerm_network_security_group.nsg01.id
}

resource "azurerm_subnet_network_security_group_association" "subnet02assoc" {
  subnet_id                 = azurerm_subnet.subnet02.id
  network_security_group_id = azurerm_network_security_group.nsg01.id
}


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

resource "azurerm_resource_group" "rgname" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_virtual_network" "nextopsvnet04" {
  name                = "NextOpsVNET05"
  resource_group_name = azurerm_resource_group.rgname.name
  location            = azurerm_resource_group.rgname.location
  address_space       = ["10.5.0.0/16"]
}

resource "azurerm_subnet" "subnet01" {
  name                 = "Subnet01"
  resource_group_name  = azurerm_resource_group.rgname.name
  virtual_network_name = azurerm_virtual_network.nextopsvnet04.name
  address_prefixes     = ["10.5.1.0/24"]
}

resource "azurerm_subnet" "subnet02" {
  name                 = "Subnet02"
  resource_group_name  = azurerm_resource_group.rgname.name
  virtual_network_name = azurerm_virtual_network.nextopsvnet04.name
  address_prefixes     = ["10.5.0.0/24"]
}

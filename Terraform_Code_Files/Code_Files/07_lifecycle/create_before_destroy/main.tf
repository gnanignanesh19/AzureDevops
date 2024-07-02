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
  name     = "nextopsrg02"
  location = "West Europe"
}

resource "azurerm_virtual_network" "nextopsvnet04" {
  name                  = "NextOpsVNET07"
  resource_group_name   = azurerm_resource_group.rgname.name
  location              = azurerm_resource_group.rgname.location
  address_space         = ["10.6.0.0/16"]  

  lifecycle {
    create_before_destroy = true
  }
}





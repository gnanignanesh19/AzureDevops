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

data "azurerm_resource_group" "existing_rg" {
  name = var.rg_name
}

data "azurerm_virtual_network" "existing_vnet" {
  name                = "NextOpsVNETT15"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}

data "azurerm_subnet" "existing_sn1" {
  name                 = "Subnet01"
  virtual_network_name = data.azurerm_virtual_network.existing_vnet.name
  resource_group_name  = data.azurerm_resource_group.existing_rg.name
}

data "azurerm_subnet" "existing_sn2" {
  name                 = "Subnet02"
  virtual_network_name = data.azurerm_virtual_network.existing_vnet.name
  resource_group_name  = data.azurerm_resource_group.existing_rg.name
}

data "azurerm_network_security_group" "existing_nsg" {
  name                = "NextOpsNSGT15"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
} 

resource "azurerm_public_ip" "pip01" {
  name                = "nextopsvmt15-pip"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  location            = data.azurerm_resource_group.existing_rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic01" {
  name                = "nextopsvmt15-nic"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  location            = data.azurerm_resource_group.existing_rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.existing_sn1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip01.id
  }

  depends_on = [ azurerm_public_ip.pip01 ]
}

resource "azurerm_linux_virtual_machine" "linvm01" {
  name                = "NextOpsLVMT15"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  location            = data.azurerm_resource_group.existing_rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic01.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
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
  name                  = "NextOpsVNET04"
  resource_group_name   = azurerm_resource_group.rgname.name
  location              = azurerm_resource_group.rgname.location
  address_space         = ["10.4.0.0/16"]  
}

resource "azurerm_subnet" "subnet01" {
  name                 = "Subnet01"
  resource_group_name  = azurerm_resource_group.rgname.name
  virtual_network_name = azurerm_virtual_network.nextopsvnet04.name
  address_prefixes     = ["10.4.1.0/24"]
}

resource "azurerm_subnet" "subnet02" {
  name                 = "Subnet02"
  resource_group_name  = azurerm_resource_group.rgname.name
  virtual_network_name = azurerm_virtual_network.nextopsvnet04.name
  address_prefixes     = ["10.4.0.0/24"]
}

resource "azurerm_network_security_group" "nsg01" {
  name                = "nextopsnsgt04"
  resource_group_name = azurerm_resource_group.rgname.name
  location            = azurerm_resource_group.rgname.location
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
  resource_group_name         = azurerm_resource_group.rgname.name
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

resource "azurerm_public_ip" "pip01" {
  name                = "nextopsvmt04-pip"
  resource_group_name = azurerm_resource_group.rgname.name
  location            = azurerm_resource_group.rgname.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic01" {
  name                = "nextopsvmt04-nic"
  location            = azurerm_resource_group.rgname.location
  resource_group_name = azurerm_resource_group.rgname.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet01.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip01.id
  }

  depends_on = [ azurerm_public_ip.pip01 ]
}

resource "azurerm_windows_virtual_machine" "winvm01" {
  name                = "nextopsvmt04"
  location            = azurerm_resource_group.rgname.location
  resource_group_name = azurerm_resource_group.rgname.name
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic01.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  depends_on = [ 
    azurerm_network_interface.nic01,
    azurerm_network_security_group.nsg01,
    azurerm_public_ip.pip01
   ]
}
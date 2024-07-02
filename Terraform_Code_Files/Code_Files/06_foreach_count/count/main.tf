terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.81.0"
    }
  }
}

provider "azurerm" {
  features {} 
}

resource "azurerm_resource_group" "myrg" {
   name     = var.rg_name
   location = var.rg_location
}

resource "azurerm_virtual_network" "myvnet" {
   name                 = var.vnet_name
   resource_group_name  = azurerm_resource_group.myrg.name
   location             = azurerm_resource_group.myrg.location
   address_space        = var.address_space
}

resource "azurerm_subnet" "subnets" {
    count                   = length(var.subnet_name)
    name                    = var.subnet_name[count.index]
    resource_group_name     = azurerm_resource_group.myrg.name
    virtual_network_name    = azurerm_virtual_network.myvnet.name
    address_prefixes        = ["10.10.${count.index}.0/24"]
}

resource "azurerm_public_ip" "mypip" {
  count               = length(var.pip)
  name                = var.pip[count.index]
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "mynic" {
  count               = 3  
  name                = "my-nic-${count.index}"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  ip_configuration {
    name                          = "my-ip-config"
    subnet_id                     = azurerm_subnet.subnets[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mypip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "myvm" {
  count                 = 3
  name                  = "my-vm-${count.index}"
  location              = azurerm_resource_group.myrg.location
  resource_group_name   = azurerm_resource_group.myrg.name
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.mynic[count.index].id]

  admin_ssh_key {
    username   = "adminuser"
    # ssh-keygen -t rsa -f C:\Terraform\SSHKeys\id_rsa  <-- command to generate keys in windows
    public_key = file("C:/Terraform/SSHKeys/id_rsa.pub") 
  }

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
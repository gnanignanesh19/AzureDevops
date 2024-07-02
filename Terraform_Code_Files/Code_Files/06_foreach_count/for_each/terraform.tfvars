resourcedetails = {
  "westus" = {
    vm_name       = "west-vm"
    location      = "westus"
    size          = "Standard_B1s"
    rg_name       = "west-rg"
    subnet_name   = "Subnet01"
    vnet_name     = "west-vnet"
    address_space = ["10.10.0.0/16"]
    address_prefix= ["10.10.0.0/24"]
  }
  "eastus" = {
    vm_name       = "east-vm"
    location      = "eastus"
    size          = "Standard_B2s"
    rg_name       = "east-rg"
    subnet_name   = "Subnet01"
    vnet_name     = "east-vnet"
    address_space = ["10.20.0.0/16"]
    address_prefix= ["10.20.0.0/24"]
  }
}
variable "rg_name" {
    type = string
    description = "The name of the Resource Group" 
}

variable "rg_location" {
    type = string
    description = "The location of the Resource Group"
    default = "West Europe" 
}

variable "vnet_name" {
    type = string
    description = "The name of the Virtual Network" 
}

variable "subnet01_name" {
    type = string
    description = "The name of the Subnet01" 
}

variable "subnet02_name" {
    type = string
    description = "The name of the Subnet02" 
}

variable "vm_name" {
    type = string
    description = "The name of the VM" 
}

variable "vm_size" {
    type = string
    default = "Standard_B1s"
}

variable "vm_image" {
    type = list(string)
    default = ["2016-Datacenter","2019-Datacenter","Ubuntu-22.04"]
}
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
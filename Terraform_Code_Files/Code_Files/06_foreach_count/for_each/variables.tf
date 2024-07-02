variable "resourcedetails" {
  type = map(object({
    vm_name       = string
    location      = string
    size          = string
    rg_name       = string
    subnet_name   = string
    vnet_name     = string
    address_space = list(string)
    address_prefix= list(string)
}))
  description = "Values of a specific vm resource in a specific region and specific vnet"
}


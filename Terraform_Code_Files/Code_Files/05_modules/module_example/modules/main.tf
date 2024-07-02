resource "azurerm_resource_group" "rgname" {
    name = var.rg_name
    location = var.rg_location  
}

resource "azurerm_virtual_network" "aks_vnet" {
    name = var.vnet_name
    resource_group_name = azurerm_resource_group.rgname.name
    location = azurerm_resource_group.rgname.location
    address_space = var.addressspace
}

resource "azurerm_subnet" "aks_subnet" {
    name = var.subnet01_name
    address_prefixes = var.addressprefixes
    resource_group_name = azurerm_resource_group.rgname.name
    virtual_network_name = azurerm_virtual_network.aks_vnet.name  
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rgname.name
  location            = azurerm_resource_group.rgname.location
  sku                 = "Premium"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "akscluster" {
  name                = var.aks_name
  location            = azurerm_resource_group.rgname.location
  resource_group_name = azurerm_resource_group.rgname.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_B2s"
    type = "VirtualMachineScaleSets"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
    dns_service_ip = "10.0.0.10"
    service_cidr = "10.0.0.0/16"
    load_balancer_sku = "standard"
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [ azurerm_virtual_network.aks_vnet, azurerm_subnet.aks_subnet, azurerm_container_registry.acr ]
}

resource "azurerm_role_assignment" "aks2acr" {
  principal_id                     = azurerm_kubernetes_cluster.akscluster.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
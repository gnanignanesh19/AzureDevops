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
    name = var.rg_name
    location = var.rg_location  
}

resource "azurerm_virtual_network" "aks_vnet" {
    name = var.vnet_name
    resource_group_name = azurerm_resource_group.rgname.name
    location = azurerm_resource_group.rgname.location
    address_space = ["10.2.0.0/16"]  
}

resource "azurerm_subnet" "aks_subnet" {
    name = var.subnet01_name
    address_prefixes = ["10.2.0.0/22"]
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
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
    type       = "VirtualMachineScaleSets"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
    secret_rotation_interval = "1m"
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

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "aks_uat_kv" {
  name                        = "nextopa-akv"
  resource_group_name         = var.rg_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  location                    = var.rg_location

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_kubernetes_cluster.akscluster.kubelet_identity[0].object_id

    key_permissions = [
      "Get",
      "List"
    ]

    secret_permissions = [
      "Get",
      "List"
    ]

    certificate_permissions = [
      "Get",
      "List"
    ]
  }
  depends_on = [ azurerm_kubernetes_cluster.akscluster ]
}

resource "azurerm_role_assignment" "aks2acr" {
  principal_id                     = azurerm_kubernetes_cluster.akscluster.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
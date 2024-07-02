terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.80.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "NextOps"
    storage_account_name = "nextopssat15"
    container_name       = "terraform"
    key                  = "DEV/dev.terraform.tfstate"
    access_key = "I4eO1VW0J6VnQFdhcoakTBqbdbm3DhMv3HAA+tZr4R7OX2S0y15+OFFyMg3O2uDDp1n9pTkNeKM1+AStci39sQ=="
  }
}

provider "azurerm" {
  features {}
}

module "dev" {
   source = "../../modules"
   rg_location = "EastUS"
   rg_name = "AKSDEVRG"
   vnet_name = "AKSDEVVNET01"
   subnet01_name = "Subnet01"
   addressspace = ["10.10.0.0/16"]
   addressprefixes = ["10.10.0.0/22"]
   acr_name = "nextopsdevacr01"
   aks_name = "nextopsdevaks01"  
}
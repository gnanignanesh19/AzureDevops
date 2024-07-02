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
    key                  = "STG/stg.terraform.tfstate"
    access_key = "I4eO1VW0J6VnQFdhcoakTBqbdbm3DhMv3HAA+tZr4R7OX2S0y15+OFFyMg3O2uDDp1n9pTkNeKM1+AStci39sQ=="
  }
}

provider "azurerm" {
  features {}
}

module "stage" {
   source = "../../modules"
   rg_location = "EastUS"
   rg_name = "AKSSTGRG"
   vnet_name = "AKSSTGVNET01"
   subnet01_name = "Subnet01"
   addressspace = ["10.12.0.0/16"]
   addressprefixes = ["10.12.0.0/22"]
   acr_name = "nextopsstgacr01"
   aks_name = "nextopsstgaks01"  
}
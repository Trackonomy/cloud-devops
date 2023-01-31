terraform {
  required_providers {
    azurerm = {
        source  = "hashicorp/azurerm"
        version = "3.41.0"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
    features{}
    subscription_id = "var.${terraform.workspace}.subscription_id"
    tenant_id       = "var.${terraform.workspace}.tenant_id"
    client_id       = "var.${terraform.workspace}.client_id"
    client_secret   = "var.${terraform.workspace}.client_secret"
}


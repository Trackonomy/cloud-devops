terraform {
  required_providers {
    azurerm = {
        source  = "hashicorp/azurerm"
        version = "3.41.0"
    }
  }
  # can be added by passing specific .conf file while running
  backend "azurerm" {}
}

provider "azurerm" {
  features{}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

data "azurerm_resource_group" "rg" {
  name     = var.project_name
#  location = var.project_loc

#  tags = var.tags
}

resource "azurerm_shared_image_gallery" "imagegallery" {
  name = var.image_gallery_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location = data.azurerm_resource_group.rg.location
  description = "Where main node-dev image definition is stored"

  tags = var.tags
}

resource "azurerm_shared_image" "sharedimage" {
  name                = var.vmss_config.image_name
  gallery_name        = azurerm_shared_image_gallery.imagegallery.name
  resource_group_name = azurerm_shared_image_gallery.imagegallery.resource_group_name
  location            = data.azurerm_resource_group.rg.location
  os_type             = "Linux"

  identifier {
    publisher = "Trackonomy"
    offer     = "Node-Dev"
    sku       = "stable"
  }
}


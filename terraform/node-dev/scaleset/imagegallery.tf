resource "azurerm_shared_image_gallery" "imagegallery" {
  name                = var.image_gallery_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.project_loc
  description         = "Where main node-dev image definition is stored"

  tags = var.tags
}


data "azurerm_shared_image_version" "main-image" {
  name                = var.vmss_config.image_version
  image_name          = var.vmss_config.image_name
  gallery_name        = azurerm_shared_image_gallery.imagegallery.name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_shared_image" "sharedimage" {
  name                = var.vmss_config.image_name
  gallery_name        = azurerm_shared_image_gallery.imagegallery.name
  resource_group_name = azurerm_shared_image_gallery.imagegallery.resource_group_name
  location            = var.project_loc
  os_type             = "Linux"

  identifier {
    publisher = "Trackonomy"
    offer     = "Node-Dev"
    sku       = "stable"
  }
}
data "azurerm_shared_image_gallery" "imagegallery" {
  name                = var.image_gallery_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_shared_image_version" "main-image" {
  name                = var.vmss_config.image_version
  image_name          = var.vmss_config.image_name
  gallery_name        = data.azurerm_shared_image_gallery.imagegallery.name
  resource_group_name = data.azurerm_resource_group.rg.name
}
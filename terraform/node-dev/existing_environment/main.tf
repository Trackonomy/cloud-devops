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
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

data "azurerm_resource_group" "rg" {
  name = var.project_name
}
data "azurerm_shared_image_gallery" "imagegallery" {
  name = var.image_gallery_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_shared_image_version" "main-image" {
  name                = var.vmss_config.image_version
  image_name          = var.vmss_config.image_name
  gallery_name        = data.azurerm_shared_image_gallery.imagegallery.name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vn_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_lb" "main-lb" {
  name = var.lb_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_lb_backend_address_pool" "main-bpepool" {
  name = var.bepool_name
  loadbalancer_id = data.azurerm_lb.main-lb.id
}

# image galery should be module
resource "azurerm_linux_virtual_machine_scale_set" "scaleset" {
  name                            = var.scaleset_name
  location                        = data.azurerm_shared_image_version.main-image.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  sku                             = var.vmss_config.image_sku
  instances                       = var.vmss_config.instances
  admin_username                  = var.vmss_config.admin_username
  admin_password                  = var.vmss_config.admin_password
  custom_data                     = base64encode(file("${path.module}/startup.sh"))
  disable_password_authentication = false
  zones                           = var.availability_zones
  source_image_id                 = data.azurerm_shared_image_version.main-image.id

  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"
  }
  
  network_interface {
    name    = var.nic_name
    primary = true
    #network_security_group_id = azurerm_network_security_group.nsg.id
    ip_configuration {
      name                                   = var.ipconf_name
      primary                                = true
      subnet_id                              = data.azurerm_subnet.subnet.id
      load_balancer_backend_address_pool_ids = [data.azurerm_lb_backend_address_pool.main-bpepool.id]
    }
  }
  boot_diagnostics {

  }
}
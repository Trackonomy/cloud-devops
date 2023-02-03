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

resource "azurerm_resource_group" "rg" {
  name     = var.project_name
  location = var.project_loc

  tags = var.tags
}

resource "azurerm_network_security_rule" "openports-rules" {
  for_each                    = var.accepted_ports
  name                        = "Port_${each.key}"
  priority                    = each.value
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  destination_port_range      = each.key
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# firewall settings
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.project_name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  # CORS policy

  tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.1.4"]

  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.project_name}-sub01"
  address_prefixes     = ["10.0.2.0/24"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_public_ip" "main-pubip" {
  name                = "${var.project_name}-publicip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"

  tags = var.tags
}

resource "azurerm_lb" "lb" {
  name                = "${var.project_name}-loadbalancer"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "LoadBalancer-PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main-pubip.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "main-bpepool" {
  name = "LoadBalancer-BackendAddressPool"
  #resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_rule" "lb-rule" {
  loadbalancer_id                = azurerm_lb.lb.id
  for_each                       = var.accepted_ports
  name                           = "${var.project_name}-lbrule-${each.key}"
  protocol                       = "Tcp"
  frontend_port                  = each.key
  backend_port                   = each.key
  frontend_ip_configuration_name = "LoadBalancer-PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main-bpepool.id]
}

resource "azurerm_shared_image_gallery" "imagegallery" {
  name                = var.image_gallery_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  description         = "Where main node-dev image definition is stored"

  tags = var.tags
}


data "azurerm_shared_image_version" "main-image" {
  name                = var.vmss_config.image_version
  image_name          = var.vmss_config.image_name
  gallery_name        = azurerm_shared_image_gallery.imagegallery.name
  resource_group_name = azurerm_resource_group.rg.name
}

# image galery should be module
resource "azurerm_linux_virtual_machine_scale_set" "scaleset" {
  name                            = "${var.project_name}-scaleset"
  location                        = data.azurerm_shared_image_version.main-image.location
  resource_group_name             = azurerm_resource_group.rg.name
  sku                             = var.vmss_config.image_sku
  instances                       = var.vmss_config.instances
  admin_username                  = var.vmss_config.admin_username
  admin_password                  = var.vmss_config.admin_password
  disable_password_authentication = var.vmss_config.disable_password_authentication

  admin_ssh_key {
    username   = var.vmss_config.admin_username
    public_key = var.vmss_config.admin_ssh_key
  }

  source_image_id = data.azurerm_shared_image_version.main-image.id

  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "vm-network-internal"
    primary = true

    ip_configuration {
      name      = "ip-internal"
      primary   = true
      subnet_id = azurerm_subnet.subnet.id
    }
  }
}
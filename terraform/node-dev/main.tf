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
  name     = var.project_name
}

resource "azurerm_network_security_rule" "openports-rules-inbound" {
  for_each                    = var.accepted_ports
  name                        = "Port_${each.key}_inbound"
  priority                    = each.value
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  destination_port_range      = each.key
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "openports-rules-outbound" {
  for_each                    = var.accepted_ports
  name                        = "Port_${each.key}_outbound"
  priority                    = each.value
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  destination_port_range      = each.key
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
# firewall settings
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.project_name}-nsg"
  location            = var.project_loc
  resource_group_name = data.azurerm_resource_group.rg.name
  # CORS policy

  tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}-vnet"
  location            = var.project_loc
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.project_name}-sub01"
  address_prefixes     = ["10.0.2.0/24"]
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_subnet_network_security_group_association" "sub-nsg-assoc" {
  subnet_id = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "main-pubip" {
  name                = "${var.project_name}-publicip"
  location            = var.project_loc
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  domain_name_label   = var.dns_prefix
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "nat" {
  name                    = "NAT"
  location                = var.project_loc
  resource_group_name     = data.azurerm_resource_group.rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_public_ip" "nat-ip" {
  name                = "${var.project_name}-natgatewayip"
  location            = var.project_loc
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "ip-nat-assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.nat-ip.id
}

resource "azurerm_subnet_nat_gateway_association" "sub-nat-assoc" {
  nat_gateway_id = azurerm_nat_gateway.nat.id
  subnet_id = azurerm_subnet.subnet.id
}

resource "azurerm_lb" "lb" {
  name                = "${var.project_name}-loadbalancer"
  location            = var.project_loc
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Standard"

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
  backend_address_pool_ids       = [ azurerm_lb_backend_address_pool.main-bpepool.id ]
}

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

# image galery should be module
resource "azurerm_linux_virtual_machine_scale_set" "scaleset" {
  name                            = "${var.project_name}-scaleset"
  location                        = data.azurerm_shared_image_version.main-image.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  sku                             = var.vmss_config.image_sku
  instances                       = var.vmss_config.instances
  admin_username                  = var.vmss_config.admin_username
  admin_password                  = var.vmss_config.admin_password
  custom_data                     = base64encode(file("${path.module}/startup.sh"))
  disable_password_authentication = false

  #admin_ssh_key {
    #username   = var.vmss_config.admin_username
    #public_key = var.vmss_config.admin_ssh_key
  #}

  source_image_id = data.azurerm_shared_image_version.main-image.id

  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "${azurerm_virtual_network.vnet.name}-nic"
    primary = true
    #network_security_group_id = azurerm_network_security_group.nsg.id
    ip_configuration {
      name      = "${azurerm_virtual_network.vnet.name}-nic-defaultIpConfiguration"
      primary   = true
      subnet_id = azurerm_subnet.subnet.id
      load_balancer_backend_address_pool_ids = [ azurerm_lb_backend_address_pool.main-bpepool.id ]
    }
  }
  boot_diagnostics {
    
  }
  depends_on = [
    azurerm_lb_rule.lb-rule
  ]
}

#resource "azurerm_virtual_machine_scale_set_extension" "startup-script" {
#  name                         = azurerm_linux_virtual_machine_scale_set.scaleset.name
#  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.scaleset.id
#  publisher                    = "Microsoft.Azure.Extensions"
#  type                         = "CustomScript"
#  type_handler_version         = "2.0"
#  settings = jsonencode({
#    "script" = base64encode(file("${path.module}/startup.sh"))
#  })
#}
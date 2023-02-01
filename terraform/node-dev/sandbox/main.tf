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

resource "azurerm_resource_group" "main-rg" {
  name     = var.rg_name
  location = var.rg_loc
}

# firewall settings
resource "azurerm_network_security_group" "main-nsg" {
  name                = "trk-ppe-sbx-nsg"
  location            = azurerm_resource_group.main-rg.location
  resource_group_name = azurerm_resource_group.main-rg.name

  security_rule {
    name                       = "Port_inbppe"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    destination_port_ranges    = [ "8098","8191", "8491", "9091", "9111", "9000" ]

  }

  security_rule {
    name                       = "Port_9000"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    destination_port_range     = "9000"
  }

  security_rule {
    name                       = "Port_9003"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    destination_port_range     = "9003"
  }
}

resource "azurerm_virtual_network" "main-vnet" {
  name = "trk-ppe-sbx-vnet"
  location = azurerm_resource_group.main-rg.location
  resource_group_name = azurerm_resource_group.main-rg.name
  address_space = ["10.0.0.0/16"]
  dns_servers = ["10.0.1.4"]

  subnet {
    name = "trk-ppe-sbx-sub01"
    address_prefix = "10.0.1.0/24"
    security_group = azurerm_network_security_group.main-nsg.id
  }
}

resource "azurerm_public_ip" "main-pubip" {
  name = "trk-ppe-sbx-PublicIP"
  location = azurerm_resource_group.main-rg.location
  resource_group_name = azurerm_resource_group.main-rg.name
  allocation_method = "Static"
}

resource "azurerm_lb" "main-lb" {
  name = "trk-ppe-sbx-LoadBalancer"
  location = azurerm_resource_group.main-rg.location
  resource_group_name = azurerm_resource_group.main-rg.name

  frontend_ip_configuration {
    name = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main-pubip.id
  }
}

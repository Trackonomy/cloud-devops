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
  name                = var.nsg_name == "" ? "${var.project_name}-nsg" : var.nsg_name
  location            = var.project_loc
  resource_group_name = data.azurerm_resource_group.rg.name
  # CORS policy

  tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name == "" ? "${var.project_name}-vnet" : var.vnet_name
  location            = var.project_loc
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                 = var.sub_name == "" ? "${var.project_name}-sub01" : var.sub_name
  address_prefixes     = ["10.0.2.0/24"]
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_subnet_network_security_group_association" "sub-nsg-assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "main-pubip" {
  name                = var.pubip_name == "" ? "${var.project_name}-publicip" : var.pubip_name
  location            = var.project_loc
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  domain_name_label   = var.dns_prefix
  sku                 = "Standard"
  zones               = var.availability_zones
  tags                = var.tags
  lifecycle {
    ignore_changes = [
      tags,
      zones
    ]

  }
}
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
  name     = var.project_name
  location = var.project_loc

  tags = {
    environment = "Sandbox"
  }
}

resource "azurerm_network_security_rule" "openports-rules" {
  for_each = var.accepted_ports
  name                       = "Port_${each.key}"
  priority                   =  each.value
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  destination_port_range    = each.key
  resource_group_name = azurerm_resource_group.main-rg.name
  network_security_group_name = azurerm_network_security_group.main-nsg.name
}

# firewall settings
resource "azurerm_network_security_group" "main-nsg" {
  name                = "${var.project_name}-nsg"
  location            = azurerm_resource_group.main-rg.location
  resource_group_name = azurerm_resource_group.main-rg.name
  # CORS policy

  tags = {
    environment = "Sandbox"
  }
}

resource "azurerm_virtual_network" "main-vnet" {
  name                = "${var.project_name}-vnet"
  location            = azurerm_resource_group.main-rg.location
  resource_group_name = azurerm_resource_group.main-rg.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.1.4"]

  tags = {
    environment = "Sandbox"
  }
}

resource "azurerm_subnet" "main-subnet" {
  name                 = "${var.project_name}-sub01"
  address_prefixes     = ["10.0.2.0/24"]
  resource_group_name  = azurerm_resource_group.main-rg.name
  virtual_network_name = azurerm_virtual_network.main-vnet.name
}

resource "azurerm_public_ip" "main-pubip" {
  name                = "${var.project_name}-publicip"
  location            = azurerm_resource_group.main-rg.location
  resource_group_name = azurerm_resource_group.main-rg.name
  allocation_method   = "Static"

  tags = {
    environment = "Sandbox"
  }
}

resource "azurerm_lb" "main-lb" {
  name                = "${var.project_name}-loadbalancer"
  location            = azurerm_resource_group.main-rg.location
  resource_group_name = azurerm_resource_group.main-rg.name

  frontend_ip_configuration {
    name                 = "LoadBalancer-PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main-pubip.id
  }
}

resource "azurerm_lb_backend_address_pool" "main-bpepool" {
  name                = "LoadBalancer-BackendAddressPool"
  #resource_group_name = azurerm_resource_group.main-rg.name
  loadbalancer_id     = azurerm_lb.main-lb.id
}

resource "azurerm_lb_rule" "main-lb-rule" {
  loadbalancer_id                = azurerm_lb.main-lb.id
  for_each                       = var.accepted_ports
  name                           = "${var.project_name}-lbrule-${each.key}"
  protocol                       = "Tcp"
  frontend_port                  = each.key
  backend_port                   = each.key
  frontend_ip_configuration_name = "LoadBalancer-PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main-bpepool.id]
}

resource "azurerm_virtual_machine_scale_set" "main-scaleset" {
  name                = "${var.project_name}-scaleset"
  location            = azurerm_resource_group.main-rg.location
  resource_group_name = azurerm_resource_group.main-rg.name
  upgrade_policy_mode = "Manual"

  os_profile {
    computer_name_prefix = "vm"
    admin_username       = "azureadm"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azureadm/.ssh/authorized_keys"
      key_data = file("id_rsa.pub")
    }
  }
  network_profile {
    name    = "${var.project_name}-NetworkProfile"
    primary = true

    ip_configuration {
      name      = "${var.project_name}-ipconfiguration"
      primary   = true
      subnet_id = azurerm_subnet.main-subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.main-bpepool.id]
    }
  }

  storage_profile_os_disk {
    name = ""
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun = 0
    caching = "ReadWrite"
    create_option = "Empty"
    disk_size_gb = 10
  }
  
  storage_profile_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04-LTS"
    version = "latest"
  }

  sku {
    name = "Standard_F2"
    tier = "Standard"
    capacity = 1
  }
}
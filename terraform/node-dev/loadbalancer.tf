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

resource "azurerm_lb_probe" "healthprobes" {
  for_each        = var.accepted_ports
  loadbalancer_id = azurerm_lb.lb.id
  name            = "${each.key}_probe"
  port            = each.key
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
  probe_id                       = [for healthprobe in azurerm_lb_probe.healthprobes : healthprobe.id if healthprobe.name == "${each.key}_probe"][0]
}
output "dns_name" {
  value = azurerm_public_ip.main-pubip.fqdn
}

output "public_ip_address" {
  value = azurerm_public_ip.main-pubip.ip_address
}

output "scaleset_image_id" {
  value = azurerm_linux_virtual_machine_scale_set.scaleset.source_image_id
}
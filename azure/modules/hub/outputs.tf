output "rg_location" {
  value = azurerm_resource_group.hub.location
}

output "rg_name" {
  value = azurerm_resource_group.hub.name
}

output "network_name" {
  value = azurerm_virtual_network.hub.name
}

output "hub_gateway_ip" {
  value = azurerm_public_ip.vpn_public_ip.ip_address
}

output "bastion_endpoint" {
  value = azurerm_public_ip.bastion.ip_address
}

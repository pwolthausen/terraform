output "network_id" {
  value = azurerm_virtual_network.spoke.id
}

output "network_name" {
  value = azurerm_virtual_network.spoke.name
}

output "subnet_id" {
  value = { for x in azurerm_subnet.spoke : x.name => x.id }
}

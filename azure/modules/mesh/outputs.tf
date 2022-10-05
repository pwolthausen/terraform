output "hub_tunnel_ips1" {
  value = tolist(azurerm_vpn_gateway.vwan.bgp_settings[0].instance_0_bgp_peering_address[0].tunnel_ips)[1]
}

output "hub_tunnel_ips2" {
  value = tolist(azurerm_vpn_gateway.vwan.bgp_settings[0].instance_1_bgp_peering_address[0].tunnel_ips)[1]
}

output "hub_asn" {
  value = azurerm_virtual_hub.vwan.virtual_router_asn
}

output "firewall_ip" {
  value = azurerm_firewall.firewall.virtual_hub[0].private_ip_address
}

# output "vhub_route_table_id" {
#   value = azurerm_virtual_hub_route_table.vwan.id
# }

output "test" {
  value = local.site_links
}

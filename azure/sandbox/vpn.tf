###########################
##### VPN
###########################

resource "azurerm_subnet" "hub_vpn" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["192.168.100.0/27"]
}

resource "azurerm_public_ip" "vpn_public_ip" {
  name                = "ip-hub-vpn-gateway-cac"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  sku               = "Standard"
  allocation_method = "Static"

  zones = ["1", "2", "3"]
}

output "hub_gateway_ip" {
  value = azurerm_public_ip.vpn_public_ip.ip_address
}

##local_network_gateway references the information of the on-prem network
resource "azurerm_local_network_gateway" "hub_local_gateway" {
  name                = "lng-hub-gcp"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  gateway_address     = var.vpn_peer_address

  bgp_settings {
    asn                 = var.vpn_peer_bgp_asn
    bgp_peering_address = var.vpn_peer_bgp_ip
  }

  address_space = ["192.168.64.0/19", "10.64.0.0/11"]
}

resource "azurerm_virtual_network_gateway" "hub" {
  name                = "gw-hub-vpn-cac"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  type = "Vpn"
  sku  = "VpnGw1AZ"

  enable_bgp = true
  bgp_settings {
    asn = 64513
    peering_addresses {
      apipa_addresses = ["169.254.21.1"]
    }
  }

  ip_configuration {
    subnet_id            = azurerm_subnet.hub_vpn.id
    public_ip_address_id = azurerm_public_ip.vpn_public_ip.id
  }

  # custom_route {
  #   address_prefixes = ["192.168.64.0/19", "10.64.0.0/11"]
  # }
}

resource "azurerm_virtual_network_gateway_connection" "hub_gcp_connection" {
  name                = "tn-hub-gcp"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.hub.id
  local_network_gateway_id   = azurerm_local_network_gateway.hub_local_gateway.id

  shared_key      = "P@ssw0rd"
  enable_bgp      = true
  connection_mode = "ResponderOnly"
}

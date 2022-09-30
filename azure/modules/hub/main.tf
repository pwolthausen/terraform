resource "azurerm_resource_group" "hub" {
  name     = "${var.prefix}-hub-${var.region_code}"
  location = var.location
  tags = merge(var.global_tags, {
    env    = "shared"
    role   = "hub-${var.region_code}"
    region = var.location
  })
}

resource "azurerm_virtual_network" "hub" {
  name                = "vpc-${var.prefix}-hub-${var.region_code}"
  address_space       = var.address_space
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  tags = merge(var.global_tags, {
    env    = "shared"
    role   = "hub-${var.region_code}"
    region = var.location
  })
}

###########################
##### VPN
###########################

resource "azurerm_subnet" "hub_vpn" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [cidrsubnet(var.address_space[0], 3, 0)]
}

resource "azurerm_public_ip" "vpn_public_ip" {
  name                = "ip-hub-vpn-gateway-${var.region_code}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  sku               = "Standard"
  allocation_method = "Static"

  zones = ["1", "2", "3"]
}

##local_network_gateway references the information of the on-prem network
resource "azurerm_local_network_gateway" "hub_local_gateway" {
  name                = "lng-hub-${var.vpn_peer_name}-${var.region_code}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  gateway_address     = var.vpn_peer_address

  bgp_settings {
    asn                 = var.vpn_peer_bgp_asn
    bgp_peering_address = var.vpn_peer_bgp_ip
  }
}

resource "azurerm_virtual_network_gateway" "hub" {
  name                = "gw-hub-vpn-${var.region_code}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  type = "Vpn"
  sku  = "VpnGw1AZ"

  enable_bgp = true
  bgp_settings {
    asn = var.vpn_az_bgp_asn #64513
    peering_addresses {
      apipa_addresses = var.vpn_az_bgp_ip #["169.254.21.1"]
    }
  }

  ip_configuration {
    subnet_id            = azurerm_subnet.hub_vpn.id
    public_ip_address_id = azurerm_public_ip.vpn_public_ip.id
  }

  tags = merge(var.global_tags, {
    env    = "shared"
    role   = "hub-${var.region_code}"
    region = var.location
  })
}

resource "azurerm_virtual_network_gateway_connection" "hub_gcp_connection" {
  name                = "tn-hub-${var.vpn_peer_name}-${var.region_code}"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.hub.id
  local_network_gateway_id   = azurerm_local_network_gateway.hub_local_gateway.id

  shared_key      = var.shared_key #"P@ssw0rd"
  enable_bgp      = true
  connection_mode = "ResponderOnly"
}

##########################
#### Bastion
##########################

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [cidrsubnet(var.address_space[0], 3, 1)]
}

resource "azurerm_public_ip" "bastion" {
  name                = "${var.prefix}-${var.region_code}-bastion-ip"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(var.global_tags, {
    env  = "shared"
    role = "bastion"
  })
}

resource "azurerm_bastion_host" "bastion" {
  name                = "${var.prefix}-${var.region_code}-bastion"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "Standard"

  file_copy_enabled = true
  tunneling_enabled = true

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = merge(var.global_tags, {
    env  = "shared"
    role = "bastion"
  })
}

# ##########################
# #### Firewall
# ##########################
#
# resource "azurerm_virtual_network" "firewall" {
#   name                = "vpc-${var.prefix}-fw-${var.region_code}"
#   address_space       = [cidrsubnet(var.address_space, 1, 1)]
#   location            = azurerm_resource_group.hub.location
#   resource_group_name = azurerm_resource_group.hub.name
#
#   tags = merge(var.global_tags, {
#     env    = "shared"
#     role   = "firewall-${var.region_code}"
#     region = var.location
#   })
# }
#
# resource "azurerm_virtual_hub_connection" "firewall" {
#   name                      = "hc-fw-${var.region_code}"
#   virtual_hub_id            = azurerm_virtual_hub.hub.id
#   remote_virtual_network_id = azurerm_virtual_network.firewall.id
# }
#
# resource "azurerm_subnet" "firewall" {
#   name                 = "AzureFirewallSubnet"
#   resource_group_name  = azurerm_resource_group.hub.name
#   virtual_network_name = azurerm_virtual_network.firewall.name
#   address_prefixes     = [cidrsubnet(var.address_space, 3, 4)]
# }
#
# resource "azurerm_subnet" "firewall_management" {
#   name                 = "AzureFirewallManagementSubnet"
#   resource_group_name  = azurerm_resource_group.hub.name
#   virtual_network_name = azurerm_virtual_network.firewall.name
#   address_prefixes     = [cidrsubnet(var.address_space, 3, 5)]
# }
#
# resource "azurerm_public_ip" "firewall" {
#   name                = "ip-${var.prefix}-${var.region_code}-firewall"
#   location            = azurerm_resource_group.hub.location
#   resource_group_name = azurerm_resource_group.hub.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
#
#   tags = merge(var.global_tags, {
#     env  = "shared"
#     role = "firewall"
#   })
# }
#
# resource "azurerm_public_ip" "firewall_management" {
#   name                = "ip-${var.prefix}-${var.region_code}-firewall-mgmnt"
#   location            = azurerm_resource_group.hub.location
#   resource_group_name = azurerm_resource_group.hub.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
#
#   tags = merge(var.global_tags, {
#     env  = "shared"
#     role = "firewall"
#   })
# }
#
# resource "azurerm_firewall" "firewall" {
#   name                = "fw-${var.prefix}-${var.region_code}"
#   location            = azurerm_resource_group.hub.location
#   resource_group_name = azurerm_resource_group.hub.name
#   sku_name            = "AZFW_VNet"
#   sku_tier            = "Standard"
#
#   ip_configuration {
#     name                 = "firewall"
#     subnet_id            = azurerm_subnet.firewall.id
#     public_ip_address_id = azurerm_public_ip.firewall.id
#   }
#   management_ip_configuration {
#     name                 = "firewallManagement"
#     subnet_id            = azurerm_subnet.firewall_management.id
#     public_ip_address_id = azurerm_public_ip.firewall_management.id
#   }
# }

resource "azurerm_resource_group" "spoke" {
  name     = "${var.prefix}-${var.env}-${var.region_code}-network"
  location = var.location
  tags = merge(var.global_tags, {
    env  = var.env
    role = "${var.app}"
  })
}

resource "azurerm_virtual_network" "spoke" {
  name                = "vpc-${var.prefix}-${var.region_code}"
  address_space       = var.address_space
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name

  tags = merge(var.global_tags, {
    env  = var.env
    role = "${var.app}-spoke"
  })
}

resource "azurerm_subnet" "spoke" {
  for_each             = var.subnets
  name                 = "sb-${var.prefix}-${var.region_code}-${var.app}-${each.key}"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = each.value
}

data "azurerm_resource_group" "hub" {
  name = "${var.prefix}-hub-${var.region_code}"
}

data "azurerm_virtual_network" "hub" {
  name                = "vpc-${var.prefix}-hub-${var.region_code}"
  resource_group_name = data.azurerm_resource_group.hub.name
}

resource "azurerm_virtual_network_peering" "spoke_hub_peer" {
  name                      = "${var.prefix}-${var.region_code}-spoke-hub"
  resource_group_name       = azurerm_resource_group.spoke.name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
  use_remote_gateways       = true
}

resource "azurerm_virtual_network_peering" "hub_spoke_peer" {
  name                      = "${var.prefix}-${var.region_code}-hub-spoke"
  resource_group_name       = data.azurerm_resource_group.hub.name
  virtual_network_name      = data.azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
}

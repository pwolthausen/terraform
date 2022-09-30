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

data "azurerm_virtual_hub" "hub" {
  name                = "hub-pw-${var.region_code}"
  resource_group_name = "pw-vwan-${var.region_code}"
}

resource "azurerm_virtual_hub_connection" "spoke" {
  name                      = "hc-${var.prefix}-${var.region_code}"
  virtual_hub_id            = data.azurerm_virtual_hub.hub.id
  remote_virtual_network_id = azurerm_virtual_network.spoke.id

  routing {
    associated_route_table_id = var.vhub_route_table_id
    propagated_route_table {
      route_table_ids = [var.vhub_route_table_id]
    }
  }

  lifecycle {
    replace_triggered_by = [azurerm_virtual_network.spoke.address_space]
  }
}

data "azurerm_virtual_hub" "hub" {
  name                = "hub-${var.hub_bu}-${var.hub_env}-${var.region_code}"
  resource_group_name = "rg-${var.hub_bu}-${var.hub_env}-${var.region_code}"
}

resource "azurerm_resource_group" "spoke" {
  name     = "rg-${var.business_unit}-${var.app}-${var.env}-${var.region_code}"
  location = var.location
  tags = merge(var.global_tags, {
    env  = var.env
    role = "${var.app}"
  })
}

resource "azurerm_virtual_network" "spoke" {
  name                = "vpc-${var.business_unit}-${var.app}-${var.env}-${var.region_code}"
  address_space       = var.address_space
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name

  tags = merge(var.global_tags, {
    env  = var.env
    role = "${var.app}-spoke"
  })
}

locals {
  subnets = var.subnets == {} ? { public = [cidrsubnet(var.address_space[0], 1, 0)], private = [cidrsubnet(var.address_space[0], 1, 1)], akspods = [var.address_space[1]] } : var.subnets
}

resource "azurerm_subnet" "spokes" {
  for_each             = local.subnets
  name                 = "sb-${var.business_unit}-${var.app}-${var.region_code}-${each.key}"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = each.value
}

resource "azurerm_virtual_hub_connection" "spoke" {
  name                      = "hc-${var.business_unit}-${var.app}-${var.region_code}"
  virtual_hub_id            = data.azurerm_virtual_hub.hub.id
  remote_virtual_network_id = azurerm_virtual_network.spoke.id

  routing {
    associated_route_table_id = data.azurerm_virtual_hub.hub.default_route_table_id
    propagated_route_table {
      route_table_ids = [data.azurerm_virtual_hub.hub.default_route_table_id]
    }
  }

  lifecycle {
    replace_triggered_by = [azurerm_virtual_network.spoke.address_space]
  }
}

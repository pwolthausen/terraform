resource "azurerm_resource_group" "vwan" {
  name     = "${var.prefix}-vwan-${var.region_code}"
  location = var.location
  tags = merge(var.global_tags, {
    env    = "shared"
    role   = "vwan-${var.region_code}"
    region = var.location
  })
}

##########################
#### Virtual Wan
##########################

resource "azurerm_virtual_wan" "vwan" {
  name                           = "vwan-${var.prefix}-${var.region_code}"
  resource_group_name            = azurerm_resource_group.vwan.name
  location                       = azurerm_resource_group.vwan.location
  allow_branch_to_branch_traffic = false

  tags = merge(var.global_tags, {
    env    = "shared"
    role   = "vwan-${var.region_code}"
    region = var.location
  })
}

resource "azurerm_virtual_hub" "vwan" {
  name                = "hub-${var.prefix}-${var.region_code}"
  resource_group_name = azurerm_resource_group.vwan.name
  location            = azurerm_resource_group.vwan.location
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_prefix      = cidrsubnet(var.address_space, 1, 0)

  sku = "Standard"
  tags = merge(var.global_tags, {
    env    = "shared"
    role   = "vwan-${var.region_code}"
    region = var.location
  })
}

resource "azurerm_virtual_hub_route_table" "vwan" {
  name           = "rtt-hub-${var.region_code}"
  virtual_hub_id = azurerm_virtual_hub.vwan.id

  route {
    name              = "all_traffic"
    destinations_type = "CIDR"
    destinations      = ["0.0.0.0/0", "10.0.0.0/8", "192.168.0.0/16"]
    next_hop_type     = "ResourceId"
    next_hop          = azurerm_firewall.firewall.id
  }
}

resource "azurerm_firewall" "firewall" {
  name                = "fw-${var.prefix}-${var.region_code}"
  location            = azurerm_resource_group.vwan.location
  resource_group_name = azurerm_resource_group.vwan.name

  sku_name           = "AZFW_Hub"
  sku_tier           = "Standard"
  firewall_policy_id = azurerm_firewall_policy.vwan.id

  virtual_hub {
    virtual_hub_id = azurerm_virtual_hub.vwan.id
  }
}

##########################
#### S2S VPN
##########################

resource "azurerm_vpn_gateway" "vwan" {
  name                = "vpn-${var.prefix}-${var.region_code}"
  location            = azurerm_resource_group.vwan.location
  resource_group_name = azurerm_resource_group.vwan.name
  virtual_hub_id      = azurerm_virtual_hub.vwan.id

  bgp_settings {
    asn         = 65515
    peer_weight = 0
    instance_0_bgp_peering_address {
      custom_ips = ["169.254.21.1"]
    }
    instance_1_bgp_peering_address {
      custom_ips = ["169.254.21.5"]
    }
  }
}

resource "azurerm_vpn_site" "vwan" {
  name                = "site-${var.prefix}-${var.region_code}-${var.vpn_peer_name}"
  location            = azurerm_resource_group.vwan.location
  resource_group_name = azurerm_resource_group.vwan.name
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  dynamic "link" {
    for_each = var.vpn_links
    content {
      name       = link.key
      ip_address = link.value.peer_ip
      dynamic "bgp" {
        for_each = lookup(link.value, "bgp")
        content {
          asn             = bgp.value.asn
          peering_address = bgp.value.bgp_peer_ip
        }
      }
    }
  }
}

resource "azurerm_vpn_gateway_connection" "vwan" {
  name               = "tn-${var.prefix}-${var.region_code}-${var.vpn_peer_name}"
  vpn_gateway_id     = azurerm_vpn_gateway.vwan.id
  remote_vpn_site_id = azurerm_vpn_site.vwan.id

  routing {
    associated_route_table = azurerm_virtual_hub_route_table.vwan.id
    propagated_route_table {
      route_table_ids = [azurerm_virtual_hub_route_table.vwan.id]
    }
  }

  vpn_link {
    name             = "link1"
    vpn_site_link_id = azurerm_vpn_site.vwan.link[0].id
    bgp_enabled      = true
    shared_key       = var.shared_key
  }

  vpn_link {
    name             = "link2"
    vpn_site_link_id = azurerm_vpn_site.vwan.link[1].id
    bgp_enabled      = true
    shared_key       = var.shared_key
  }
}

##########################
#### Firewall Policies
##########################

resource "azurerm_firewall_policy" "vwan" {
  name                = "fwp-hub-${var.prefix}-${var.region_code}"
  resource_group_name = azurerm_resource_group.vwan.name
  location            = azurerm_resource_group.vwan.location
}

resource "azurerm_firewall_policy_rule_collection_group" "vwan" {
  name               = "pw-firewall-policies"
  firewall_policy_id = azurerm_firewall_policy.vwan.id
  priority           = 500

  dynamic "application_rule_collection" {
    for_each = var.application_rule_collection
    iterator = app_rule
    content {
      name     = app_rule.key
      priority = app_rule.value.priority
      action   = app_rule.value.action
      dynamic "rule" {
        for_each = app_rule.value.rules
        content {
          name                  = rule.key
          source_addresses      = lookup(rule.value, "source_addresses", [])
          source_ip_groups      = lookup(rule.value, "source_ip_groups", [])
          destination_urls      = lookup(rule.value, "destination_urls", [])
          destination_fqdns     = lookup(rule.value, "destination_fqdns", [])
          destination_fqdn_tags = lookup(rule.value, "destination_fqdn_tags", [])
          terminate_tls         = lookup(rule.value, "terminate_tls", false)
          web_categories        = lookup(rule.value, "web_categories", [])
          dynamic "protocols" {
            for_each = rule.value.protocols
            content {
              type = protocols.key
              port = protocols.value
            }
          }
        }
      }
    }
  }

  dynamic "network_rule_collection" {
    for_each = var.network_rule_collection
    iterator = net_rule
    content {
      name     = net_rule.key
      priority = net_rule.value.priority
      action   = net_rule.value.action
      dynamic "rule" {
        for_each = net_rule.value.rules
        content {
          name                  = rule.key
          protocols             = rule.value.protocols
          source_addresses      = lookup(rule.value, "source_addresses", [])
          source_ip_groups      = lookup(rule.value, "source_ip_groups", [])
          destination_addresses = lookup(rule.value, "destination_addresses", [])
          destination_ip_groups = lookup(rule.value, "destination_ip_groups", [])
          destination_fqdns     = lookup(rule.value, "destination_fqdns", [])
          destination_ports     = lookup(rule.value, "destination_ports", [])
        }
      }
    }
  }

  dynamic "nat_rule_collection" {
    for_each = var.nat_rule_collection
    iterator = nat_rule
    content {
      name     = nat_rule.key
      priority = nat_rule.value.priority
      action   = nat_rule.value.action
      dynamic "rule" {
        for_each = nat_rule.value.rules
        content {
          name                = rule.key
          protocols           = rule.value.protocols
          source_addresses    = lookup(rule.value, "source_addresses", [])
          source_ip_groups    = lookup(rule.value, "source_ip_groups", [])
          destination_address = lookup(rule.value, "destination_address", [])
          destination_ports   = lookup(rule.value, "destination_ports", [])
          translated_address  = lookup(rule.value, "translated_address", null)
          translated_fqdn     = lookup(rule.value, "translated_fqdn", null)
          translated_port     = rule.value.translated_port
        }
      }
    }
  }
}

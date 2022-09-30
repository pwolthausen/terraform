module "hub_network" {
  source  = "terraform-google-modules/network/google"
  version = "5.2.0"

  project_id                             = var.project_id
  network_name                           = "vpc-pw-hub"
  shared_vpc_host                        = "false"
  delete_default_internet_gateway_routes = "false"

  subnets = [
    {
      subnet_name           = "vpc-pw-hub"
      subnet_ip             = "192.168.7.0/27"
      subnet_region         = "northamerica-northeast1"
      subnet_private_access = false
    },
  ]
}

module "net_hub_core_vpc_peering" {
  source  = "terraform-google-modules/network/google//modules/network-peering"
  version = "5.2.0"

  prefix                     = "pn-core-hub"
  local_network              = module.core_network.network_self_link
  peer_network               = module.hub_network.network_self_link
  export_peer_custom_routes  = true
  export_local_custom_routes = true
  depends_on = [
    module.core_network,
    module.hub_network
  ]
}

module "net_hub_alternate_vpc_peering" {
  source  = "terraform-google-modules/network/google//modules/network-peering"
  version = "5.2.0"

  prefix                     = "pn-alternate-hub"
  local_network              = module.alternate_network.network_self_link
  peer_network               = module.hub_network.network_self_link
  export_peer_custom_routes  = true
  export_local_custom_routes = true
  depends_on = [
    module.alternate_network,
    module.hub_network
  ]
}

module "vpn_ha" {
  source  = "terraform-google-modules/vpn/google//modules/vpn_ha"
  version = "2.3.0"

  project_id = var.project_id
  region     = var.region
  network    = module.hub_network.network_name
  name       = "vpn-azure-test"

  router_advertise_config = {
    groups    = []
    ip_ranges = { "192.168.0.0/18" = "primary", "10.0.0.0/10" = "secondary" }
    mode      = "CUSTOM"
  }

  peer_external_gateway = {
    redundancy_type = length(var.peer_ips) == 1 ? "SINGLE_IP_INTERNALLY_REDUNDANT" : "TWO_IPS_REDUNDANCY"
    interfaces = [
      {
        id         = 0
        ip_address = var.peer_ips[0]
      },
      {
        id         = 1
        ip_address = var.peer_ips[1]
      }
    ]
  }
  router_asn = 64514
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = "169.254.21.1"
        asn     = 65515
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.21.2/30"
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = var.vpn_secret
    }
    remote-1 = {
      bgp_peer = {
        address = "169.254.21.5"
        asn     = 65515
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.21.6/30"
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 1
      shared_secret                   = var.vpn_secret
    }
  }
}

output "vpn_endpoints" {
  value = [for x in module.vpn_ha.gateway[0].vpn_interfaces : x.ip_address]
  # value = module.vpn_ha.gateway_ip
}

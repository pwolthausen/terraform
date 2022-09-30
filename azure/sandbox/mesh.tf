###################################################
##### vwan network
###################################################

module "vwan" {
  source = "../modules/vwan"

  prefix        = var.prefix
  location      = var.location
  region_code   = "cac"
  address_space = "192.168.100.0/23"
  vpn_peer_name = "gcp"
  shared_key    = var.shared_key

  vpn_links = {
    link1 = {
      peer_ip = var.bgp_peer_ip[0]
      bgp = {
        bgp = {
          asn         = "64514"
          bgp_peer_ip = "169.254.21.2"
        }
      }
    },
    link2 = {
      peer_ip = var.bgp_peer_ip[1]
      bgp = {
        bgp = {
          asn         = "64514"
          bgp_peer_ip = "169.254.21.6"
        }
      }
    }
  }

  application_rule_collection = var.application_rule_collection
  network_rule_collection     = var.network_rule_collection

  global_tags = var.global_tags
}

output "hub_tunnel_ips1" {
  value = module.vwan.hub_tunnel_ips1
}

output "hub_tunnel_ips2" {
  value = module.vwan.hub_tunnel_ips2
}

output "hub_asn" {
  value = module.vwan.hub_asn
}

output "firewall_ip" {
  value = module.vwan.firewall_ip
}

output "route_table_id" {
  value = module.vwan.vhub_route_table_id
}

##################################################
#### core network
##################################################

module "app1_network" {
  source = "../modules/vnet"

  prefix      = var.prefix
  location    = var.location
  region_code = "cac"
  env         = "test"
  app         = "test-app"

  address_space       = ["192.168.102.0/24"]
  subnets             = { webapp = ["192.168.102.0/24"] }
  firewall_ip         = module.vwan.firewall_ip
  vhub_route_table_id = module.vwan.vhub_route_table_id

  global_tags = var.global_tags
}

output "app1_subnets" {
  value = module.app1_network.subnet_id
}

##################################################
#### dr network
##################################################

module "dr_network" {
  source = "../modules/vnet"

  prefix      = "pw-dr"
  location    = var.location
  region_code = "cac"
  env         = "test"
  app         = "test-dr"

  address_space       = ["192.168.103.0/24"]
  subnets             = { dr = ["192.168.103.0/24"] }
  firewall_ip         = module.vwan.firewall_ip
  vhub_route_table_id = module.vwan.vhub_route_table_id

  global_tags = var.global_tags
}

output "dr_subnets" {
  value = module.dr_network.subnet_id
}

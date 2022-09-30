# ###################################################
# ##### hub network
# ###################################################
#
# module "hub" {
#   source = "../modules/hub"
#
#   prefix         = var.prefix
#   location       = var.location
#   region_code    = "cac"
#   address_space  = ["192.168.100.0/24"]
#   address_prefix = ["192.168.100.0/27"]
#
#   vpn_peer_name    = "gcp"
#   vpn_peer_address = var.vpn_peer_address
#   vpn_peer_bgp_ip  = var.vpn_peer_bgp_ip
#   vpn_peer_bgp_asn = var.vpn_peer_bgp_asn
#   shared_key       = var.shared_key
#
#   global_tags = var.global_tags
# }
#
# output "vpn_gateway_ip" {
#   value = module.hub.hub_gateway_ip
# }

###################################################
##### core network
###################################################

# module "app1_network" {
#   source = "../modules/spoke"
#
#   prefix      = var.prefix
#   location    = var.location
#   region_code = "cac"
#   env         = "test"
#   app         = "test-app"
#
#   address_space = ["192.168.101.0/24"]
#   subnets       = { webapp = ["192.168.101.0/24"] }
#
#   global_tags = var.global_tags
# }
#
# output "subnets" {
#   value = module.app1_network.subnet_id
# }

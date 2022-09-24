variable "project_id" {}

variable "my_ip" {
  type    = string
  default = ""
}

variable "region" {
  type = string
}

variable "peer_ips" {
  type    = list(string)
  default = []
}

variable "vpn_secret" {
  type    = string
  default = ""
}

# variable "masterCIDR" {
#   type    = string
#   default = "10.46.0.0/24"
# }
# variable "masternewbits" {
#   type    = number
#   default = 4
# }

# variable "net_hub_subnets" {
#   description = "List of subnets to create in the network hub VPC. There should only be 1 subnet per required region for the interconnects or VPNs"
#   type        = list(map({ subnet_name = string, subnet_ip = string, subnet_region = string, subnet_private_access = string, subnet_flow_logs = string, description = string }))
#   default     = []
# }
#
# variable "net_hub_routes" {
#   description = "List of custom routes to create in the network hub VPC. GCP will still create standard routing in the VPC. See https://github.com/terraform-google-modules/terraform-google-network#route-inputs for syntax"
#   type        = list(map(any))
#   default     = []
# }

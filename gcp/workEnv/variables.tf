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

variable "master_ipv4_cidr_block" {
  type    = string
  default = "10.46.0.0/28"
}

variable "master_authorized_networks" {
  type        = map(any)
  description = "Defines IP addresses allowed to communicate with the GKE master endpoint"
  default     = {}
}

variable "subnets" {
  type = map(object({
    ip     = string
    region = string
  }))
}

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

variable "prj_iam_bindings" {
  description = "Defines the various IAM bindings for the project"
  type = map(object({
    roles = list(string)
  }))
  default = {}
}

variable "custom_roles" {
  description = "Defines custom roles for the project"
  type = map(object({
    permissions = list(string)
    description = string
  }))
  default = {}
}

variable "workload_identities" {
  description = "Defines service accounts to use for workload identity in GKE"
  type = map(object({
    sa_description = string
    sa_role        = string
    sa_namespace   = string
  }))
  default = {}
}

variable "service_accounts" {
  description = "Defines custom project wide service accounts"
  type = map(object({
    roles       = list(string)
    description = string
  }))
  default = {}
}

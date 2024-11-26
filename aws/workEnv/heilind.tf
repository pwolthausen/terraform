
# data "aws_availability_zones" "current" {
#   state = "available"
# }

# module "frankfurt" {
#   source = "git::git@sgit.cloudops.com:consulting/clients/heilind/regional-deployment.git?ref=fix-deployement"

#   env                 = var.env
#   app_name            = var.app_name
#   region_code         = var.region_code
#   cidr                = var.cidr
#   availability_zones  = var.availability_zones
#   tags                = var.tags

#   web_machine_type    = var.web_machine_type
#   web_root_disk_size  = var.web_root_disk_size
#   mem_machine_type    = var.mem_machine_type
#   mem_root_disk_size  = var.mem_root_disk_size
#   dev_machine_type    = var.dev_machine_type
#   dev_root_disk_size  = var.dev_root_disk_size
#   termination_protection_enabled = var.termination_protection_enabled

#   on_prem_cidr        = var.on_prem_cidr
#   vpn_aws_secret_name = var.vpn_aws_secret_name
#   client_vpn_ip_0     = var.client_vpn_ip_0
#   client_vpn_ip_1     = var.client_vpn_ip_1
#   on_prem_cidr_0      = var.on_prem_cidr_0
#   on_prem_cidr_1      = var.on_prem_cidr_1
# }


# variable "env" {
#   description = "Environment (e.g., prod, dev, test)"
#   type        = string
#   default = "dev"
# }

# variable "app_name" {
#   type        = string
#   description = "3 or 4 letter short code for the environment, normally linked to the workloads being deployed"
#   default = "heil"
# }

# variable "region_code" {
#   type        = string
#   description = "4 character short hand for the region where the resources are being created"
#   default = "euc1"
# }

# variable "cidr" {
#   type        = string
#   description = "CIDR block assigned to the VPC being deployed. Must be at least a /22"
#   default = "10.0.0.0/22"
# }

# variable "availability_zones" {
#   type        = list(string)
#   description = "List of availablity zones in the region to deploy subnets to. Will default to using all availability zones in the region."
#   default     = null
# }

# variable "tags" {
#   type        = map(string)
#   description = "Tags to assign to resources in the environment."
#   default     = {}
# }

# variable "web_machine_type" {
#   type        = string
#   description = "Machine type used for web app front end."
#   default     = "m6g.4xlarge"
# }

# variable "web_root_disk_size" {
#   type        = number
#   description = "Size fo the root disk for web servers."
#   default     = 100
# }

# variable "mem_machine_type" {
#   type        = string
#   description = "Machine type used for memcache front end."
#   default     = "m6g.2xlarge"
# }

# variable "mem_root_disk_size" {
#   type        = number
#   description = "Size fo the root disk for memcache servers."
#   default     = 100
# }

# variable "dev_machine_type" {
#   type        = string
#   description = "Machine type used for dev app front end."
#   default     = "r6g.2xlarge"
# }

# variable "dev_root_disk_size" {
#   type        = number
#   description = "Size fo the root disk for dev servers."
#   default     = 100
# }

# variable "on_prem_cidr" {
#   type        = list(string)
#   description = "List of CIDRs to allow access to servers from on prem"
#   default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
# }

# variable "vpn_aws_secret_name" {
#   description = "AWS Secrets Manager name for VPN PSK"
#   type        = string
#   default = "vpn-secret"
# }

# variable "client_vpn_ip_0" {
#   description = "Primary on-prem VPN gateway IP"
#   type        = string
#   default = "55.55.55.55"
# }

# variable "client_vpn_ip_1" {
#   description = "Secondary on-prem VPN gateway IP"
#   type        = string
#   default = "66.66.66.66"
# }

# variable "on_prem_cidr_0" {
#   type        = string
#   description = "CIDR of the on prem network, to allow routing from AWS to on prem"
#   default     = "0.0.0.0/0"
# }

# variable "on_prem_cidr_1" {
#   type        = string
#   description = "CIDR of the on prem network, to allow routing from AWS to on prem"
#   default     = "0.0.0.0/0"
# }

# variable "termination_protection_enabled" {
#   type        = bool
#   description = "If set to true, EC2 instances cannot be terminated. Must be changed to false before any destructive changes cab be implemented."
#   default     = false
# }
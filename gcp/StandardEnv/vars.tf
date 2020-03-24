variable "projectID" {}
variable "networkName" {}
variable "region" {}
variable "zone" {}
variable "automation_key" {}
variable "client_admin_key" {}

##+#+#+#+#+#+#+#+#+#+#
##This full block must be repeated for every different instance type
variable "servers1" {}

variable "servers1_machine_type" {}
variable "servers1_image_family" {}
variable "servers1_image_project" {}
variable "servers1_env" {}
variable "servers1_role" {}

variable "server1_replicas" {
  type    = "number"
  default = 1
}

##+#+#+#+#+#+#+#+#+#+#

variable "db_version" {}
variable "db_root_password" {}

variable "ipCIDR" {
  type    = "list"
  default = [""]
}

variable "onpremCIDR" {}
variable "onprem_VPN_IP" {}
variable "vpn-secret" {}

variable "podCIDR" {
  default = ""
}

variable "serviceCIDR" {
  type    = "list"
  default = [""]
}

variable "specialIPs" {
  type        = "list"
  description = "List of IPs to allow through general firewalls"
  default     = ["x.x.x.x"]
}

variable "bastionSourceIP" {
  type        = "list"
  description = "IPs to allow connecting to the bastion"
  default     = ["0.0.0.0/0"]
}

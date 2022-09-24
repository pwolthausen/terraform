variable "cloudca_api_key" {
  type        = string
  description = "API key used to access cloud.ca storage bucket"
}

variable "azure_sub" {
  type        = string
  description = "Subscription ID used to deploy resources"
}

variable "os_admin" {
  type        = string
  default     = "pwolthausen"
  description = "OS admin user"
}

variable "vpn_peer_address" {
  type    = string
  default = ""
}

variable "vpn_peer_bgp_asn" {
  type    = string
  default = ""
}

variable "vpn_peer_bgp_ip" {
  type    = string
  default = ""
}
# output "bastion_endpoint" {
#   value = azurerm_public_ip.bastion.ip_address
# }

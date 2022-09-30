variable "location" {
  type        = string
  description = "Region where resources are being created"
}

variable "region_code" {
  type        = string
  description = "abbreviated code for the location where resources are created. Used in various resource names and tags"
}

variable "address_space" {
  type        = list(string)
  description = "Address space used by the hub virtual network. Must be at least /27"
}

variable "address_prefix" {
  type        = list(string)
  description = "Address prefix used by gateway subnet. Must be at least /27. If unset, address space will be used"
  default     = null
}

variable "vpn_peer_name" {
  type        = string
  description = "Abbreviated code name for the vpn peer site"
}

variable "vpn_peer_address" {
  type        = string
  description = "External IP address of the on prem VPN gateway device"
}

variable "vpn_peer_bgp_ip" {
  type        = string
  description = "APIPA IP address of the on prem device used for the BGP session, must be within 168.254.21.0/24 or 169.254.22.0/24"
  default     = "169.254.21.2"
}

variable "vpn_peer_bgp_asn" {
  type        = string
  description = "ASN assigned to the on-prem BGP device"
  default     = "64514"
}

variable "vpn_az_bgp_ip" {
  type        = list(string)
  description = "APIPA IP address used for the azure gateway BGP session"
  default     = ["169.254.21.1"]
}

variable "vpn_az_bgp_asn" {
  type        = string
  description = "ASN assigned to the azure gateway"
  default     = "64513"
}

variable "shared_key" {
  type        = string
  description = "Shared key used for IPsec session"
}

variable "global_tags" {
  type        = map(any)
  description = "global tags assigned to all resources in the module"
  default     = {}
}

variable "prefix" {
  type        = string
  description = "Prefix used on resources created"
}

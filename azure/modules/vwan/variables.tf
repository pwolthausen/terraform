variable "location" {
  type        = string
  description = "Region where resources are being created"
}

variable "region_code" {
  type        = string
  description = "abbreviated code for the location where resources are created. Used in various resource names and tags"
}

variable "address_space" {
  type        = string
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

variable "vpn_links" {
  type = map(object({
    peer_ip = string
    bgp = map(object({
      asn         = string
      bgp_peer_ip = string
    }))
  }))
  default     = {}
  description = "Mapping of VPN links to create for the VPN site. The bgp value should be a mapping in the style of <asn> = <bgp_peer_ip>"
}


terraform {
  experiments = [module_variable_optional_attrs]
}

variable "application_rule_collection" {
  type = map(object({
    priority = number
    action   = string
    rules = map(object({
      source_addresses      = optional(list(any))
      source_ip_groups      = optional(list(any))
      destination_urls      = optional(list(any))
      destination_fqdns     = optional(list(any))
      destination_fqdn_tags = optional(list(any))
      terminate_tls         = optional(bool)
      web_categories        = optional(list(any))
      protocols             = map(any)
    }))
  }))
  default = {}
}

variable "network_rule_collection" {
  default = {}
}

variable "nat_rule_collection" {
  default = {}
}

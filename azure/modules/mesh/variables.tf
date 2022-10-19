# terraform {
#   experiments = [module_variable_optional_attrs]
# }

##########################
#### Global variables
##########################

variable "location" {
  type        = string
  description = "Region where resources are being created"
}

variable "region_code" {
  type        = string
  description = "abbreviated code for the location where resources are created. Used in various resource names and tags"
}

variable "business_unit" {
  type        = string
  description = "Business Unit that owns these resources"
}

variable "env" {
  type    = string
  default = "core"
}

variable "address_space" {
  type        = string
  description = "Address space used by the hub virtual network. Must be at least /24"
}

variable "global_tags" {
  type        = map(any)
  description = "global tags assigned to all resources in the module"
  default     = {}
}


##########################
#### VPN variables
##########################

variable "bgp_settings" {
  type = map(object({
    link0 = string
    link1 = string
  }))
  default     = {}
  description = "If this block is defined, the vwan gateway will use BGP. All VPN sites and connections must also use BGP"
}

variable "vpn_connections" {
  default     = {}
  description = "Definition of the different VPN connections. Each block within contains the definition of a single VPN site with connections"
  type = map(object({
    shared_key    = string
    address_cidrs = optional(list(string))
    vpn_links = map(object({
      peer_ip = string
      bgp = optional(map(object({
        asn         = string
        bgp_peer_ip = string
      })))
    }))
  }))
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
  default     = {}
  description = "each block defines an application rule to add to the firewall policy"
}

variable "network_rule_collection" {
  description = "Each block defines a network rule to add to the firewall policy"
  default     = {}
  type = map(object({
    priority = number
    action   = string
    rule = map(object({
      protocols             = list(string)
      source_addresses      = optional(list(string))
      source_ip_groups      = optional(list(string))
      destination_addresses = optional(list(string))
      destination_ip_groups = optional(list(string))
      destination_fqdns     = optional(list(string))
      destination_ports     = optional(list(string))
    }))
  }))
}

variable "nat_rule_collection" {
  description = "Each block defines a NAT rule to add to the firewall policy"
  default     = {}
  type = map(object({
    priority = number
    action   = string
    rule = map(object({
      protocols           = list(string)
      source_addresses    = optional(list(string))
      source_ip_groups    = optional(list(string))
      destination_address = optional(list(string))
      destination_ports   = optional(list(string))
      translated_address  = optional(string)
      translated_fqdn     = optional(string)
      translated_port     = string
    }))
  }))
}

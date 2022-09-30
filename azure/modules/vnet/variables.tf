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

variable "subnets" {
  type        = map(any)
  description = "Mapping of subnets and address prefixes to use with each. Must be a subset of the address_space variable"
}


variable "global_tags" {
  type        = map(any)
  description = "global tags assigned to all resources in the module"
  default     = {}
}

variable "env" {
  type = string
}

variable "app" {
  type = string
}

variable "prefix" {
  type        = string
  description = "Prefix used on resources created"
}

variable "firewall_ip" {
  type        = string
  description = "IP address of the firewall device to use as default route"
}

variable "vhub_route_table_id" {
  type        = string
  description = "ID of the non default vhub route table"
}

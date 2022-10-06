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

variable "env" {
  type = string
}

variable "app" {
  type = string
}

variable "business_unit" {
  type        = string
  description = "Prefix used on resources created"
}

variable "subnets" {
  type        = map(any)
  description = "Mapping of subnets and address prefixes to use with each. Must be a subset of the address_space variable. If unset, a single subnet will be created using the entire available cidr."
  default     = {}
}


variable "global_tags" {
  type        = map(any)
  description = "global tags assigned to all resources in the module"
  default     = {}
}

variable "hub_bu" {
  type        = string
  description = "Business unit code used by the hub resource group"
  default     = "it"
}

variable "hub_env" {
  type        = string
  description = "Environment code used by the hub resource group"
  default     = "core"
}

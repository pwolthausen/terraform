variable "location" {
  type        = string
  description = "Region where resources are being created"
}

variable "region_code" {
  type        = string
  description = "abbreviated code for the location where resources are created. Used in various resource names and tags"
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

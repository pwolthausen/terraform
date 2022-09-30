variable "cloudca_api_key" {
  type        = string
  description = "API key used to access cloud.ca storage bucket"
}

variable "azure_sub" {
  type        = string
  description = "Subscription ID used to deploy resources"
}

variable "location" {
  type        = string
  default     = "Canada Central"
  description = "Azure region"
}

variable "prefix" {
  type        = string
  default     = "pw"
  description = "Prefix used in naming for most resources"
}

variable "os_admin" {
  type        = string
  default     = "pwolthausen"
  description = "OS admin user"
}

variable "shared_key" {
  type    = string
  default = "P@ssw0rd"
}

variable "global_tags" {
  type = map(any)
}

variable "bgp_peer_ip" {
  type        = list(string)
  description = "list of IPs used for peer VPN gateway"
}

variable "application_rule_collection" {
  default = {}
}

variable "network_rule_collection" {
  default = {}
}

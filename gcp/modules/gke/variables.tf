############################
#### Required variables ####
############################

variable "project_id" {
  description = "GCP project ID"
}

variable "domain" {
  description = "project domain - see cloud naming doc"
}

variable "env" {
  description = "project env - see cloud naming doc"
}

variable "usecase" {
  description = "project usecase - see cloud naming doc"
}

variable "index" {
  description = "cluster index with a project - see cloud naming doc"
}

variable "region" {
  description = "region"
}

variable "subnet_name" {
  description = "Name of the Subnet in the shared VPC to be used"
}

variable "cluster_secondary_range" {
  description = "secondary cidr range for GKE cluster"
}

variable "service_secondary_range" {
  description = "secondary cidr range for GKE services"
}

variable "master_ipv4_cidr_block" {
  description = "Private CIDR range for the cluster."
}

############################
#### Optional variables ####
############################

variable "service_account_email" {
  description = "email address for service account"
  type        = string
  default     = null
}

variable "service_account_roles" {
  type        = list(string)
  description = "List of roles to assign to the custom created service account for the cluster. SA comes with the following roles: `storage.objectViewer`, `monitoring.metricWriter`, `monitoring.viewer`, and `logging.logWriter`"
  default     = []
}

variable "network_name" {
  description = "GCP network name"
  default     = "vpc-hyc-prod-nane1-trust-prd"
}

variable "network_project_id" {
  description = "Host Project that contains the shared VPC"
  default     = "hyc-shrd-svc-prod-01"
}

variable "network_tags" {
  description = "tag used for networking rules"
  default     = []
  type        = list(string)
}

variable "node_pools" {
  type        = map(any)
  description = "Node pools definitions"
  default     = {}
}

variable "manifests" {
  type        = list(string)
  description = "list of manifests to deploy to the cluster. Must be placed in a `manifests` directory in the root module"
  default     = []
}

variable "master_authorized_networks" {
  type        = map(any)
  description = "Map of CIDRs authorized to interact with the master endpoint. Must be in format of name = <cidr_range>"
  default     = {}
}

variable "labels" {
  type        = map(any)
  description = "Labels to apply to the cluster and node pools."
  default     = {}
}

variable "non_masquerade_cidrs" {
  type        = list(string)
  description = "List of strings in CIDR notation that specify the IP address ranges that do not use IP masquerading in addition to the pod, service, and subnet CIDRs."
  default     = []
}
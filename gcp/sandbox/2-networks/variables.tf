/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "org_id" {
  description = "The organization id for the associated services"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate this project with"
  type        = string
}

variable "terraform_service_account" {
  description = "Service account email of the account to impersonate to run Terraform."
  type        = string
}

variable "region1" {
  description = "Primary region."
  type        = string
}

variable "region2" {
  description = "Secondary region for interconnect or VPN region."
  type        = string
  default     = "us-east4"
}

variable "parent_folder" {
  description = "Optional - for an organization with existing projects or for development/validation. It will place all the example foundation resources under the provided folder instead of the root organization. The value is the numeric folder ID. The folder must already exist. Must be the same value used in previous step."
  type        = string
  default     = ""
}

variable "folder_prefix" {
  description = "Name prefix to use for folders created. Should be the same in all steps."
  type        = string
  default     = "fldr"
}

/******************************************
  Network Hub Variables
*****************************************/

variable "net_hub_firewall_rules" {
  description = "List of firewall rules to be created for the VPC. There is an explicit deny all ingress and allow all egress"
  type        = list(map(any))
  default     = []
}

variable "net_hub_subnets" {
  description = "List of subnets to create in the network hub VPC. There should only be 1 subnet per required region for the interconnects or VPNs"
  type        = list(map({subnet_name = string, subnet_ip = string, subnet_region = string, subnet_private_access = string, subnet_flow_logs = string, description = string}))
  default     = [
    {
      subnet_name           = "transit-region1-10-150-96"
      subnet_ip             = "10.150.96.0/23"
      subnet_region         = "region1"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Transit subnet in region1 for on prem connectivity"
    },
    {
      subnet_name           = "transit-region2-10-150-98"
      subnet_ip             = "10.150.98.0/23"
      subnet_region         = "region2"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Transit subnet in region2 for on prem connectivity"
    },
    {
      subnet_name           = "org-shared-region1-10-150-100"
      subnet_ip             = "10.150.100.0/23"
      subnet_region         = "region1"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Shared subnet in region1 for org-wide shared resources"
    },
    {
      subnet_name           = "org-shared-region2-10-150-102"
      subnet_ip             = "10.150.102.0/23"
      subnet_region         = "region2"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Shared subnet in region2 for org-wide shared resources"
    }
  ]
}

variable "net_hub_routes" {
  description = "List of custom routes to create in the network hub VPC. GCP will still create standard routing in the VPC. See https://github.com/terraform-google-modules/terraform-google-network#route-inputs for syntax"
  type        = list(map(any))
  default     = []
}

variable "hub_svc_connect_ip" {
  description = "Network address of the range of IPs used for service connect, uses a /22"
  type        = string
  default     = "10.150.104.0"
}

/******************************************
  Prod Shared VPC network variables
*****************************************/

variable "prod_vpc_firewall_rules" {
  description = "List of firewall rules to be created for the VPC. There is an explicit deny all ingress and allow all egress"
  type        = list(map(any))
  default     = []
}

variable "prod_vpc_subnets" {
  description = "List of subnets to create in the VPC. There should only be 1 subnet per required region for the interconnects or VPNs"
  type        = list(map({subnet_name = string, subnet_ip = string, subnet_region = string, subnet_private_access = string, subnet_flow_logs = string, description = string}))
  default     = [
    {
      subnet_name           = "prod-public-region1-10-150-0"
      subnet_ip             = "10.150.0.0/22"
      subnet_region         = "region1"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Public subnet in region1 for prod"
    },
    {
      subnet_name           = "prod-private-region1-10-150-8"
      subnet_ip             = "10.150.8.0/22"
      subnet_region         = "region1"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Private subnet in region1 for prod"
    },
    {
      subnet_name           = "prod-public-region2-10-150-16"
      subnet_ip             = "10.150.16.0/22"
      subnet_region         = "region2"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Public subnet in region2 for prod"
    },
    {
      subnet_name           = "prod-private-region2-10-150-24"
      subnet_ip             = "10.150.24.0/22"
      subnet_region         = "region2"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Private subnet in region2 for prod"
    }
  ]
}

variable "prod_vpc_routes" {
  description = "List of custom routes to create in the VPC. GCP will still create standard routing in the VPC"
  type        = list(map(any))
  default     = []
}

variable "prod_svc_connect_ip" {
  description = "Network address of the range of IPs used for service connect, uses a /22"
  type        = string
  default     = "10.150.108.0"
}

/******************************************
  QA Shared VPC network variables
*****************************************/

variable "qa_vpc_firewall_rules" {
  description = "List of firewall rules to be created for the VPC. There is an explicit deny all ingress and allow all egress"
  type        = list(map(any))
  default     = []
}

variable "qa_vpc_subnets" {
  description = "List of subnets to create in the VPC. There should only be 1 subnet per required region for the interconnects or VPNs"
  type        = list(map({subnet_name = string, subnet_ip = string, subnet_region = string, subnet_private_access = string, subnet_flow_logs = string, description = string}))
  default     = [
    {
      subnet_name           = "qa-public-region1-10-150-32"
      subnet_ip             = "10.150.32.0/22"
      subnet_region         = "region1"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Public subnet in region1 for qa"
    },
    {
      subnet_name           = "qa-private-region1-10-150-40"
      subnet_ip             = "10.150.40.0/22"
      subnet_region         = "region1"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Private subnet in region1 for qa"
    },
    {
      subnet_name           = "qa-public-region2-10-150-48"
      subnet_ip             = "10.150.48.0/22"
      subnet_region         = "region2"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Public subnet in region2 for qa"
    },
    {
      subnet_name           = "qa-private-region2-10-150-56"
      subnet_ip             = "10.150.56.0/22"
      subnet_region         = "region2"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Private subnet in region2 for qa"
    }
  ]
}

variable "qa_vpc_routes" {
  description = "List of custom routes to create in the VPC. GCP will still create standard routing in the VPC"
  type        = list(map(any))
  default     = []
}

variable "qa_svc_connect_ip" {
  description = "Network address of the range of IPs used for service connect, uses a /22"
  type        = string
  default     = "10.150.112.0"
}

/******************************************
  Dev Shared VPC network variables
*****************************************/

variable "dev_vpc_firewall_rules" {
  description = "List of firewall rules to be created for the VPC. There is an explicit deny all ingress and allow all egress"
  type        = list(map(any))
  default     = []
}

variable "dev_vpc_subnets" {
  description = "List of subnets to create in the VPC. There should only be 1 subnet per required region for the interconnects or VPNs"
  type        = list(map({subnet_name = string, subnet_ip = string, subnet_region = string, subnet_private_access = string, subnet_flow_logs = string, description = string}))
  default     = [
    {
      subnet_name           = "dev-public-region1-10-150-64"
      subnet_ip             = "10.150.64.0/22"
      subnet_region         = "region1"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Public subnet in region1 for dev"
    },
    {
      subnet_name           = "dev-private-region1-10-150-72"
      subnet_ip             = "10.150.72.0/22"
      subnet_region         = "region1"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Private subnet in region1 for dev"
    },
    {
      subnet_name           = "dev-public-region2-10-150-80"
      subnet_ip             = "10.150.80.0/22"
      subnet_region         = "region2"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Public subnet in region2 for dev"
    },
    {
      subnet_name           = "dev-private-region2-10-150-88"
      subnet_ip             = "10.150.88.0/22"
      subnet_region         = "region2"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Private subnet in region2 for dev"
    }
  ]
}

variable "dev_vpc_routes" {
  description = "List of custom routes to create in the VPC. GCP will still create standard routing in the VPC"
  type        = list(map(any))
  default     = []
}

variable "dev_svc_connect_ip" {
  description = "Network address of the range of IPs used for service connect, uses a /22"
  type        = string
  default     = "10.150.116.0"
}

/******************************************
  interconnect variables
  These nust be defined in tfvars if partner interconnect is being used
*****************************************/
variable "enable_interconnect" {
  type    = bool
  default = false
}
variable "enable_partner_interconnect" {
  type    = bool
  default = false
}

variable "region1_interconnect1_location" {
  type    = string
  default = ""
}

variable "region1_interconnect2_location" {
  type    = string
  default = ""
}

variable "region2_interconnect1_location" {
  type    = string
  default = ""
}

variable "region2_interconnect2_location" {
  type    = string
  default = ""
}

variable "interconnect_region1" {
  type    = string
  default = ""
}

variable "interconnect_region2" {
  type    = string
  default = ""
}

/******************************************
  VPN variables
*****************************************/

variable "enable_ha_vpn" {
  type    = bool
  default = false
}

variable "vpn_secret" {
  type    = string
  default = ""
}

variable "peer_ips" {
  type        = list(string)
  description = "List of peer IPs. There should be 1 per on prem gateway"
  default     = []
}

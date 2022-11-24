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


/******************************************
 VPN
*****************************************/

module "vpn_ha" {
  count  = var.enable_ha_vpn ? 1 : 0
  source = "terraform-google-modules/vpn/google//modules/vpn_ha"

  project_id = data.google_project.org_network_project.project_id
  region     = var.region1
  network    = module.hub_network.network_name
  name       = "vpn-"

  peer_external_gateway = {
    redundancy_type = length(var.peer_ips) == 1 ? "SINGLE_IP_INTERNALLY_REDUNDANT" : "TWO_IPS_REDUNDANCY"
    interfaces = [{
      id         = 0
      ip_address = var.peer_ips[0]

      },
      {
        id         = 1
        ip_address = var.peer_ips[1]
      }
    ]
  }
  router_asn = 64514
  tunnels = {
    remote-0 = {
      bgp_peer = {
        address = "169.254.11.1"
        asn     = 64513
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.11.2/30"
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = var.vpn_secret
    }
    remote-1 = {
      bgp_peer = {
        address = "169.254.12.1"
        asn     = 64513
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.12.2/30"
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 0
      shared_secret                   = var.vpn_secret
    }
    remote-2 = {
      bgp_peer = {
        address = "169.254.13.1"
        asn     = 64513
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.13.2/30"
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 1
      shared_secret                   = var.vpn_secret
    }
    remote-3 = {
      bgp_peer = {
        address = "169.254.14.1"
        asn     = 64513
      }
      bgp_peer_options                = null
      bgp_session_range               = "169.254.14.2/30"
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 1
      shared_secret                   = var.vpn_secret
    }
  }
}

/******************************************
 Interconnect
*****************************************/

module "region1_router1" {
  count   = var.enable_partner_interconnect || var.enable_interconnect ? 1 : 0
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 1.2"
  name    = "cr-${module.hub_network.network_name}-${var.region1}-cr1"
  project = data.google_project.org_network_project.project_id
  network = module.hub_network.network_name
  region  = var.region1
  bgp = {
    asn                  = local.bgp_asn_number
    advertised_groups    = ["ALL_SUBNETS"]
    advertised_ip_ranges = [{ range = local.private_googleapis_cidr }]
  }
}

module "region1_router2" {
  count   = var.enable_partner_interconnect || var.enable_interconnect ? 1 : 0
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 1.2"
  name    = "cr-${module.hub_network.network_name}-${var.region1}-cr2"
  project = data.google_project.org_network_project.project_id
  network = module.hub_network.network_name
  region  = var.region1
  bgp = {
    asn                  = local.bgp_asn_number
    advertised_groups    = ["ALL_SUBNETS"]
    advertised_ip_ranges = [{ range = local.private_googleapis_cidr }]
  }
}

module "region2_router1" {
  count   = var.enable_partner_interconnect || var.enable_interconnect ? 1 : 0
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 1.2"
  name    = "cr-${module.hub_network.network_name}-${var.region2}-cr3"
  project = data.google_project.org_network_project.project_id
  network = module.hub_network.network_name
  region  = var.region2
  bgp = {
    asn                  = local.bgp_asn_number
    advertised_groups    = ["ALL_SUBNETS"]
    advertised_ip_ranges = [{ range = local.private_googleapis_cidr }]
  }
}

module "region2_router2" {
  count   = var.enable_partner_interconnect || var.enable_interconnect ? 1 : 0
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 1.2"
  name    = "cr-${module.hub_network.network_name}-${var.region2}-cr4"
  project = data.google_project.org_network_project.project_id
  network = module.hub_network.network_name
  region  = var.region2
  bgp = {
    asn                  = local.bgp_asn_number
    advertised_groups    = ["ALL_SUBNETS"]
    advertised_ip_ranges = [{ range = local.private_googleapis_cidr }]
  }
}

module "partner_interconnect" {
  count         = var.enable_partner_interconnect ? 1 : 0
  source        = "../modules/partner_interconnect"
  org_id        = var.org_id
  vpc_name      = module.hub_network.network_name
  environment   = "shared"
  parent_folder = var.parent_folder
  preactivate   = false

  region1                        = var.interconnect_region1
  region1_router1_name           = module.region1_router1[0].router.name
  region1_router2_name           = module.region1_router2[0].router.name
  region1_interconnect1_location = var.region1_interconnect1_location
  region1_interconnect2_location = var.region1_interconnect2_location

  region2                        = var.interconnect_region2
  region2_router1_name           = module.region2_router1[0].router.name
  region2_router2_name           = module.region2_router2[0].router.name
  region2_interconnect1_location = var.region2_interconnect1_location
  region2_interconnect2_location = var.region2_interconnect2_location

  cloud_router_labels = {
    vlan_1 = "cr5",
    vlan_2 = "cr6",
    vlan_3 = "cr7",
    vlan_4 = "cr8"
  }
}

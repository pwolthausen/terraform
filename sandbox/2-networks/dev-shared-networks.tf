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

module "dev_network" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 3.4"
  project_id                             = data.google_project.org_network_project.project_id
  network_name                           = "vpc-shared-dev"
  shared_vpc_host                        = "true"
  delete_default_internet_gateway_routes = "true"

  firewall_rules = var.dev_vpc_firewall_rules

  subnets = var.dev_vpc_subnets

  routes = var.dev_vpc_routes
}


module "net_hub_dev_shared_vpc_peering" {
  source  = "terraform-google-modules/network/google//modules/network-peering"
  version = "3.4.0"

  prefix                     = "pn-dev-hub"
  local_network              = module.dev_network.network_self_link
  peer_network               = module.hub_network.network_self_link
  export_peer_custom_routes  = true
  export_local_custom_routes = true
  depends_on = [
    module.dev_network,
    module.hub_network
  ]
}

resource "google_compute_firewall" "dev_iap" {
  project       = data.google_project.org_network_project.project_id
  name          = "fw-dev-allow-all-lb-health-checks-iap"
  network       = module.dev_network.network_name
  direction     = "INGRESS"
  source_ranges = ["35.191.0.0/16", "209.85.152.0/22", "209.85.204.0/22", "130.211.0.0/22", "35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports    = []
  }
}

/******************************************
  VPC Private connection
*****************************************/

resource "google_compute_global_address" "dev_private_ip_alloc" {
  project       = data.google_project.org_network_project.project_id
  name          = "dev-private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = var.dev_svc_connect_ip
  prefix_length = 22
  network       = module.dev_network.network_id
}

resource "google_service_networking_connection" "dev_svc_connect" {
  network                 = module.dev_network.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.dev_private_ip_alloc.name]
}

/******************************************
  NAT routers (1 per region)
*****************************************/

resource "google_compute_router" "dev_nat_router_region1" {
  project = data.google_project.org_network_project.project_id
  name    = "dev-nat-router-${var.region1}"
  region  = var.region1
  network = module.dev_network.network_name

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "dev_nat_gateway_region1" {
  project                            = data.google_project.org_network_project.project_id
  name                               = "dev-nat-gateway-${var.region1}"
  router                             = google_compute_router.dev_nat_router_region1.name
  region                             = var.region1
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_router" "dev_nat_router_region2" {
  project = data.google_project.org_network_project.project_id
  name    = "dev-nat-router-${var.region2}"
  region  = var.region2
  network = module.dev_network.network_name

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "dev_nat_gateway_region2" {
  project                            = data.google_project.org_network_project.project_id
  name                               = "dev-nat-gateway-${var.region2}"
  router                             = google_compute_router.dev_nat_router_region2.name
  region                             = var.region2
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

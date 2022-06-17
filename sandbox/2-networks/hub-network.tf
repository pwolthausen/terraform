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

module "hub_network" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 3.4"
  project_id                             = data.google_project.org_network_project.project_id
  network_name                           = "vpc-core-hub"
  shared_vpc_host                        = "true"
  delete_default_internet_gateway_routes = "true"

  firewall_rules = var.net_hub_firewall_rules

  subnets = var.net_hub_subnets

  routes = var.net_hub_routes
}

resource "google_compute_firewall" "hub_iap" {
  project       = data.google_project.org_network_project.project_id
  name          = "fw-hub-allow-all-lb-health-checks-iap"
  network       = module.hub_network.network_name
  direction     = "INGRESS"
  source_ranges = ["35.191.0.0/16", "209.85.152.0/22", "209.85.204.0/22", "130.211.0.0/22", "35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports    = []
  }
}

resource "google_compute_global_address" "hub_private_ip_alloc" {
  project       = data.google_project.org_network_project.project_id
  name          = "hub-private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = var.hub_svc_connect_ip
  prefix_length = 22
  network       = module.hub_network.network_id
}

resource "google_service_networking_connection" "hub_svc_connect" {
  network                 = module.hub_network.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.dev_private_ip_alloc.name]
}



module "vpc_test_vpn_peer_routes" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 3.4"
  project_id                             = var.project_id
  network_name                           = "test-vpn-peering-routes"
  shared_vpc_host                        = "false"
  delete_default_internet_gateway_routes = "false"

  firewall_rules = []

  subnets = [
    {
      subnet_name           = "sb-test-vpn-peering-routes-ne1"
      subnet_ip             = "192.168.0.0/24"
      subnet_region         = var.region
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "Test route propagation over VPN and peering"
    }
  ]
  routes = []
}

resource "google_compute_address" "test_hub_vpn_gw" {
  project = var.project_id
  region  = var.region

  name         = "test_hub_vpn_gw-ext-ip"
  address_type = "EXTERNAL"
}


module "vpn_hub" {
  source  = "terraform-google-modules/vpn/google"
  version = "~> 1.2.0"

  project_id         = var.project_id
  network            = data.google_compute_network.hub_vpc.network_id
  region             = "us-central1"
  gateway_name       = "test-hub-vpn-gw"
  tunnel_name_prefix = "test-hub"
  shared_secret      = data.google_secret_manager_secret_version.vpn_secret.secret_data
  tunnel_count       = 1
  peer_ips           = [google_compute_address.test_vpc_vpn_gw.address]
  peer_asn           = ["65101"]
  vpn_gw_ip          = google_compute_address.test_hub_vpn_gw.address

  cr_enabled = true
  cr_name = "test_hub_vpn"
  bgp_cr_session_range = ["169.254.0.1", "169.254.1.1"]
  bgp_remote_session_range = ["169.254.0.2", "169.254.1.2"]
}

resource "google_compute_address" "test_vpc_vpn_gw" {
  project = var.project_id
  region  = var.region

  name         = "test_hub_vpc_gw-ext-ip"
  address_type = "EXTERNAL"
}

module "vpn_test" {
  source  = "terraform-google-modules/vpn/google"
  version = "~> 1.2.0"

  project_id         = var.project_id
  network            = module.vpc_test_vpn_peer_routes.network_id
  region             = var.region
  gateway_name       = "test-vpc-vpn-gw"
  tunnel_name_prefix = "test-vpc"
  shared_secret      = data.google_secret_manager_secret_version.vpn_secret.secret_data
  tunnel_count       = 1
  peer_ips           = [google_compute_address.test_hub_vpn_gw.address]
  peer_asn           = ["65101"]
  vpn_gw_ip          = google_compute_address.test_vpc_vpn_gw.address

  cr_enabled = true
  cr_name = "test_vpc_vpn"
  bgp_cr_session_range = ["169.254.0.2", "169.254.1.2"]
  bgp_remote_session_range = ["169.254.0.1", "169.254.1.1"]
}
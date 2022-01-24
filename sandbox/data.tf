data google_compute_network hub_vpc {
    project = var.project_id
    name = "hub"
}

data "google_secret_manager_secret_version" "vpn_secret" {
  project = var.project_id
  secret  = "vpn-shared-secret"
}

data google_compute_network cartdotcom {
    project = var.project_id
    name = "cartdotcom"
}

data "google_compute_subnetwork" "prod" {
  project = var.project_id
  name    = var.subnet
  region  = var.region
}
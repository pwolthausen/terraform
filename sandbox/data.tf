data google_compute_network hub_vpc {
    project = var.project_id
    name = "hub"
}

data "google_secret_manager_secret_version" "vpn_secret" {
  project = var.project_id
  secret  = "vpn-shared-secret"
}
data "google_project" "project" {
  project_id = var.project_id
}

data "google_compute_network" "network" {
  project = var.project_id
  name    = "vpc-pw-core"
}

data "google_compute_subnetwork" "subnetwork" {
  name    = "dublin"
  project = var.project_id
  region  = var.region
}

# GKE cluster
resource "google_container_cluster" "primary" {
  provider = google-beta
  name     = "gke-bell-network-common-nbd-01"
  location = var.region
  project  = var.project_id

  node_config {
    tags = ["gke-bell-network-common-nbd-gke-npe-cluster"]
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    service_account = "${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  }
  release_channel {
    channel = "STABLE"
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    master_global_access_config {
      enabled = false
    }
  }


  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "10.61.120.0/25"
      display_name = "prod-common-cicd"
    }
    # cidr_blocks {
    #   cidr_block   = data.google_compute_subnetwork.subnetwork.ip_cidr_range
    #   display_name = "VPC"
    # }
  }

  initial_node_count = 1

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-cidr"
    services_secondary_range_name = "service-cidr-0"
  }

  network                   = data.google_compute_network.network.self_link
  subnetwork                = data.google_compute_subnetwork.subnetwork.self_link
  default_max_pods_per_node = 20

  default_snat_status {
    disabled = true
  }

  network_policy {
    enabled = true
  }

  workload_identity_config {
    workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
  }

  resource_labels = {
    env = "test"
  }
}


# resource "google_service_account" "default" {
#   account_id   = var.service_account_id
#   display_name = "GKE Service Account"
# }

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  project    = var.project_id
  name       = "${google_container_cluster.primary.name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 2
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/servicecontrol",
    ]
    service_account = "${data.google_project.project.number}-compute@developer.gserviceaccount.com"

    labels = {
      env = google_container_cluster.primary.name
    }
    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${google_container_cluster.primary.name}", "gke-bell-network-common-nbd-gke-npe-cluster"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

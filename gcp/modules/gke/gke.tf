# GKE cluster

data "google_compute_network" "network" {
  project = var.network_project_id
  name    = var.network_name
}

data "google_compute_subnetwork" "subnetwork" {
  name    = var.subnet_name
  project = var.network_project_id
  region  = var.region
}

resource "google_container_cluster" "cluster" {
  provider = google-beta
  name     = "gke-${var.domain}-${var.env}-${var.usecase}-${var.index}"
  location = var.region
  project  = var.project_id

  node_config {
    service_account = local.gke_sa_email
    tags            = var.network_tags
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  release_channel {
    channel = "STABLE"
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    master_global_access_config {
      enabled = false
    }
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value
        display_name = cidr_blocks.key
      }
    }
    cidr_blocks {
      cidr_block   = data.google_compute_subnetwork.subnetwork.ip_cidr_range
      display_name = "local-subnet"
    }
  }

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_secondary_range
    services_secondary_range_name = var.service_secondary_range
  }

  network                   = data.google_compute_network.network.self_link
  subnetwork                = data.google_compute_subnetwork.subnetwork.self_link
  default_max_pods_per_node = 30

  default_snat_status {
    disabled = true
  }

  network_policy {
    enabled = true
  }

  monitoring_config {
    managed_prometheus {
      enabled = true
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  resource_labels = merge(var.labels, {
    env = var.env
    # mesh_id = "proj-${data.google_project.project.number}"
  })

  lifecycle {
    ignore_changes = [node_pool, initial_node_count, resource_labels["asmv"], resource_labels["mesh_id"]]
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "pool" {
  for_each       = var.node_pools
  project        = var.project_id
  name           = each.key
  location       = var.region
  node_locations = lookup(each.value, "node_locations", null)
  cluster        = google_container_cluster.cluster.name

  node_count = lookup(each.value, "initial_node_count", 1)
  autoscaling {
    min_node_count = lookup(each.value, "min_count", 0)
    max_node_count = lookup(each.value, "max_count", 5)
  }

  node_config {
    machine_type    = lookup(each.value, "machine_type", "n2-standard-8")
    disk_size_gb    = lookup(each.value, "disk_size_gb", 100)
    disk_type       = lookup(each.value, "disk_type", "pd-standard")
    local_ssd_count = lookup(each.value, "local_ssd_count", 0)
    image_type      = lookup(each.value, "image_type", "COS")

    service_account = var.service_account_email
    tags            = concat(["gke-bell-network-common-nbd-gke-${var.env}-cluster"], var.network_tags)
    oauth_scopes = [
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/servicecontrol",
    ]


    labels = merge(var.labels, {
      env = var.env
      # mesh_id = "proj-${data.google_project.project.number}"
    })

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = lookup(each.value, "auto_upgrade", true)
  }
}

data "kubectl_file_documents" "manifests" {
  for_each = toset(var.manifests)
  content  = file("${path.root}/manifests/${each.key}")
}

resource "kubectl_manifest" "manifests" {
  for_each  = toset(var.manifests)
  yaml_body = data.kubectl_file_documents.manifests[each.key].documents
}

# module "asm" {
#   source           = "terraform-google-modules/kubernetes-engine/google//modules/asm"
#   project_id       = var.project_id
#   cluster_name     = google_container_cluster.cluster.name
#   cluster_location = google_container_cluster.cluster.location
#   enable_cni       = true
#   internal_ip      = true
# }

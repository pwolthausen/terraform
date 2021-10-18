##Set provider config
provider "google" {
  project     = var.projectID
  credentials = "${file("credentials.json")}"
}

##Reserve Statis IPs
resource "google_compute_address" "bastionip" {
  name   = "bastionip"
  region = "northamerica-northeast1"
}

resource "google_compute_global_address" "nginxIP" {
  name = "nginx"
}

resource "google_compute_global_address" "webip" {
  name = "webip"
}

##Create bastion host
resource "google_compute_instance" "bastionHost" {
  name         = "bastion"
  zone         = "northamerica-northeast1-a"
  machine_type = "f1-micro"
  tags         = ["bastion"]

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      size  = "30"
      type  = "pd-standard"
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network    = google_compute_network.newVPC.self_link
    subnetwork = google_compute_subnetwork.belfastSubnet.self_link

    access_config {
      nat_ip = google_compute_address.bastionip.address
    }
  }

  metadata {
    block-project-ssh-keys = "true"
    enable-oslogin         = "true"
  }

  service_account {
    scopes = []
  }
}

##Create GKE cluster
resource "google_container_cluster" "sheehy" {
  name                      = "sheehy"
  location                  = "northamerica-northeast1"
  network                   = google_compute_network.newVPC.self_link
  subnetwork                = google_compute_subnetwork.dublinSubnet.self_link
  remove_default_node_pool  = true
  initial_node_count        = 1
  default_max_pods_per_node = 55

  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-cidr"
    services_secondary_range_name = "service-cidr"
  }

  master_authorized_networks_config {
    cidr_blocks = [{
      cidr_block   = "192.168.0.0/16"
      display_name = "access from within the GCP project"
    },
    {
      cidr_block   = var.mypcip
      display_name = "home PC"
    }]
  }

  private_cluster_config {
    enable_private_nodes   = true
    master_ipv4_cidr_block = cidrsubnet(var.masterCIDR, var.masternewbits, 1)
  }

  vertical_pod_autoscaling {
    enabled = true
  }
}

resource "google_container_node_pool" "kube-system" {
  name               = "kubesystem"
  location           = "northamerica-northeast1"
  cluster            = google_container_cluster.sheehy.name
  initial_node_count = 2

  autoscaling {
    min_node_count = 1
    max_node_count = 4
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    image_type = "COS"

    labels {
      key   = "workloads"
      value = "kube-system"
    }
  }
}

resource "google_container_node_pool" "narwhal" {
  name               = "narwhal"
  location           = "northamerica-northeast1"
  cluster            = google_container_cluster.sheehy.name
  initial_node_count = 2

  autoscaling {
    min_node_count = 1
    max_node_count = 4
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    image_type = "COS"

    labels {
      key   = "workloads"
      value = "apps"
    }

    taint {
      key    = "app"
      value  = "nonsystem"
      effect = "NO_SCHEDULE"
    }
  }
}

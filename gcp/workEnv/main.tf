##Set provider config
provider "google" {
  project     = "${var.projectID}"
  credentials = "${file("credentials.json")}"
}

##Create network, subnets,, and firewall rules
resource "google_compute_network" "newVPC" {
  name                    = "${var.networkName}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "dublinSubnet" {
  name                     = "dublin"
  region                   = "northamerica-northeast1"
  network                  = "${google_compute_network.newVPC.self_link}"
  ip_cidr_range            = "${var.ipCIDR[0]}"
  private_ip_google_access = true

  secondary_ip_range = [{
    range_name    = "pod-cidr"
    ip_cidr_range = "${var.podCIDR[0]}"
  },
    {
      range_name    = "service-cidr"
      ip_cidr_range = "${var.serviceCIDR[0]}"
    },
  ]
}

resource "google_compute_subnetwork" "belfastSubnet" {
  name                     = "belfast"
  region                   = "northamerica-northeast1"
  network                  = "${google_compute_network.newVPC.self_link}"
  ip_cidr_range            = "${var.ipCIDR[1]}"
  private_ip_google_access = true

  secondary_ip_range = [{
    range_name    = "pod-cidr"
    ip_cidr_range = "${var.podCIDR[1]}"
  },
    {
      range_name    = "service-cidr1"
      ip_cidr_range = "${var.serviceCIDR[1]}"
    },
    {
      range_name    = "service-cidr2"
      ip_cidr_range = "${var.serviceCIDR[2]}"
    },
  ]
}

resource "google_compute_subnetwork" "corkSubnet" {
  name                     = "cork"
  region                   = "us-east1"
  network                  = "${google_compute_network.newVPC.self_link}"
  ip_cidr_range            = "${var.ipCIDR[2]}"
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "galwaySubnet" {
  name                     = "galway"
  region                   = "us-central1"
  network                  = "${google_compute_network.newVPC.self_link}"
  ip_cidr_range            = "${var.ipCIDR[3]}"
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "sligoSubnet" {
  name                     = "sligo"
  region                   = "us-west1"
  network                  = "${google_compute_network.newVPC.self_link}"
  ip_cidr_range            = "${var.ipCIDR[4]}"
  private_ip_google_access = true
}

resource "google_compute_firewall" "allow-web-traffic" {
  name    = "allow-web-traffic"
  network = "${google_compute_network.newVPC.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

resource "google_compute_firewall" "bastion-ssh" {
  name    = "bastion-ssh"
  network = "${google_compute_network.newVPC.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion"]
}

resource "google_compute_firewall" "allow-internal" {
  name    = "allow-internal"
  network = "${google_compute_network.newVPC.self_link}"

  allow {
    protocol = "all"
  }

  source_ranges = ["192.168.0.0/16"]
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
    network    = "${google_compute_network.newVPC.self_link}"
    subnetwork = "${google_compute_subnetwork.belfastSubnet.self_link}"

    access_config {
      nat_ip = "${google_compute_address.bastionip.address}"
    }
  }

  metadata {
    "block-project-ssh-keys" = "true"
    "enable-oslogin"         = "true"
  }

  service_account {
    scopes = []
  }
}

##Create GKE cluster
resource "google_container_cluster" "sheehy" {
  name                      = "sheehy"
  location                  = "northamerica-northeast1"
  network                   = "${google_compute_network.newVPC.self_link}"
  subnetwork                = "${google_compute_subnetwork.dublinSubnet.self_link}"
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
        cidr_block   = "${var.mypcip}"
        display_name = "home PC"
      },
    ]
  }

  private_cluster_config {
    enable_private_nodes   = true
    master_ipv4_cidr_block = "${var.masterCIDR[0]}"
  }

  # vertical_pod_autoscaling {
  #   enabled = true
  # }
}

resource "google_container_node_pool" "kube-system" {
  name               = "kubesystem"
  location           = "northamerica-northeast1"
  cluster            = "${google_container_cluster.sheehy.name}"
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
  cluster            = "${google_container_cluster.sheehy.name}"
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

    taint {
      key    = "app"
      value  = "nonsystem"
      effect = "NO_SCHEDULE"
    }
  }
}

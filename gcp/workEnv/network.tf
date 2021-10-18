##Create network and subnets
resource "google_compute_network" "newVPC" {
  name                    = var.networkName
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "dublin" {
  name                     = "dublin"
  region                   = "northamerica-northeast1"
  network                  = google_compute_network.newVPC.self_link
  ip_cidr_range            = cidrsubnet(var.ipCIDR, var.newbits, 1)
  private_ip_google_access = true

  secondary_ip_range = [{
    range_name    = "pod-cidr"
    ip_cidr_range = cidrsubnet(var.podCIDR, var.podnewbits, 1)
  },
  {
    range_name    = "service-cidr"
    ip_cidr_range = cidrsubnet(var.serviceCIDR, var.servicenewbits, 1)
  },
  {
    range_name    = "service-cidr2"
    ip_cidr_range = cidrsubnet(var.serviceCIDR, var.servicenewbits, 2)
  },
  {
    range_name    = "service-cidr3"
    ip_cidr_range = cidrsubnet(var.serviceCIDR, var.servicenewbits, 3)
  }]
}

resource "google_compute_subnetwork" "belfast" {
  name                     = "belfast"
  region                   = "northamerica-northeast1"
  network                  = google_compute_network.newVPC.self_link
  ip_cidr_range            = cidrsubnet(var.ipCIDR, var.newbits, 2)
  private_ip_google_access = true

  secondary_ip_range = [{
    range_name    = "pod-cidr"
    ip_cidr_range = cidrsubnet(var.podCIDR, var.podnewbits, 2)
  },
  {
    range_name    = "service-cidr1"
    ip_cidr_range = cidrsubnet(var.serviceCIDR, var.servicenewbits, 5)
  },
  {
    range_name    = "service-cidr2"
    ip_cidr_range = cidrsubnet(var.serviceCIDR, var.servicenewbits, 6)
  },
  {
    range_name    = "service-cidr3"
    ip_cidr_range = cidrsubnet(var.serviceCIDR, var.servicenewbits, 7)
  }]
}

resource "google_compute_subnetwork" "cork" {
  name                     = "cork"
  region                   = "us-east1"
  network                  = google_compute_network.newVPC.self_link
  ip_cidr_range            = cidrsubnet(var.ipCIDR, var.newbits, 3)
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "galwaySubnet" {
  name                     = "galway"
  region                   = "us-central1"
  network                  = google_compute_network.newVPC.self_link
  ip_cidr_range            = cidrsubnet(var.ipCIDR, var.newbits, 4)
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "sligoSubnet" {
  name                     = "sligo"
  region                   = "us-west1"
  network                  = google_compute_network.newVPC.self_link
  ip_cidr_range            = cidrsubnet(var.ipCIDR, var.newbits, 5)
  private_ip_google_access = true
}

##Create firewall rules

resource "google_compute_firewall" "allow-web-traffic" {
  name    = "allow-web-traffic"
  network = google_compute_network.newVPC.self_link

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

resource "google_compute_firewall" "bastion-ssh" {
  name    = "bastion-ssh"
  network = google_compute_network.newVPC.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion"]
}

resource "google_compute_firewall" "allow-internal" {
  name    = "allow-internal"
  network = google_compute_network.newVPC.self_link

  allow {
    protocol = "all"
  }

  source_ranges = ["192.168.0.0/16", "10.0.0.0/8"]
}
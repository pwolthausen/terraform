##Create network, subnets, and firewall rules
resource "google_compute_network" "newVPC" {
  name                    = "${var.projectID}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "newSubnets" {
  name                     = "${var.projectID}-${var.region1}"
  region                   = "${var.region1}"
  network                  = "${google_compute_network.newVPC.self_link}"
  ip_cidr_range            = "${var.ipCIDR[0]}"
  private_ip_google_access = true

  #Block for secondary ranges if required.
  ##Should always be used if creating a GKE cluster
  secondary_ip_range = [
    {
      range_name    = "pod-cidr"
      ip_cidr_range = "${var.podCIDR}"
    },
    {
      range_name    = "service-cidr"
      ip_cidr_range = "${var.serviceCIDR[0]}"
    },
  ] 
}

resource "google_compute_firewall" "allow-internal" {
  name          = "allow-internal-demo"
  network       = "${google_compute_network.newVPC.self_link}"
  source_ranges = "${concat(var.ipCIDR, var.serviceCIDR, var.podCIDR)}"
  description   = "Rule to allow all traffic within the GCP VPC"

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "bastion-access" {
  name          = "bastion-access"
  network       = "${google_compute_network.newVPC.self_link}"
  description   = "Allow RDP and/or SSH traffic to the bastion"
  source_ranges = "${var.bastionSourceIP}"
  target_tags   = ["bastion"]

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }
}

resource "google_compute_firewall" "special-access" {
  name          = "special-access"
  network       = "${google_compute_network.newVPC.self_link}"
  source_ranges = "${var.specialIPs}"
  description   = "Allow access for special users"

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "allow-onprem" {
  name          = "allow-onprem"
  network       = "${google_compute_network.newVPC.self_link}"
  source_ranges = ["${var.onpremCIDR}"]
  description   = "Allows access from on-prem connections over the VPN"

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "allow-web-traffic" {
  name    = "allow-web-traffic-demo"
  network = "${google_compute_network.newVPC.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

resource "google_compute_firewall" "lb_health_checks" {
  name          = "lb-health-checks"
  network       = "${google_compute_network.newVPC.self_link}"
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

##Configure VPN
resource "google_compute_vpn_gateway" "vpn_gateway" {
  name    = "vpn-1"
  network = "${google_compute_network.newVPC.self_link}"
  region  = "${var.region1}"
}

resource "google_compute_address" "vpn_static_ip" {
  name   = "vpn-1-static-ip"
  region = "${var.region1}"
}

resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = "${google_compute_address.vpn_static_ip.address}"
  target      = "${google_compute_vpn_gateway.vpn_gateway.self_link}"
  region      = "${var.region1}"
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = "${google_compute_address.vpn_static_ip.address}"
  target      = "${google_compute_vpn_gateway.vpn_gateway.self_link}"
  region      = "${var.region1}"
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = "${google_compute_address.vpn_static_ip.address}"
  target      = "${google_compute_vpn_gateway.vpn_gateway.self_link}"
  region      = "${var.region1}"
}

resource "google_compute_vpn_tunnel" "tunnel1" {
  name          = "tunnel1"
  peer_ip       = "${var.onprem_VPN_IP}"
  shared_secret = "${var.vpn-secret}"

  target_vpn_gateway      = "${google_compute_vpn_gateway.vpn_gateway.self_link}"
  local_traffic_selector  = "${var.ipCIDR}"
  remote_traffic_selector = ["${var.onpremCIDR}"]

  depends_on = [
    "google_compute_forwarding_rule.fr_esp",
    "google_compute_forwarding_rule.fr_udp500",
    "google_compute_forwarding_rule.fr_udp4500"
  ]
}

resource "google_compute_route" "onprem_route" {
  name       = "on-prem"
  network    = "${google_compute_network.newVPC.name}"
  dest_range = "${var.onpremCIDR}"
  priority   = 1000

  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.tunnel1.self_link}"
}

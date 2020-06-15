resource "google_sql_database_instance" "backend_db" {
  name             = "myDatabase"
  region           = "${var.region1}"
  database_version = "${var.db_version}"
  root_password    = "${var.db_root_password}"

  settings {
    tier              = "${var.db_tier}"
    availability_type = "${var.db_availability}"
    labels {
      env = "${var.servers1_env}"
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = "${google_compute_network.newVPC.id}"
    }
  }
}

resource "google_compute_global_address" "db_private_ip" {
  provider = google-beta

  name          = "db-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = "${google_compute_network.newVPC.id}"
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = "${google_compute_network.private_network.id}"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["${google_compute_global_address.db_private_ip.name}"]
}

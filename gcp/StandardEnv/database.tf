resource "google_service_networking_connection" "private_vpc_connection" {

  network                 = "${google_compute_network.newVPC.id}"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["${google_compute_global_address.db_private_ip.name}"]
}

resource "google_sql_database_instance" "backend_db" {
  name             = "my-database-1"
  region           = "${var.region1}"
  database_version = "${var.db_version}"
  # root_password    = "${var.db_root_password}"

  settings {
    tier              = "${var.db_tier}"
    availability_type = "${var.db_availability}"
    user_labels = {
      env = "${var.servers1_env}"
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = "${google_compute_network.newVPC.id}"
    }
  }
  depends_on = [
    "google_service_networking_connection.private_vpc_connection"
  ]
}

## Create private service connection
resource "google_compute_global_address" "db_private_ip" {

  name          = "db-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = "${google_compute_network.newVPC.id}"
}

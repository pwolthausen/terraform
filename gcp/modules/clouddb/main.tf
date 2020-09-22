## Create private service connection
resource "google_compute_global_address" "db_private_ip" {

  name          = "db-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = var.networkid
}
resource "google_service_networking_connection" "private_vpc_connection" {

  network                 = var.networkid
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["${google_compute_global_address.db_private_ip.name}"]
}

resource "google_sql_database_instance" "backend_db" {
  name             = var.name
  region           = var.region
  database_version = var.db_version
  # root_password    = "${var.db_root_password}"

  settings {
    tier              = var.db_tier
    availability_type = var.db_availability

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.networkid
    }
  }
  depends_on = [
    "google_service_networking_connection.private_vpc_connection"
  ]
}

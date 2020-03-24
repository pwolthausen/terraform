provider "google-beta" {
  project     = "${var.projectID}"
  credentials = "${file("credentials.json")}"
}

resource "google_sql_database_instance" "MSSQL" {
  name             = "MSSQL_database"
  region           = "${var.region}"
  database_version = "${var.db_version}"
  root_password    = "${var.db_root_password}"

  settings {
    tier = ""

    ip_configuration {
      ipv4_enabled    = false
      private_network = "${google_compute_network.newVPC}"
    }
  }
}

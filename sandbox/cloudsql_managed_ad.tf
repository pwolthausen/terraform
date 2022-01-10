resource "google_sql_database_instance" "app_db" {
  count    = 2
  provider = google-beta
  project  = var.project_id

  name   = format("p-appdb-%02d-usc1", count.index + 5)
  region = "us-central1"
  // https://cloud.google.com/sql/docs/db-versions
  database_version = "SQLSERVER_2019_WEB"

  root_password = "p@ssw0rd"

  deletion_protection = true

  settings {
    tier              = "db-custom-2-13312"
    availability_type = "REGIONAL"
    disk_type         = "PD_SSD"
    disk_autoresize   = true
    ip_configuration {
      ipv4_enabled    = length(var.sql_auth_networks) == 0 ? false : true
      private_network = "projects/pwolthausen-sandbox/global/networks/cartdotcom"

      dynamic "authorized_networks" {
        for_each = var.sql_auth_networks
        iterator = cidr

        content {
          name  = cidr.key
          value = cidr.value
        }
      }
    }
    backup_configuration {
      enabled    = true
      start_time = "03:00"
      location   = "us"

      backup_retention_settings {
        retained_backups = "14"
      }
    }
    maintenance_window {
      day          = 6
      hour         = 9
      update_track = "stable"
    }
  }
}

resource "null_resource" "managed_ad_join" {
  count = 2
  provisioner "local-exec" {
    command = "gcloud beta sql instances patch ${google_sql_database_instance.app_db[count.index].name} --active-directory-domain=wolthausen.ca"
  }
  triggers = {
    version = google_sql_database_instance.app_db[count.index].settings.version
  }
}
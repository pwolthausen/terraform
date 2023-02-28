# resource "google_compute_global_address" "private_ip_address" {
#   provider = google-beta

#   name          = "postgres-ip-address"
#   purpose       = "VPC_PEERING"
#   address_type  = "INTERNAL"
#   prefix_length = 16
#   network       = module.core_network.network_id
# }

# resource "google_service_networking_connection" "private_vpc_connection" {
#   provider = google-beta

#   network                 = module.core_network.network_id
#   service                 = "servicenetworking.googleapis.com"
#   reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
# }

# resource "random_id" "db_name_suffix" {
#   byte_length = 4
# }

# resource "google_sql_database_instance" "instance" {
#   provider = google-beta

#   name             = "ory-test-${random_id.db_name_suffix.hex}"
#   region           = var.region
#   database_version = "POSTGRES_14"

#   depends_on          = [google_service_networking_connection.private_vpc_connection]
#   deletion_protection = false

#   settings {
#     tier = "db-f1-micro"
#     ip_configuration {
#       ipv4_enabled    = false
#       private_network = module.core_network.network_id
#     }
#   }
# }

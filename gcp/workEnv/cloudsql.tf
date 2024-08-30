# module "database" {
#   source                      = "git@github.com:cloudops/cloudmc-infra-module-sql.git?ref=feat-sql20.0.0-add-user-flexibility"
#   project_id                  = var.project_id
#   region_id                   = "northamerica-northeast1"
#   zone_id                     = "northamerica-northeast1-a"
#   env                         = "dev"
#   vpc_network                 = "vpc-pw-core"
#   user_host_cidr              = "192.168.0.0/23"
#   authorized_networks         = [{ name = "patty", value = "${var.my_ip}/32" }]
#   cloudsql_private_range_name = module.private_service_access.google_compute_global_address_name
#   availability_type           = "ZONAL"
# }

# resource "google_sql_user" "iam_group_user" {
#   project  = var.project_id
#   name     = "ops-cmcaas-primes@cloudops.com"
#   instance = " cloudmc-saas-sql-dev-nane1"
#   type     = "CLOUD_IAM_GROUP"
# }

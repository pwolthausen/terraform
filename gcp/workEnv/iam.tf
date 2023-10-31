# module "iam" {
#   source = "git@github.com:cloudops/cloudmc-infra-module-iam?ref=1.0.3"

#   project_id  = var.project_id
#   apis        = []
#   vpc_regions = [var.region]

#   prj_iam_bindings    = var.prj_iam_bindings
#   custom_roles        = var.custom_roles
#   workload_identities = var.workload_identities
#   service_accounts    = var.service_accounts
# }

# /**
#  * Copyright 2021 Google LLC
#  *
#  * Licensed under the Apache License, Version 2.0 (the "License");
#  * you may not use this file except in compliance with the License.
#  * You may obtain a copy of the License at
#  *
#  *      http://www.apache.org/licenses/LICENSE-2.0
#  *
#  * Unless required by applicable law or agreed to in writing, software
#  * distributed under the License is distributed on an "AS IS" BASIS,
#  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  * See the License for the specific language governing permissions and
#  * limitations under the License.
#  */
#
# resource "google_folder" "shared" {
#   display_name = "${var.folder_prefix}-shared"
#   parent       = local.parent
# }
#
# /******************************************
#   Project for Org Networking
# *****************************************/
#
# module "org_networks" {
#   source                  = "terraform-google-modules/project-factory/google"
#   version                 = "~> 11.1"
#   random_project_id       = "true"
#   default_service_account = "deprivilege"
#   name                    = "network-hub"
#   org_id                  = var.org_id
#   billing_account         = var.billing_account
#   folder_id               = google_folder.shared.id
#   activate_apis           = ["billingbudgets.googleapis.com", "compute.googleapis.com", "logging.googleapis.com", "servicenetworking.googleapis.com"]
#
#   labels = {
#     environment      = "shared"
#     application_name = "org-networks"
#     primary_contact  = "example1"
#   }
# }
#
# module "org_networks_iam" {
#   for_each = var.prj_org_networks_iam
#
#   source     = "../modules/prj_iam_bindings"
#   roles      = each.value.roles
#   project_id = module.org_networks.project_id
#   group      = each.key
# }
#
# /******************************************
#   Project for Org Security
# *****************************************/
#
# module "org_security" {
#   source                  = "terraform-google-modules/project-factory/google"
#   version                 = "~> 11.1"
#   random_project_id       = "true"
#   default_service_account = "deprivilege"
#   name                    = "org-security"
#   org_id                  = var.org_id
#   billing_account         = var.billing_account
#   folder_id               = google_folder.shared.id
#   activate_apis           = ["logging.googleapis.com", "secretmanager.googleapis.com", "bigquery.googleapis.com"]
#
#   labels = {
#     environment      = "shared"
#     application_name = "org-security"
#     primary_contact  = "example1"
#   }
# }
#
# module "org_security_iam" {
#   for_each = var.prj_org_security_iam
#
#   source     = "../modules/prj_iam_bindings"
#   roles      = each.value.roles
#   project_id = module.org_security.project_id
#   group      = each.key
# }
#
# /******************************************
#   Projects for Operations (logging / monitoring)
# *****************************************/
#
# module "operations_project" {
#   source                      = "terraform-google-modules/project-factory/google"
#   version                     = "~> 10.1"
#   random_project_id           = "true"
#   # impersonate_service_account = var.terraform_service_account
#   name                        = "org-operations"
#   org_id                      = var.org_id
#   billing_account             = var.billing_account
#   folder_id                   = data.google_active_folder.devops.id
#   disable_services_on_destroy = false
#   activate_apis = [
#     "logging.googleapis.com",
#     "monitoring.googleapis.com",
#     "bigquery.googleapis.com"
#   ]
#
#   labels = {
#     environment      = "devops"
#     application_name = "org-operations"
#     primary_contact  = "example"
#   }
# }
#
# module "org_ops_iam" {
#   for_each = var.prj_org_ops_iam
#
#   source     = "../modules/prj_iam_bindings"
#   roles      = each.value.roles
#   project_id = module.operations_project.project_id
#   group      = each.key
# }

/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "google_folder" "department" {
  display_name = "${var.folder_prefix}-${var.department}"
  parent       = var.parent
}

module "department_fldr_iam_bindings" {
  for_each = var.department_fldr_iam_bindings == null ? {} : var.department_fldr_iam_bindings

  source    = "../../modules/fldr_iam_bindings"
  roles     = each.value.roles
  folder_id = google_folder.department.id
  group     = each.key
}

resource "google_folder" "department_prod" {
  display_name = "${var.folder_prefix}-${var.department}-prod"
  parent       = google_folder.department.id
}

module "department_prod_fldr_iam_bindings" {
  for_each = var.department_prod_fldr_iam_bindings == null ? {} : var.department_prod_fldr_iam_bindings

  source    = "../../modules/fldr_iam_bindings"
  roles     = each.value.roles
  folder_id = google_folder.department_prod.id
  group     = each.key
}

resource "google_folder" "department_dev" {
  display_name = "${var.folder_prefix}-${var.department}-dev"
  parent       = google_folder.department.id
}

module "department_dev_fldr_iam_bindings" {
  for_each = var.department_dev_fldr_iam_bindings == null ? {} : var.department_dev_fldr_iam_bindings

  source    = "../../modules/fldr_iam_bindings"
  roles     = each.value.roles
  folder_id = google_folder.department_dev.id
  group     = each.key
}

resource "google_folder" "department_test" {
  display_name = "${var.folder_prefix}-${var.department}-test"
  parent       = google_folder.department.id
}

module "department_test_fldr_iam_bindings" {
  for_each = var.department_test_fldr_iam_bindings == null ? {} : var.department_test_fldr_iam_bindings

  source    = "../../modules/fldr_iam_bindings"
  roles     = each.value.roles
  folder_id = google_folder.department_test.id
  group     = each.key
}

resource "google_folder" "department_stage" {
  display_name = "${var.folder_prefix}-${var.department}-stage"
  parent       = google_folder.department.id
}

module "department_stage_fldr_iam_bindings" {
  for_each = var.department_stage_fldr_iam_bindings == null ? {} : var.department_stage_fldr_iam_bindings

  source    = "../../modules/fldr_iam_bindings"
  roles     = each.value.roles
  folder_id = google_folder.department_stage.id
  group     = each.key
}

/******************************************
  department shared resources projects
*****************************************/

# module "department_secrets_project" {
#   source                      = "terraform-google-modules/project-factory/google"
#   version                     = "~> 10.1"
#   random_project_id           = "true"
#   impersonate_service_account = var.terraform_service_account
#   name                        = "${var.department}-secrets"
#   org_id                      = var.org_id
#   billing_account             = var.billing_account
#   folder_id                   = google_folder.department.id
#   disable_services_on_destroy = false
#   activate_apis = [
#     "logging.googleapis.com",
#     "monitoring.googleapis.com",
#     "secretmanager.googleapis.com"
#   ]
#
#   labels = {
#     environment      = "secrets"
#     application_name = "department-secrets"
#     primary_contact  = "example"
#   }
# }
#
# variable "department_prj_secrets_iam" {
#   type = map(object({
#     roles = list(string)
#   }))
#   default = {}
# }
#
# module "department_secrets_iam" {
#   for_each = var.department_prj_secrets_iam
#
#   source     = "../modules/prj_iam_bindings"
#   roles      = each.value.roles
#   project_id = module.operations_project.project_id
#   group      = each.key
# }

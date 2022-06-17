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

data "google_active_folder" "department" {
  display_name = "${var.folder_prefix}-${var.department}"
  parent       = var.parent_id
}
data "google_active_folder" "environment" {
  for_each     = toset(var.environments)
  display_name = "${var.folder_prefix}-${var.department}-${each.key}"
  parent       = data.google_active_folder.department.id
}
#
# data "google_projects" "org_network_project" {
#   filter = "parent.id:${var.org_id} labels.application_name=org-networks  lifecycleState=ACTIVE"
# }
#
# data "google_project" "org_network_project" {
#   project_id = data.google_projects.org_network_project.projects[0].project_id
# }
#
# data "google_compute_network" "network" {
#   for_each = toset(var.environments)
#   project  = data.google_projects.org_network_project.projects[0].project_id
#   name     = "vpc-shared-${each.key}"
# }

module "project" {
  for_each          = toset(var.environments)
  source            = "terraform-google-modules/project-factory/google"
  version           = "~> 11.1"
  random_project_id = "true"
  name              = "${each.key}-${var.application_name}"
  org_id            = var.org_id
  billing_account   = var.billing_account
  folder_id         = data.google_active_folder.environment[each.key].id

  activate_apis = ["compute.googleapis.com", "logging.googleapis.com"]

  auto_create_network = false
  # svpc_host_project_id = data.google_project.org_network_project.project_id
  # shared_vpc_subnets   = data.google_compute_network.network[each.key].subnetworks_self_links

  labels = {
    environment      = each.key
    application_name = var.application_name
    primary_contact  = var.primary_contact
  }
}

module "prj_prod_iam" {
  for_each = contains(var.environments, "prod") ? var.prj_prod_iam : {}

  source     = "../../modules/prj_iam_bindings"
  roles      = each.value.roles
  project_id = module.project["prod"].project_id
  group      = each.key
}

module "prj_stage_iam" {
  for_each = contains(var.environments, "stage") ? var.prj_stage_iam : {}

  source     = "../../modules/prj_iam_bindings"
  roles      = each.value.roles
  project_id = module.project["stage"].project_id
  group      = each.key
}

module "prj_test_iam" {
  for_each = contains(var.environments, "test") ? var.prj_test_iam : {}

  source     = "../../modules/prj_iam_bindings"
  roles      = each.value.roles
  project_id = module.project["test"].project_id
  group      = each.key
}

module "prj_dev_iam" {
  for_each = contains(var.environments, "dev") ? var.prj_dev_iam : {}

  source     = "../../modules/prj_iam_bindings"
  roles      = each.value.roles
  project_id = module.project["dev"].project_id
  group      = each.key
}

module "prj_qa_iam" {
  for_each = contains(var.environments, "qa") ? var.prj_qa_iam : {}

  source     = "../../modules/prj_iam_bindings"
  roles      = each.value.roles
  project_id = module.project["qa"].project_id
  group      = each.key
}

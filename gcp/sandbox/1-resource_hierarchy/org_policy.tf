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
# ## Org policies must be discussed with clients before enabling any.
#
# locals {
#   organization_id = var.parent_folder != "" ? null : var.org_id
#   folder_id       = var.parent_folder != "" ? var.parent_folder : null
#   policy_for      = var.parent_folder != "" ? "folder" : "organization"
# }
#
#
# /******************************************
#   Compute org policies
# *******************************************/
#
# module "org_disable_nested_virtualization" {
#   source          = "terraform-google-modules/org-policy/google"
#   version         = "~> 5.0"
#   organization_id = local.organization_id
#   folder_id       = local.folder_id
#   policy_for      = local.policy_for
#   policy_type     = "boolean"
#   enforce         = "true"
#   constraint      = "constraints/compute.disableNestedVirtualization"
# }
#
# module "org_disable_serial_port_access" {
#   source          = "terraform-google-modules/org-policy/google"
#   version         = "~> 5.0"
#   organization_id = local.organization_id
#   folder_id       = local.folder_id
#   policy_for      = local.policy_for
#   policy_type     = "boolean"
#   enforce         = "true"
#   constraint      = "constraints/compute.disableSerialPortAccess"
# }
#
# module "org_compute_disable_guest_attributes_access" {
#   source          = "terraform-google-modules/org-policy/google"
#   version         = "~> 5.0"
#   organization_id = local.organization_id
#   folder_id       = local.folder_id
#   policy_for      = local.policy_for
#   policy_type     = "boolean"
#   enforce         = "true"
#   constraint      = "constraints/compute.disableGuestAttributesAccess"
# }
#
# module "org_vm_external_ip_access" {
#   source            = "terraform-google-modules/org-policy/google"
#   version           = "~> 5.0"
#   organization_id   = local.organization_id
#   folder_id         = local.folder_id
#   policy_for        = local.policy_for
#   policy_type       = "list"
#   allow             = var.vmexternalipaccess
#   allow_list_length = length(var.vmexternalipaccess)
#   enforce           = "true"
#   constraint        = "constraints/compute.vmExternalIpAccess"
# }
#
# #module "org_trusted_image_projects" {
# #  source          = "terraform-google-modules/org-policy/google"
# #  version         = "~> 5.0"
# #  organization_id = local.organization_id
# #  folder_id       = local.folder_id
# #  policy_for      = local.policy_for
# #  policy_type     = "list"
# #  allow           = var.trustedImageProjects
# #  enforce         = "true"
# #  constraint      = "constraints/compute.trustedImageProjects"
# #}
#
# module "org_shared_require_os_login" {
#   source          = "terraform-google-modules/org-policy/google"
#   version         = "~> 5.0"
#   organization_id = local.organization_id
#   folder_id       = local.folder_id
#   policy_for      = local.policy_for
#   policy_type     = "boolean"
#   enforce         = "true"
#   constraint      = "constraints/compute.requireOsLogin"
# }
#
# module "org_resource_locations" {
#   source            = "terraform-google-modules/org-policy/google"
#   version           = "~> 5.0"
#   organization_id   = local.organization_id
#   folder_id         = local.folder_id
#   policy_for        = local.policy_for
#   policy_type       = "list"
#   allow             = var.resourceLocations
#   allow_list_length = length(var.resourceLocations)
#   constraint        = "constraints/gcp.resourceLocations"
# }
#
# /******************************************
#   Network Constraints
# *******************************************/
#
# module "org_skip_default_network" {
#   source          = "terraform-google-modules/org-policy/google"
#   version         = "~> 5.0"
#   organization_id = local.organization_id
#   folder_id       = local.folder_id
#   policy_for      = local.policy_for
#   policy_type     = "boolean"
#   enforce         = "true"
#   constraint      = "constraints/compute.skipDefaultNetworkCreation"
# }
#
# module "org_shared_vpc_lien_removal" {
#   source          = "terraform-google-modules/org-policy/google"
#   version         = "~> 5.0"
#   organization_id = local.organization_id
#   folder_id       = local.folder_id
#   policy_for      = local.policy_for
#   policy_type     = "boolean"
#   enforce         = "true"
#   constraint      = "constraints/compute.restrictXpnProjectLienRemoval"
# }
#
# # This is recommended for advanced
# #module "org_restrict_shared_vpc_subnetworks" {
# #  source          = "terraform-google-modules/org-policy/google"
# #  version         = "~> 5.0"
# #  organization_id = local.organization_id
# #  folder_id       = local.folder_id
# #  policy_for      = local.policy_for
# #  policy_type     = "list"
# #  allow             = var.restrictSharedVpcSubnetworks
# #  allow_list_length = length(var.restrictSharedVpcSubnetwork)
# #  constraint      = "constraints/compute.restrictSharedVpcSubnetworks"
# #}
#
# module "org_restrict_vpc_peering" {
#   source            = "terraform-google-modules/org-policy/google"
#   version           = "~> 5.0"
#   organization_id   = local.organization_id
#   folder_id         = local.folder_id
#   policy_for        = local.policy_for
#   policy_type       = "list"
#   allow             = var.restrictVpcPeering
#   allow_list_length = length(var.restrictVpcPeering)
#   constraint        = "constraints/compute.restrictVpcPeering"
# }
#
# /******************************************
#   Cloud SQL
# *******************************************/
#
# module "org_cloudsql_external_ip_access" {
#   source          = "terraform-google-modules/org-policy/google"
#   version         = "~> 5.0"
#   organization_id = local.organization_id
#   folder_id       = local.folder_id
#   policy_for      = local.policy_for
#   policy_type     = "boolean"
#   enforce         = "true"
#   constraint      = "constraints/sql.restrictPublicIp"
# }
#
# /******************************************
#   IAM
# *******************************************/
#
# module "org_domain_restricted_sharing" {
#   source           = "terraform-google-modules/org-policy/google//modules/domain_restricted_sharing"
#   version          = "~> 5.0"
#   organization_id  = local.organization_id
#   folder_id        = local.folder_id
#   policy_for       = local.policy_for
#   domains_to_allow = var.domains_to_allow
# }
#
# module "org_disable_sa_key_creation" {
#   source          = "terraform-google-modules/org-policy/google"
#   version         = "~> 5.0"
#   organization_id = local.organization_id
#   folder_id       = local.folder_id
#   policy_for      = local.policy_for
#   policy_type     = "boolean"
#   enforce         = "true"
#   constraint      = "constraints/iam.disableServiceAccountKeyCreation"
# }
#
# module "org_disable_automatic_iam_grants_on_default_service_accounts" {
#   source          = "terraform-google-modules/org-policy/google"
#   version         = "~> 5.0"
#   organization_id = local.organization_id
#   folder_id       = local.folder_id
#   policy_for      = local.policy_for
#   policy_type     = "boolean"
#   enforce         = "true"
#   constraint      = "constraints/iam.automaticIamGrantsForDefaultServiceAccounts"
# }
#
# /******************************************
#   Storage
# *******************************************/
#
# module "org_enforce_bucket_level_access" {
#   source          = "terraform-google-modules/org-policy/google"
#   version         = "~> 5.0"
#   organization_id = local.organization_id
#   folder_id       = local.folder_id
#   policy_for      = local.policy_for
#   policy_type     = "boolean"
#   enforce         = "true"
#   constraint      = "constraints/storage.uniformBucketLevelAccess"
# }
#
# module "org_enforce_bucket_public_access_prevention" {
#   source          = "terraform-google-modules/org-policy/google"
#   version         = "~> 5.0"
#   organization_id = local.organization_id
#   folder_id       = local.folder_id
#   policy_for      = local.policy_for
#   policy_type     = "boolean"
#   enforce         = "true"
#   constraint      = "constraints/storage.publicAccessPrevention"
# }
#
# /******************************************
#   Access Context Manager Policy
# *******************************************/
#
# resource "google_access_context_manager_access_policy" "access_policy" {
#   count  = var.create_access_context_manager_access_policy ? 1 : 0
#   parent = "organizations/${var.org_id}"
#   title  = "default policy"
# }

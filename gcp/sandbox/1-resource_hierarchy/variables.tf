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

variable "org_id" {
  description = "The organization id for the associated services"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate this project with"
  type        = string
}

variable "terraform_service_account" {
  description = "Service account email of the account to impersonate to run Terraform."
  type        = string
}

variable "parent_folder" {
  description = "Optional - for an organization with existing projects or for development/validation. It will place all the example foundation resources under the provided folder instead of the root organization. The value is the numeric folder ID. The folder must already exist. Must be the same value used in previous step."
  type        = string
  default     = ""
}

variable "folder_prefix" {
  description = "Name prefix to use for folders created. Should be the same in all steps."
  type        = string
  default     = "fldr"
}

/******************************************
  Department Folders
*****************************************/

variable "departments" {
  type = map(object({
    dept_fldr_iam_bindings = optional(map(object({
      roles = list(string)
    }))),
    prod_fldr_iam_bindings = optional(map(object({
      roles = list(string)
    }))),
    dev_fldr_iam_bindings = optional(map(object({
      roles = list(string)
    }))),
    test_fldr_iam_bindingss = optional(map(object({
      roles = list(string)
    }))),
    stage_fldr_iam_bindings = optional(map(object({
      roles = list(string)
    }))),
  }))
  default = {}
}

/******************************************
  IAM
*****************************************/

variable "org_iam_bindings" {
  type = map(object({
    roles = list(string)
  }))
  default = {}
}


variable "shared_fldr_iam_bindings" {
  type = map(object({
    roles = list(string)
  }))
  default = {}
}

variable "department_fldr_iam_bindings" {
  type = map(object({
    roles = list(string)
  }))
  default = {}
}

variable "qa_fldr_iam_bindings" {
  type = map(object({
    roles = list(string)
  }))
  default = {}
}

variable "dev_fldr_iam_bindings" {
  type = map(object({
    roles = list(string)
  }))
  default = {}
}


variable "prj_org_networks_iam" {
  type = map(object({
    roles = list(string)
  }))
  default = {}
}

variable "prj_org_security_iam" {
  type = map(object({
    roles = list(string)
  }))
  default = {}
}

variable "prj_org_ops_iam" {
  type = map(object({
    roles = list(string)
  }))
  default = {}
}
/******************************************
  Log exports and syncs
*****************************************/

variable "log_export_storage_retention_policy" {
  description = "Configuration of the bucket's data retention policy for how long object in the bucket should be retained."
  type = object({
    is_locked             = bool
    retention_period_days = number
  })
  default = null
}

variable "data_access_logs_enabled" {
  description = "Enable Data Access logs of types DATA_READ, DATA_WRITE and ADMIN_READ for all GCP services. Enabling Data Access logs might result in your organization being charged for the additional logs usage. See https://cloud.google.com/logging/docs/audit#data-access"
  type        = bool
  default     = true
}

variable "log_export_storage_location" {
  description = "The location of the storage bucket used to export logs."
  type        = string
  default     = "US"
}

variable "log_export_storage_force_destroy" {
  description = "(Optional) If set to true, delete all contents when destroying the resource; otherwise, destroying the resource will fail if contents are present."
  type        = bool
  default     = false
}

variable "log_export_storage_versioning" {
  description = "(Optional) Toggles bucket versioning, ability to retain a non-current object version when the live object version gets replaced or deleted."
  type        = bool
  default     = false
}

variable "audit_logs_table_delete_contents_on_destroy" {
  description = "(Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present."
  type        = bool
  default     = false
}

variable "audit_logs_table_expiration_days" {
  description = "Period before tables expire for all audit logs in milliseconds. Default is 30 days."
  type        = number
  default     = 30
}

/******************************************
  Org Policy
*****************************************/

variable "enable_os_login_policy" {
  description = "Enable OS Login Organization Policy."
  type        = bool
  default     = false
}

variable "vmexternalipaccess" {
  type        = list(any)
  default     = []
  description = "This list constraint defines the set of Compute Engine VM instances that are allowed to use external IP addresses"
}

variable "trustedImageProjects" {
  type        = list(any)
  default     = []
  description = "List of projects that can be used for image storage and disk instantiation for Compute Engine. List of publisher projects must be strings in the form: projects/PROJECT_ID."
}

variable "resourceLocations" {
  type        = list(any)
  default     = ["in:us-locations"]
  description = "List of allowed locations where GCP resources can be created. See https://cloud.google.com/resource-manager/docs/organization-policy/defining-locations for more details"
}

variable "restrictSharedVpcSubnetworks" {
  type        = list(any)
  default     = []
  description = "This list constraint defines the set of shared VPC subnetworks that eligible resources can use. This constraint does not apply to resources within the same project. By default, eligible resources can use any shared VPC subnetwork. The allowed/denied list of subnetworks must be specified in the form: under:organizations/ORGANIZATION_ID, under:folders/FOLDER_ID, under:projects/PROJECT_ID, or projects/PROJECT_ID/regions/REGION/subnetworks/SUBNETWORK-NAME"
}

variable "restrictVpcPeering" {
  type        = list(any)
  default     = []
  description = "This list constraint defines the set of VPC networks that are allowed to be peered with the VPC networks belonging to this project, folder, or organization. By default, a Network Admin for one network can peer with any other network. The allowed/denied list of networks must be identified in the form: under:organizations/ORGANIZATION_ID, under:folders/FOLDER_ID, under:projects/PROJECT_ID, or projects/PROJECT_ID/global/networks/NETWORK_NAME"
}

variable "domains_to_allow" {
  description = "The list of domains to allow users from in IAM. Used by Domain Restricted Sharing Organization Policy. Must include the domain of the organization you are deploying the foundation. To add other domains you must also grant access to these domains to the terraform service account used in the deploy."
  type        = list(string)
  default     = []
}

variable "create_access_context_manager_access_policy" {
  description = "Whether to create access context manager access policy"
  type        = bool
  default     = true
}

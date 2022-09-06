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

variable "department" {
  type = string
}

variable "applications" {
  type = map(object({
    primary_contact = string

    environments = optional(list(string))
    prj_prod_iam = optional(map(object({
      roles = list(string)
    }))),
    prj_stage_iam = optional(map(object({
      roles = list(string)
    }))),
    prj_test_iam = optional(map(object({
      roles = list(string)
    }))),
    prj_dev_iam = optional(map(object({
      roles = list(string)
    }))),
    prj_qa_iam = optional(map(object({
      roles = list(string)
    }))),
  }))
  default = {}
}

locals {
  applications = defaults(var.applications, {
    prj_prod_iam  = {}
    prj_stage_iam = {}
    prj_test_iam  = {}
    prj_dev_iam   = {}
    prj_qa_iam    = {}
  })
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

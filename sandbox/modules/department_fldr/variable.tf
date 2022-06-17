

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

variable "parent" {
  type        = string
  description = "parent id of the org or folder under whcih the department folders will be created"
}

variable "terraform_service_account" {
  description = "Service account email of the account to impersonate to run Terraform."
  type        = string
}

variable "folder_prefix" {
  description = "Name prefix to use for folders created. Should be the same in all steps."
  type        = string
  default     = "fldr"
}

variable "department_fldr_iam_bindings" {
  type = map(object({
    roles = list(string)
  }))
  default = {}
}

variable "department_prod_fldr_iam_bindings" {
  type = map(object({
    roles = list(string)
  }))
  default = {}
}

variable "department_dev_fldr_iam_bindings" {
  type = map(object({
    roles = list(string)
  }))
  default = {}
}

variable "department_test_fldr_iam_bindings" {
  type = map(object({
    roles = list(string)
  }))
  default = {}
}

variable "department_stage_fldr_iam_bindings" {
  type = map(object({
    roles = list(string)
  }))
  default = {}
}

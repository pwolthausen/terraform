
variable "org_id" {
  type = string
}

variable "parent_id" {
  type = string
}

variable "billing_account" {
  type = string
}

variable "department" {
  type = string
}

variable "application_name" {
  type = string
}

variable "primary_contact" {
  type = string
}

variable "environments" {
  type    = list(any)
  default = ["prod", "stage", "test", "dev"]
}

variable "folder_prefix" {
  description = "Name prefix to use for folders created. Should be the same in all steps."
  type        = string
  default     = "fldr"
}

variable "prj_prod_iam" {
  type = map(object({
    roles = list(string)
  }))
}

variable "prj_stage_iam" {
  type = map(object({
    roles = list(string)
  }))
}

variable "prj_test_iam" {
  type = map(object({
    roles = list(string)
  }))
}

variable "prj_dev_iam" {
  type = map(object({
    roles = list(string)
  }))
}

variable "prj_qa_iam" {
  type = map(object({
    roles = list(string)
  }))
}

output "project_ids" {
  value = { for k, v in module.project : k => v.project_id }
}

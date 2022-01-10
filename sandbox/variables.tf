variable "terraform_service_account" {
    type = string
}

variable "region" {
    type = string
}

variable "project_id" {
    type = string
}

variable "sql_auth_networks" {
  type    = map(any)
  default = {}
}
variable "terraform_service_account" {
    type = string
}

variable "region" {
    type = string
}

variable "project_id" {
    type = string
}

variable "name" {
    type = string
}

variable "sql_auth_networks" {
  type    = map(any)
  default = {}
}

variable "image" {
    type = string
    description = "URI of GCP image"
    default = "projects/debian-cloud/global/images/debian-10-buster-v20220118"
}

variable "labels" {
    type = map(any)
    default = {}
}

variable "machine_type" {
    type = string
    default = "e2-medium"
}

variable "subnet" {
    type = string
    default = prod
}

variable "domain_user" {
    type = string
    default = ""
}

variable "domain_password" {
    type = string
    default = ""
}
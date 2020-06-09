variable "projectID" {}
variable "region1" {}
variable "region2" {}
variable "zone1_1" {}
variable "zone1_2" {}
variable "zone2_1" {}
variable "zone2_2" {}
variable "demo_pub_key" {
  description = "public key to add as project wide metadata. This will alllow SSH as user automation to all linux instances"
}

variable "server_image_family" {}
variable "server_image_project" {}

variable "bastionIP" {
  default = "static IP being assigned to the bastion. The demo assumes the IP already exists"
}
variable "frontendIP" {
  default = "statis IP being assigned to the GLB for the frontends. Global IP must exist before running demo"
}
variable "backendIP" {
  default = "statis IP being assigned to the GLB for the backends. Global IP must exist before running demo"
}

variable "frontend1count" {}
variable "frontend2count" {}
variable "frontend3count" {}
variable "frontend4count" {}
variable "frontend_disk" {}
variable "frontend_machine_type" {}

variable "backend1count" {}
variable "backend2count" {}
variable "backend3count" {}
variable "backend4count" {}
variable "backend_disk" {}
variable "backend_machine_type" {}

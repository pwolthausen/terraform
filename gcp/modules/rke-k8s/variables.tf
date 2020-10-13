variable "cluster_name" {}
variable "network" {}
variable "subnet" {}
variable "image" {}
variable "ssh_key" {
  description = "public key to use for the RKE cluster"
}
variable "k8s_cni" {
  default = "canal"
}
variable "k8s_ingress" {
  default = "nginx"
}
variable "k8s_version" {
  default     = ""
  description = "the default will leave this field empty and will use the default version used by the rke version installed locally"
}
variable "zones" {
  type = list
}
variable "master_machine_type" {
  default = ""
}
variable "master_disk_size" {
  default = "100"
}
variable "worker_count" {
  default = "3"
}
variable "worker_machine_type" {}
variable "worker_disk_size" {
  default = "100"
}
variable "worker_st_count" {
  default = 0
}
variable "worker_st_machine_type" {}
variable "worker_st_disk_size" {}
variable "worker_st_data_disk_size" {}

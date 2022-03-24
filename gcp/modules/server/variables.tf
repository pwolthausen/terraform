##Required variables
variable "project_id" {}
variable "serverName" {}

variable "region" {
  type    = string
  default = "us-central1"
}
variable "zone" {
  type    = string
  default = "us-central1-c"
}
variable "machine_type" {
  type    = string
  default = "e2-medium"
}
variable "image" {
  type    = string
  default = "projects/debian-cloud/global/images/debian-11"
}

variable "tags" {
  description = "network tags assigned to the vm"
  type        = list(any)
  default     = [""]
}

variable "network" {
  type        = string
  description = "Network ID where the VM is being created (primary NIC only). This must be defined if using a non default network."
  default     = null
}
variable "subnet" {
  type        = string
  description = "Name of the subnet to use for the VM. This must be defined if using a non default subnet"
  default     = null
}
variable "internal_ip" {
  type        = string
  description = "Internal IP you want to assign to the server. The ip must not currently be in use"
  default     = null
}
variable "external_ip" {
  type        = bool
  description = "Whether or not to assign an IP external IP address to the server"
  default     = null
}

variable "root_disk_size" {
  type        = string
  description = "size of boot disk in GB"
}
variable "root_disk_type" {
  type        = string
  description = "Type of disk to use for the boot disk"
  default     = "pd-standard"
}
variable "addDisk" {
  type = map(object({
    size = number
    type = string
  }))
  description = "defines the additional disks"
  default     = {}
}

variable "snapshotPolicy" {
  type        = string
  description = "the name of a snapshot schedule policy in the same region"
  default     = null
}

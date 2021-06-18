##Required variables
variable "serverName" {}
variable "zone" {}
variable "machine_type" {}
variable "root_disk" {}
variable "snapshotPolicy" {
  description = "the name of a snapshot schedule policy in the same region"
}
variable "image" {}
variable "env" {}

variable "tags" {
  description = "network tags assigned to the vm"
  type        = list
  default     = [""]
}

variable "addDisk" {
  type = map(object({
    size = number
    type = string
  }))
  description = "defines the additional disks"
  default = {}
}

variable "network_if" {
  type = map(object({
    subnet      = string
    internal_ip = string
  }))
  description = "defines the network interfaces used for the instance. Must contain at least 1"
}

##Required variables
variable "serverName" {}
variable "zone" {}
variable "subnet" {}
variable "machine_type" {}
variable "disk1_size" {}
variable "snapshotPolicy" {
  description = "the name of a snapshot schedule policy in the same region"
}
variable "image" {}
variable "env" {
  description = "Must be either 'prod' or 'replica'"
  # validation {
  #   condition     = contains(["prod", "replica"], var.env)
  #   error_message = "Variable 'env' must be one of 'prod' or 'replica'"
  # }
}

##Optional variables
variable "tag" {
  description = "network tags assigned to the vm"
  type        = list
  default     = [""]
}

variable "addDisk" {
  description = "If set to true, will add a second disk to the instance"
  default     = false
}

variable "disk2_size" {
  description = "Can only be set if the 'addDisk' is set to true"
  default     = 100
}

variable "intip" {
  default = ""
}

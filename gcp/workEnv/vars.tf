variable "projectID" {}
variable "mypcip" {}

variable "ipCIDR" {
  type    = string
  default = "192.168.0.0/16"
}
variable "newbits" {
  type    = number
  default = 8
}

variable "podCIDR" {
  type    = string
  default = "10.0.0.0/11"
}
variable "podnewbits" {
  type    = number
  default = 3
}

variable "serviceCIDR" {
  type    = string
  default = "10.32.0.0/11"
}
variable "servicenewbits" {
  type    = number
  default = 9
}

variable "masterCIDR" {
  type    = string
  default = "10.46.0.0/24"
}
variable "masternewbits" {
  type    = number
  default = 4
}

variable "networkName" {
  default = "myvpc"
}
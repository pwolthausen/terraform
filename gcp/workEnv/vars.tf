variable "networkName" {}
variable "projectID" {}
variable "mypcip" {}

variable "ipCIDR" {
  type    = "list"
  default = ["192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24", "192.168.4.0/24", "192.168.5.0/24"]
}

variable "podCIDR" {
  type    = "list"
  default = ["10.0.0.0/14", "10.4.0.0/14", "10.8.0.0/14", "10.12.0.0/14", "10.20.0.0/14"]
}

variable "serviceCIDR" {
  type    = "list"
  default = ["10.16.0.0/20", "10.16.16.0/20", "10.16.32.0/20", "10.16.48.0/20", "10.16.64.0/20", "10.16.80.0/20", "10.16.96.0/20"]
}

variable "masterCIDR" {
  type    = "list"
  default = ["10.16.240.0/28", "10.16.240.16/28", "10.16.240.32/28", "10.16.240.48/28"]
}

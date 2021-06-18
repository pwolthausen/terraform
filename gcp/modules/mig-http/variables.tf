variable "name" {}
variable "zone" {}
variable "network" {}
variable "subnet" {}

variable "machine_type" {}
variable "image" {}
variable "disk_type" {
  default = "pd-standard"
}
variable "disk_size" {
  default = 20
}

variable "max_replicas" {
  default = 2
}
variable "min_replicas" {
  default = 2
}
variable "cooldown_preiod" {
  default = 60
}

variable "tags" {
  type    = list
  default = [""]
}

variable "hc" {
  description = "defines the health check for auto-healing"
  type = object({
    port     = number
    path     = string
    response = number
  })
  default = {
    port     = 80
    path     = "/"
    response = 200
  }
}
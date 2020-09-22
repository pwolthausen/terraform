variable "name" {}
variable "zone" {}
variable "network" {}
variable "subnet" {}
variable "replicas" {
  description = "number of replicas to maintain"
}
variable "machine_type" {}
variable "disk1_size" {
  default = "pd-standard"
}
variable "disk1_type" {
  default = 20
}
variable "disk2" {
  default     = false
  description = "Whether to have a second disk or not. Set to true to add 2nd disk"
}
variable "disk2_size" {
  default = 100
}
variable "disk2_type" {
  default = ""
}
variable "tags" {
  type    = list
  default = [""]
}

variable "hcpath" {
  default     = "/"
  description = "Path used by the health check for auto healing."
}
variable "hcport" {
  default     = 80
  description = "HTTP Port used for health check"
}
variable "response" {
  default = "200"
}

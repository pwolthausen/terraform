variable "name" {}
variable "zone" {}
variable "network" {}
variable "subnet" {}
variable "replicas" {
  description = "number of replicas to maintain"
}
variable "machine_type" {}
variable "image" {}
variable "disk1_type" {
  default = "pd-standard"
}
variable "disk1_size" {
  default = 10
}
variable "disk2" {
  default     = false
  description = "Whether to have a second disk or not. Set to true to add 2nd disk"
}
variable "disk2_size" {
  default = 100
}
variable "disk2_type" {
  default = "pd-standard"
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
  description = "Port used for TCP health check"
}
variable "response" {
  default = ""
}
variable "scopes" {
  type    = list
  default = ["logging-write"]
}

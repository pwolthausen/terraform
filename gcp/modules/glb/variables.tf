variable "name" {
  default     = "my-glb"
  description = "name of the HTTP(S) load balancer and all the components"
}
variable "group" {
  description = "selflink of the instance group to use as a backend"
}

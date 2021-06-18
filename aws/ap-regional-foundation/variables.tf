variable availability_zones {
  type = list
}
variable environment {}
variable region {}
variable access_ips {
  type        = list
  description = "list of IPs that have access to the bastion"
}

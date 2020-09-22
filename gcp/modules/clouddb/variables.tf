variable "name" {}
variable "networkid" {
  description = "Your VPC ID for the network that is being peered with the cloud db"
}
variable "region" {}
variable "db_version" {
  description = "CloudSQL version to use, please see documentation for available versions"
}
variable "db_tier" {
  description = "CloudSQL tier to use, please see documentation for available versions"
}
variable "db_availability" {
  default     = "ZONAL"
  description = "REGIONAL or ZONAL DB instance. Regional provides inter zone replication"
}

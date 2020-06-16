variable "profile" {
  description = "must match the name of the profile created for the aws CLI"
}
variable "region" {}
variable "zone" {}
variable "vpc_id" {}
variable "subnet_id" {}
##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
##Global EC2 settings such as SSH key, AMI and data paths
variable "elk_pub_ssh" {
  description = "public SSH key that will be used to connect to ELK nodes"
}
variable "ami_owners" {
  description = "owners of the AMI"
  type        = list
}
variable "elk_ami" {
  description = "the AMI to use to build the ELK cluster"
}
variable "data_dir" {
  description = "The path of the data device. This is OS specific"
  default     = "/dev/sdb"
}
##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
##Hot Data nodes
variable "hotdata_count" {
  default = "2"
}
variable "hotdata_machine_size" {
  description = "EC2 instance type to be used by data nodes"
}
variable "hotdata_data_disk_size" {}
variable "datahotip" {
  default     = ["10.30.32.10", "10.30.32.11", "10.30.32.12", "10.30.32.13"]
  description = "List of internal IP addresses to be assigned to hot data nodes. Must contain at least as many IPs as there will be nodes. IPs must be available in the existing subnets"
}
##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
##Master Nodes
variable "master_count" {
  default = "3"
}
variable "master_machine_size" {
  description = "EC2 instance type to be used by master nodes"
}
variable "master_data_disk_size" {}
variable "masterip" {
  default     = ["10.30.32.4", "10.30.32.5", "10.30.32.6", "10.30.32.7", "10.30.32.8", "10.30.32.9"]
  description = "List of internal IP addresses to be assigned to master nodes. Must contain at least as many IPs as there will be nodes. IPs must be available in the existing subnets"
}
##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
##Services such as kibana, logstash, apm
variable "kibana_machine_size" {
  default = "EC2 instance type to be used by kibana node"
}
variable "kibana_disk_size" {}
variable "apm_machine_size" {
  default = "EC2 instance type to be used by apm node"
}
variable "apm_disk_size" {}
variable "serviceip" {
  default = ["10.30.32.10", "10.30.32.11", "10.30.32.12", "10.30.32.13", "10.30.32.14", "10.30.32.15", "10.30.32.16"]
}
##+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
##Security settings
variable "bastion_security_group" {
  description = "A security group that is attached to the bastion host in the same VPC. Should be a security group that is only used by the bastion"
}

variable "all_security_group" {
  description = "Securiy group used by all of the hosts that are sending logs to elk. Should be a single group. If multiple groups are required, new variables will need to be added"
}

variable "protection" {
  description = "boolean value. If set to true, EC2 instances can't be terminated. Must be set to false before attempting to destroy"
}

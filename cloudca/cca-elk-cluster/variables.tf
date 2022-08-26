variable "automation_key" {
  description = "Public SSH key name to be used in the environment"
}
variable "environment_id" {}
variable "network_cidr" {
  description = "first 3 octets of cidr (10.0.0.0/24 = 10.0.0)"
}
variable "network_id" {
  description = "Network ID from Cloud.ca"
}
variable "dmznetwork_cidr" {
  description = "first 3 octets of DMZ cidr (10.0.0.0/24 = 10.0.0)"
}
variable "dmznetwork_id" {
  description = "DMZ Network ID from Cloud.ca"
}
variable "cca_image" {
  default     = "CentOS 7"
  description = "image used by elk nodes"
}
variable "disk_offering" {
  description = "Disk offering used by data disks for each node in cca"
  default     = "Economy, reduced resiliency (CloudOps)"
}
variable "cluster_name" {
  default = ""
}

variable "masters" {
  description = "number of master nodes in the cluster (4vcpu / 8GB memory)"
  default     = 3
}
variable "master_cpu" {
  default = 4
}
variable "master_memory" {
  default = 8192
}
variable "master_data_disk" {
  default = 100
}

variable "data_hot" {
  description = "number of hot data nodes (8vcpu / 16GB memory)"
  default     = 2
}
variable "data_hot_cpu" {
  default = 8
}
variable "data_hot_memory" {
  default = 16384
}
variable "data_hot_data_disk" {
  default = 1000
}

variable "data_warm" {
  description = "number of warm data nodes (8vcpu / 16GB memory)"
  default     = 0
}
variable "data_warm_cpu" {
  default = 8
}
variable "data_warm_memory" {
  default = 16384
}
variable "data_warm_data_disk" {
  default = 1000
}

variable "data_cold" {
  description = "number of cold data nodes (8vcpu / 16GB memory)"
  default     = 0
}
variable "data_cold_cpu" {
  default = 8
}
variable "data_cold_memory" {
  default = 16384
}
variable "data_cold_data_disk" {
  default = 1000
}

variable "kibana" {
  description = "number of kibana nodes (4vcpu / 8GB memory)"
  default     = 1
}
variable "kibana_cpu" {
  default = 8
}
variable "kibana_memory" {
  default = 16384
}

variable "logstash" {
  description = "number of logstash nodes (8vcpu / 16GB memory)"
  default     = 0
}
variable "logstash_cpu" {
  default = 8
}
variable "logstash_memory" {
  default = 16384
}
variable "logstash_data_disk" {
  default = 100
}

variable "ingest" {
  description = "number of ingest nodes (16vcpu / 16GB memory)"
  default     = 0
}
variable "ingest_cpu" {
  default = 16
}
variable "ingest_memory" {
  default = 16384
}
variable "ingest_data_disk" {
  default = 100
}

variable "coordination" {
  description = "number of coordination nodes (8vcpu / 16GB memory)"
  default     = 0
}
variable "coordination_cpu" {
  default = 8
}
variable "coordination_memory" {
  default = 16384
}
variable "coordination_data_disk" {
  default = 100
}

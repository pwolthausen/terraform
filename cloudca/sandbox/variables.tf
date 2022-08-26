variable "environment_id" {
  type        = string
  description = "Environment ID of the cloud.ca environment"
  default     = "cad9a761-bfed-4e6d-ab61-64118e65a713"
}

variable "public_key" {
  type        = string
  description = "Public ssh key to attach to the VM to allow SSH access"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1JTdHEY8g4RHkIXzL6k+YC1xtWXlqDcAP3wFYvy59YQyZWM23paL3WvBvroYVFsuPHEWNjaTiDJa6+67I0oP4Dbt9yGd3x9+PcMbq8opvYfzBl0cjd+mEbJUqhXlSZDLrAyFUpPd+w2dkieYnkGfC+8hx+/mhqiLJopbgdemfkeRVw8YjVcMtLZQeBLdHrSZXH38I8H0eHf20wRSBAFoNiIrrkFy8KqVcJhxWjyknTnkC3azgQygo35oNSeg4dL1xDo5PtZjm+U5sUAJSO9c2gP3V/sub8v8vTSHvGn0sRg/kTDFpiuK89J4dgszucf6PBvO77lCQfq9kpX0UNi9LBdLSI5j8QeUymnUGNYFAAkjE7/wnefqxt+RnHbETWeHTSAWiuOM22RgMMSfsMlWOjXm5ZA2agLDHEa/Lr8IXID7xP549CBYNiH4OE9wuF06EgQOxIPcmZ0hgfg9/IEevptftIuujfd6cqm/IX0oma8hwwWQfyFVbT0KmrJoALK4EeDizuzc2y9dez+dkB3cH8E6msNv45B0RsfOagG5/mJAd8VLJO+7++2FKZ5/qpm5xaeJitjaVdzHeOPlPVSvbIVLNwrr92PkH372NT8uD6qBT/MQD96++9+/dk21Cpa/J6RbE69VF1dM/YcitTasAq0ro58v25yJCh8FvbyeyuQ== pwolthausen@duncan"
}

variable "api_key" {
  type        = string
  description = "API key for cloud.ca"
}

output "ssh_ip" {
  value = cloudca_public_ip.nat_ip.ip_address
}

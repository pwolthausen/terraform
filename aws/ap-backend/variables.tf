variable name {}
variable region {}
variable environment {}
variable availability_zones {}
variable web_server_sg_id {}

variable aurora_db {
  type = object({
    engine_version                  = string
    db_cluster_parameter_group_name = string
    db_parameter_group_name         = string
    master_username                 = string
    master_password                 = string
    min_capacity                    = number
    max_capacity                    = number
  })
  description = "Contains settings for the Aurora serverless DB."
}

variable efs_storage {
  description = "Object containing informationa about the EFS storage"
  default = {
    performance_mode = "generalPurpose"
    throughput_mode  = "bursting"
  }
}

variable s3_acl {
  description = "S3 ACL permission"
  default     = "bucket-owner-full-control"
}

variable backup_retention_period {
  default = 14
}

variable apply_immediately {
  default = false
}

variable "snapshot_identifier" {
  default = ""
}

variable "deletion_protection" {
  default = true
}




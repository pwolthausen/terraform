variable host_zone {}
variable name {}
variable region {}
variable environment {}

variable web_server {
  type = object({
    instance_type = string
    release       = string
    disk_size     = number
  })
  description = <<-EOF
                Defines webserver
                instance_type is the AWS instance type to use
                release is the AMI version (will match the 'release' tag on the AMI)
                disk_size is the size of the boot disk in GB
                EOF
}

variable min_size {
    default = 1
}
variable max_size {
    default = 1
}
### Cloud.ca specific variables ###
variable "environment_id" {}
variable "image" {
  description = "Specify the image to use for the nodes, image must be available in the environment"
}
variable "s3_access_key" {
  description = "S3 credential for API access to cloud.ca s3 backend"
}
variable "s3_secret_key" {
  description = "S3 credential for API access to cloud.ca s3 backend"
}

### RKE cluster variables ###
variable "cluster_fqdn" {
  description = "added after the node name, used to make the nodes routable"
}
variable "cluster_name" {
  description = "Name of the cluster. Each node will include this name"
}
variable "k8s_version" {
  default     = ""
  description = "k8s version to use for the cluster. The default value is blank which will use the default version associated to the version of rke being used"
}
variable "k8s_ingress" {
  default     = "nginx"
  description = "k8s ingress controller to be installed using rke"
}
variable "k8s_cni" {
  default     = "canal"
  description = "CNI to use in the cluster, must be CNI supported by rke. Set to none to install own CNI"
}

### Leader node variables ###
variable leader {
  type = object({
    count         = number
    network_id    = string
    ip_range      = string
    host          = number
    cpu           = number
    memory        = number
    docker_disk   = number
    disk_offering = string
  })
  default = {
    count         = 3
    network_id    = ""
    ip_range      = ""
    host          = 0
    cpu           = 2
    memory        = 4096
    docker_disk   = 60
    disk_offering = "Guaranteed Performance, 10'000 iops min"
  }
  description = <<-EOF
                Defines leader nodes
                network_id is the network where the master nodes will be created
                ip_range is the CIDR of the network where the leader nodes are scheduled
                host is the starting bit of the leader hosts (0= first available IP, 32=32nd available IP in the range)
                disk_offering is the cloud.ca disk offering used by the additional volumes
                EOF
}

### Worker node variables ###
variable worker {
  type = object({
    count         = number
    network_id    = string
    ip_range      = string
    host          = number
    cpu           = number
    memory        = number
    docker_disk   = number
    disk_offering = string
  })
  default = {
    count         = 3
    network_id    = ""
    ip_range      = ""
    host          = 0
    cpu           = 4
    memory        = 8192
    docker_disk   = 100
    disk_offering = "Guaranteed Performance, 10'000 iops min"
  }
  description = <<-EOF
                Defines leader nodes
                network_id is the network where the master nodes will be created
                ip_range is the CIDR of the network where the leader nodes are scheduled
                host is the starting bit of the leader hosts (0= first available IP, 32=32nd available IP in the range)
                disk_offering is the cloud.ca disk offering used by the additional volumes
                EOF
}

### Storage Worker node variables ###
variable worker_st {
  type = object({
    count              = number
    network_id         = string
    ip_range           = string
    host               = number
    cpu                = number
    memory             = number
    docker_disk        = number
    data_size          = number
    disk_offering      = string
    data_disk_offering = string
  })
  default = {
    count              = 0
    network_id         = ""
    ip_range           = ""
    host               = 0
    cpu                = 4
    memory             = 8192
    docker_disk        = 100
    data_size          = 200
    disk_offering      = "Guaranteed Performance, 10'000 iops min"
    data_disk_offering = "Economy, reduced resiliency (CloudOps)"
  }
  description = <<-EOF
                Defines leader nodes
                network_id is the network where the master nodes will be created
                ip_range is the CIDR of the network where the leader nodes are scheduled
                host is the starting bit of the leader hosts (0= first available IP, 32=32nd available IP in the range)
                disk_offering is the cloud.ca disk offering used by the additional volumes
                EOF
}

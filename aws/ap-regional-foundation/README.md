# Network

Module to create the Foundation of a region. Should be run once per region, all deployments will use this shared foundation.

```
module network {
  source             = ""
  environment        = var.environment
  region             = var.aws_region
  access_ips         = var.access_ips
  availability_zones = var.availability_zones
}
```

## variables

#### environment

Should be either production or staging.

#### region

AWS region, must be a valid region.

####  availability_zones

AWS AZ

#### access_ips

list of IP addresses (in CIDR format) which will have SSH access to the bastion server
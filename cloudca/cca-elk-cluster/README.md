# cca-elk-cluster

Module will create unconfigured ELK nodes on Cloud.ca

```
module "cca-elk-cluster" {
  source = git@sgit.cloudops.com:operations/tf-modules/cca-elk-cluster.git

  automation_key  = "my_ssh_key"
  environment_id  = ""
  network_cidr    = "10.212.16"
  netowrk_id      = ""
  dmznetwork_cidr = "10.212.16"
  dmznetowrk_id   = ""
  cluster_name    = "logs-r1"
}
```

See `variables.tf` for optional variables and default values as well as descriptions for the variables

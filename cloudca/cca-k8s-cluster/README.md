# cca-k8s-cluster

The module block in your main.tf should look like this:
```
module "cca-k8s-cluster" {
  source = "git@sgit.cloudops.com:operations/tf-modules/cca-k8s-cluster.git"

  environment_id = ""
  cluster_fqdn   = ""
  cluster_name   = ""
  ssh_key        = ""
  image          = ""

  leader    = var.leader
  worker    = var.worker
  worker_st = var.worker_st
}
```

The node variable blocks should looks something like this:
```
leader = {
    network_id = var.secure_network_id
    ip_range   = "10.0.0.0/24"
    host       = 110
}

worker = {
    network_id = var.dmz_network_id
    ip_range   = "10.0.1.0/24"
    host       = 128
}

worker_st = {
    count      = 3
    network_id = var.dmz_network_id
    ip_range   = "10.0.2.0/24"
    host       = 136
    memory     = 16384
    data_size  = 500
}
```

#### Please see variables.tf for description of variables and for additional values

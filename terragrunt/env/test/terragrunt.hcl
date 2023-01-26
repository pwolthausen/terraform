terraform {
  source = "git::git@github.com:pwolthausen/terraform//gcp/modules/gke"
}

include "root" {
  path = find_in_parent_folders()
}
inputs = {
  network_project_id      = "cloudops-pwolthausen-sandbox"
  network_name            = "vpc-pw-core"
  subnet_name             = "dublin"
  cluster_secondary_range = "pod-cidr"
  service_secondary_range = "service-cidr-0"
  master_ipv4_cidr_block  = "10.0.16.0/28"
  service_account_email   = "80612684543-compute@developer.gserviceaccount.com"
  master_authorized_networks = {
    prod-common-cicd = "10.61.120.0/25"
  }
  node_pools = {
    pool-1 = {
      machine_type = "e2-small"
    }
  }
}

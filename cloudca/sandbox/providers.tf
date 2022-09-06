provider "cloudca" {
  api_key = var.cloudca_api_key
  api_url = "https://hypertec.cloud/api/v1"
}

provider "rke" {}

terraform {
  required_providers {
    cloudca = {
      source  = "cloud-ca/cloudca"
      version = "1.6.0"
    }
    rke = {
      source  = "rancher/rke"
      version = "1.3.2"
    }
  }
  backend "swift" {
    container         = "pw-sandbox-state"
    archive_container = "pw-sandbox-state_backup"
    auth_url          = "https://auth.cloud.ca"
    region_name       = "multi-region"
    tenant_name       = "cloudops-tf-state-852414"
  }
}

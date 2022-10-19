provider "cloudca" {
  api_key = var.cloudca_api_key
  api_url = "https://hypertec.cloud/api/v1"
}

provider "azurerm" {
  subscription_id = var.azure_sub
  features {}
}

terraform {
  # experiments = [module_variable_optional_attrs]
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.21.1"
    }
    cloudca = {
      source  = "cloud-ca/cloudca"
      version = "1.6.0"
    }
  }
  # backend "swift" {
  #   container         = "pw-azure-sandbox-state"
  #   archive_container = "pw-azure-sandbox-state_backup"
  #   auth_url          = "https://auth.cloud.ca"
  #   region_name       = "multi-region"
  #   tenant_name       = "cloudops-tf-state-852414"
  # }
  backend "gcs" {
    bucket = "bkt-advk8s-tfstate"
    prefix = "terraform/pwolthausen/vpn-test/az-state"
  }
}

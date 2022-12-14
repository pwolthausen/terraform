locals {
  env            = get_original_terragrunt_dir()
}

inputs = {
  env        = "${local.env}"
  project_id = "cloudops-pwolthausen-sandbox"
  domain     = "netw"
  usecase    = "nane1"
  index      = "01"
  region     = "northamerica-northeast1"
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "gcs" {
    bucket = "co-pw-tf-state-files"
    prefix = "bell-gke/${path_relative_to_include()}"
  }
}
EOF
}

generate "provider" {
  path      = "providers.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_version = "~> 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.32.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.32.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.8.0"
    }
  }
}

provider "google" {}

provider "google-beta" {}

data "google_client_config" "default" {}

EOF
}


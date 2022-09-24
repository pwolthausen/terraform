terraform {
  backend "gcs" {
    bucket = "bkt-advk8s-tfstate"
    prefix = "terraform/pwolthausen/vpn-test/state"
  }
}

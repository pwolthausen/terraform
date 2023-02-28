terraform {
  backend "s3" {
    bucket  = ""
    key     = ""
    region  = "ca-central-1"
    profile = "coo"
    encrypt = "true"
  }
}

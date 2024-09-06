data "aws_ami" "windows-2019" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "platform"
    values = ["windows"]
  }
  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base*"]
  }
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_vpc" "selected" {
  id = "vpc-005b47880a57e0950"
}

data "aws_subnets" "selected" {

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_subnet" "selected" {
  count = length(data.aws_subnets.selected.ids)
  id    = data.aws_subnets.selected.ids[count.index]
}

locals {
  availability_zones = data.aws_availability_zones.available.names
  tags = {
    Environment = "pw-sandbox"
    Owner       = "pwolthausen"
  }
  subnets          = data.aws_subnet.selected
  endpoint_subnets = var.ses_endpoint_failover ? slice(local.subnets, 0, 2) : [local.subnets[0]]
}

variable "ses_endpoint_failover" {
  type        = bool
  description = "Determines whether the SES VPC endpoint is deployed in a single AZ or multiple"
  default     = true
}
